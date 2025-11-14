#!/usr/bin/env python3

import argparse
import subprocess
import os
from urllib.parse import urlparse
import requests
import tarfile
from tqdm import tqdm

import utilities


aliases = {
    'cr2re': ['cr2re', 'crires+', 'crires2', 'cr2res'],
    'efosc': ['efosc', 'efosc2'],
    'espda': ['espda', 'espresso_da'],
    'espdr': ['espdr', 'espresso_dr', 'espresso'],
    'fors': ['fors', 'fors1', 'fors2'],
    'giraf': ['giraf', 'giraffe'],
    'sinfo': ['sinfo', 'sinfoni'],
    'spher': ['spher', 'sphere'],
    'vcam': ['vcam', 'vircam'],
    'xshoo': ['xshoo', 'xshooter']
}


#_______________________________________________________________________________________________________________________
def list_installed(brew, aliases):
    result = subprocess.run([brew, 'list', '-1'], capture_output=True, text=True)
    if result.returncode == 0:
        lines = result.stdout.splitlines()
        filtered_lines = [line for line in lines if 'esopipe' in line and 'recipes' in line]
    else:
        filtered_lines = []

    installed = [r.replace('esopipe-', '').replace('-recipes', '')
                 for r in filtered_lines if r != '']

    print('The following pipelines are installed:')
    print(f'{"Name":20} {"Aliases":30}')
    print(f'{"____":20} {"_______":30}')
    for name in installed:
        if name in aliases.keys():
            aliases_str = ', '.join(aliases[name][1:])
        else:
            aliases_str = ''
        print(f'{name:20} {aliases_str:30}')

    print()
    exit()


def make_instrument_list(brew, alias_dict, just_list):
    if just_list:
        print('The following pipelines are available to be installed:')
        print(f'{"Name":20} {"Aliases":30} {"Demo Data"}')
        print(f'{"____":20} {"_______":30} {"_________"}')

    command = [brew, "search", "/esopipe-.*-recipes/"]
    result = subprocess.run(command, capture_output=True, text=True)
    instrument_list = [r.replace('eso/pipelines/esopipe-', '').replace('-recipes', '')
                       for r in result.stdout.split('\n') if r != '']

    instruments_aliases = {i: [i] for i in instrument_list}
    for name, alias in alias_dict.items():
        instruments_aliases[name] = alias

    demodata = {i: 'No' for i in instrument_list}
    for name in demodata.keys():
        demodata_link = install_demodata(name, None, just_check=True)
        if demodata_link is not None:
            demodata[name] = 'Yes'

        if just_list:
            aliases_str = ', '.join(instruments_aliases[name][1:])
            print(f'{name:20} {aliases_str:30} {demodata[name]}')

    if just_list:
        exit()
    else:
        return instruments_aliases


def get_key_by_list_value(d, target_list):
    for key, value in d.items():
        if target_list in value:
            return key
    return None


def install_esopipe(pipe, brew, uninstall=False):
    package = f'esopipe-{pipe}'
    if uninstall:
        command = [brew, 'uninstall', package]
    else:
        command = [brew, 'install', package]


    try:
        subprocess.run(command, check=True)
        print(f'Successfully un/installed packages for {pipe}')
        return None
    except subprocess.CalledProcessError as e:
        print(f'Un/installation failed: {e}')
        return pipe


def install_demodata(pipe, dir, just_check=False):
    # Instantiate the extractor ...
    extractor = utilities.URLExtractor('https://www.eso.org/sci/software/pipe_aem_table.html', pipe)
    #
    # ... and extract matching URL
    link = extractor.extract_urls()

    if just_check:
        return link

    if link is None:
        print(f'No demo data is avaialble for instrument {pipe} ...')
        return pipe

    print(f'The Demo Data link for {pipe.upper()} is: {link}')

    # Extract the filename from the URL
    filename = os.path.basename(urlparse(link).path)

    # Download the file with a progress indicator
    response = requests.get(link, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    block_size = 1024

    with open(filename, 'wb') as f, tqdm(total=total_size, unit='iB', unit_scale=True) as progress_bar:
        for chunk in response.iter_content(chunk_size=block_size):
            f.write(chunk)
            progress_bar.update(len(chunk))

    with tarfile.open(filename, 'r:gz') as tar:
        tar.extractall(path=dir, filter=utilities.safe_extract_filter)

    os.remove(filename)
    return None

#_______________________________________________________________________________________________________________________
if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-i', '--instruments_in', nargs='+', type=str,
                        help='[all | space-separated list of instruments]')
    parser.add_argument('-u', '--uninstall', action='store_true',
                        help='Uninstall the pipeline')
    parser.add_argument('-d', '--download_demodata', action='store_true',
                        help='Download demo data')
    parser.add_argument('-np', '--no_pipe', action='store_true',
                        help='Do not install the pipeline. Use in combination with '
                             '-d/--download_demodata to download only the demodata')
    parser.add_argument('-la', '--list_available', action='store_true',
                        help='List the available pipelines and exit')
    parser.add_argument('-li', '--list_installed', action='store_true',
                        help='List the installed pipelines and exit')
    parser.add_argument('-dd', '--demodata_dir', type=str,
                        help='Root directory to write the demo data in',
                        default='/opt/cloudadm/EDPS_data/demodata')
    parser.add_argument('-b', '--brew', type=str,
                        help='Path to the brew command',
                        default='/home/linuxbrew/.linuxbrew/bin/brew')
    args = parser.parse_args()

    if not args.instruments_in and not args.list_available and not args.list_installed:
        print('Please provide a list of pipelines to install (-i), or run with -la/-li to see what is '
              'available/installed.')
        print('   Exiting ...')
        print()
        exit(1)

    if args.list_installed:
        list_installed(args.brew, aliases)

    instruments = make_instrument_list(args.brew, aliases, args.list_available)

    if args.instruments_in == ['all']:
         args.instruments_in = list(instruments.keys())

    unknown, successful, failed, no_demodata = '', '', '', ''
    for instrument_in in args.instruments_in:
        instrument_in = instrument_in.lower()
        instrument = get_key_by_list_value(instruments, instrument_in)
        if instrument is None:
            print('Instrument unknown: ', instrument_in)
            unknown += instrument_in + ' '
            continue

        if not args.no_pipe:
            # Install the requested pipeline ...
            this_failed = install_esopipe(instrument, args.brew, uninstall=args.uninstall)
            if this_failed is not None:
                failed += this_failed + ' '
            else:
                successful += instrument_in + ' '

        # ... and, if so wished, the demo data ...
        if args.download_demodata:
            no_this_demodata = install_demodata(instrument, args.demodata_dir)
            if no_this_demodata is not None:
                no_demodata += no_this_demodata + ' '

    print()
    print()
    print('In summary:')
    print('   Requested instruments: ', ' '.join(args.instruments_in))
    print('   Successful un/installations: ', successful)
    print('   Unknown instruments: ', unknown)
    print('   Failed installations: ', failed)
    if args.download_demodata:
        print('   No demo data available: ', no_demodata)
    print()

#!/usr/bin/env python3

'''
Make a tar suitable for download out of the Exported EDPS files
'''

import os
import tarfile
import argparse

def find_files_recursive(root_directory, search_string):
    matching_files = []
    for dirpath, dirnames, filenames in os.walk(root_directory):
        for filename in filenames:
            if search_string in filename:
                matching_files.append(os.path.join(dirpath, filename))
    return matching_files


def create_tar_from_filelist(filenames, tar_path, compression=None):
    """
    Create a tar archive from a list of filenames.
    Resolves symbolic links to point directly to filenames in the archive.

    Args:
        filenames (list): List of file paths to include in the tar
        tar_path (str): Path where the tar file should be created
        compression (str): Compression type ('gz', 'bz2', 'xz', or None)
    """
    # Determine the mode based on compression
    if compression == 'gz':
        mode = 'w:gz'
    elif compression == 'bz2':
        mode = 'w:bz2'
    elif compression == 'xz':
        mode = 'w:xz'
    else:
        mode = 'w'  # No compression

    try:
        with tarfile.open(tar_path, mode) as tar:
            for filename in filenames:
                if os.path.exists(filename):
                    # Resolve symbolic links to get the actual file
                    resolved_path = os.path.realpath(filename)

                    if os.path.islink(filename):
                        # For symbolic links, add the target file with the original basename
                        arcname = os.path.basename(filename)
                        tar.add(resolved_path, arcname=arcname)
                        print(f"Added (resolved symlink): {filename} -> {resolved_path} as {arcname}")
                    else:
                        # For regular files, add normally
                        arcname = os.path.basename(filename)
                        tar.add(filename, arcname=arcname)
                        print(f"Added: {filename} as {arcname}")
                else:
                    print(f"Warning: File not found: {filename}")

        print(f"Tar archive created successfully: {tar_path}")

    except Exception as e:
        print(f"Error creating tar archive: {e}")

#________________________________________________________________________________________________________________
if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-e', '--edps_export_dir', type=str,
                        help='Root directory where EDPS exported the datasets of interest')
    parser.add_argument('-t', '--tar_path', help='Output tar file',
                        default='/opt/cloudadm/Notebooks/exported_files.tgz')
    parser.add_argument('-f', '--filename_patterns', nargs='+',
                        help='File name patterns to be included in the output tar (space separated)')
    args = parser.parse_args()

    files_to_tar = []
    for filename_pattern in args.filename_patterns:
        files_to_tar += find_files_recursive(args.edps_export_dir, filename_pattern)

    create_tar_from_filelist(files_to_tar, args.tar_path, 'gz')


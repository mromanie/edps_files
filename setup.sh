#! /bin/bash

#./setup.bash cloudadm 89.47.190.7 ~/.ssh/id_rsa_EUNode passwd

uname=$1
ip=$2
id_rsa=$3
pwd=$4

file_source="https://raw.githubusercontent.com/mromanie/edps_files/refs/heads/main/"

bold=$(tput bold)
normal=$(tput sgr0)

echo
echo "${bold}Connecting to remote host and executing all setup steps...${normal}"
echo

ssh -i "${id_rsa}" "${uname}@${ip}" bash -s <<EOF
set -e

echo
echo "${bold}Creating the directory structure ...${normal}"
mkdir -p \
    .config \
    Notebooks \
    Notebooks/Utilities \
    app \
    EDPS_data \
    EDPS_data/EDPS_workdir \
    bin \
    .edps
echo "${bold}   ... done${normal}"

echo
echo "${bold}Downloading and installing files ...${normal}"
curl -sSf -o Notebooks/Utilities/utilities.py ${file_source}utilities.py
curl -sSf -o Notebooks/raw_browse_download.ipynb ${file_source}raw_browse_download.ipynb
curl -sSf -o Notebooks/Utilities/eso_programmatic.py ${file_source}eso_programmatic.py
curl -sSf -o bin/gui_stop ${file_source}gui_stop.sh
curl -sSf -o bin/gui_start ${file_source}gui_start.sh
curl -sSf -o bin/gui_check ${file_source}gui_check.sh
curl -sSf -o bin/lab_stop ${file_source}lab_stop.sh
curl -sSf -o bin/lab_start ${file_source}lab_start.sh
curl -sSf -o bin/lab_check ${file_source}lab_check.sh
curl -sSf -o bin/gui_reinstall ${file_source}gui_reinstall.sh
curl -sSf -o bin/pipe_install ${file_source}pipe_install.py
curl -sSf -o bin/splash.txt ${file_source}splash.txt
curl -sSf -o bin/make_tar_for_download ${file_source}make_tar_for_download.py
curl -sSf -o app/requirements_notebooks.txt ${file_source}requirements_notebooks.txt
curl -sSf -o app/requirements_edps.txt ${file_source}requirements_edps.txt
curl -sSf -o .bashrc ${file_source}bashrc_profile
curl -sSf -o .profile ${file_source}bashrc_profile
curl -sSf -o .edps/application.properties ${file_source}application.properties
curl -sSf -o .edps/logging.yaml ${file_source}logging.yaml
curl -sSf -o .jupyter/jupyter_server_config.py ${file_source}jupyter_server_config.py

chmod +x \
    bin/gui_start \
    bin/gui_stop \
    bin/gui_check \
    bin/gui_reinstall \
    bin/lab_start \
    bin/lab_stop \
    bin/lab_check \
    bin/pipe_install \
    bin/make_tar_for_download
echo "${bold}   ... done${normal}"

echo
echo "${bold}Installing a bunch of things, including graphviz ...${normal}"
sudo rm -f /etc/apt/sources.list.d/*.list
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    git-lfs \
    wget \
    procps \
    zip \
    unzip \
    htop \
    vim \
    nano \
    bzip2 \
    libx11-6 \
    build-essential \
    libsndfile-dev \
    software-properties-common \
    debian-keyring \
    debian-archive-keyring \
    gnupg \
    gfortran \
    graphviz
sudo rm -rf /var/lib/apt/lists/*
echo "${bold}   ... done${normal}"

echo
echo "${bold}Installing Homebrew ...${normal}"
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
/home/linuxbrew/.linuxbrew/bin/brew install gcc
echo "${bold}   ... done${normal}"

echo
echo "${bold}Installing JupyterLab, EDPS and dependencies ...${normal}"
sudo apt-get update
sudo apt-get install -y python3-venv || { echo "${bold}ERROR: Failed to install python3-venv${normal}"; exit 1; }
python3 -m venv ~/python/venvs/edps || { echo "${bold}ERROR: Failed to create virtual environment${normal}"; exit 1; }
. ~/python/venvs/edps/bin/activate || { echo "${bold}ERROR: Failed to activate virtual environment${normal}"; exit 1; }
pip install jupyterlab || { echo "${bold}ERROR: Failed to install JupyterLab${normal}"; exit 1; }
pip install -r app/requirements_edps.txt || { echo "${bold}ERROR: Failed to install EDPS packages${normal}"; exit 1; } 
pip install --no-cache-dir -r app/requirements_notebooks.txt || { echo "${bold}ERROR: Failed to install notebook requirements${normal}"; exit 1; }
echo "${bold}   ... done${normal}"

echo
echo "${bold}Starting JupyterLab ...${normal}"
nohup bash -c "export PYTHONPATH=\"\${HOME}/Notebooks/Utilities:\${PYTHONPATH}\" ; \
              . ~/python/venvs/edps/bin/activate && \
              jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token=${pwd}" > app/jupyter.log 2>&1 &
echo "${bold}   ... done${normal}"

echo
echo "${bold}Starting EDPS GUI ...${normal}"
export PANEL_AUTH=$pwd
export PANEL_COOKIE=$(python -c "import secrets; print(secrets.token_urlsafe(32))")
echo >> ~/.bashrc
echo export PANEL_COOKIE=$PANEL_COOKIE >> ~/.bashrc
echo export PANEL_AUTH=$PANEL_AUTH >> ~/.bashrc

nohup bash -c "export EDPSGUI_PDF_DIR=\"\${HOME}/app/EDPS_GUI_PDF\" ; \
              export ADARI_REPORTS_DIR=\"/home/linuxbrew/.linuxbrew/share/esopipes/reports\" ; \
              . ~/python/venvs/edps/bin/activate && \
              edps-gui --plugins edpsgui.pdf_handler --address 0.0.0.0 --port 7860 --allow-websocket-origin=\"*\" --basic-auth ${PANEL_AUTH} --cookie-secret ${PANEL_COOKIE} --admin" > app/edps_gui.log 2>&1 &
echo "${bold}   ... done${normal}"

echo
echo "${bold}Setting up the ESO Pipeline Repository ...${normal}"
/home/linuxbrew/.linuxbrew/bin/brew tap eso/pipelines
echo "${bold}   ... done${normal}"

echo
echo "${bold}Done!${normal}"
EOF

echo
echo "${bold}To access the VM, point your browser to: http://${ip}:8888/lab${normal}"
echo
echo "${bold}Done!${normal}"
echo

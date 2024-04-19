#!/bin/bash


#Install for 64Bit Ubuntu (debian) systems

#make file `waveware_deploy` with private key
mkdir sw
cd sw
if grep -q microsoft /proc/version; then
  echo "Install WSL..."
else
  echo "Install Linux..."
fi

cd ~/

if [ -f "~/.ssh/id_rsa" ]; then
    echo 'Setting Up Github Account (first input)'
    ssh-keygen -t rsa -b 4096 -C "$1"
    git config --global user.email "$1"
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa

    echo 'Add your public key to your github account'
    cat < ./.ssh/id_rsa.pub
fi


#Write bashrc file (install permisisons)
eval $(ssh-agent -s)
# /bin/cat <<EOM >"/home/$(whoami)/.bashrc"
# eval `ssh-agent`
# EOM
# 
# /bin/cat <<EOM >"/home/$(whoami)/.bash_logout"
# kill $SSH_AGENT_PID
# EOM

CNFG="/home/$(whoami)/.ssh/config"
echo "touch $CNFG"
touch "$CNFG" #ensure config file
echo "write config $CNFG"
/bin/cat <<EOM >$CNFG
Host github.com
    Hostname github.com
    IdentityFile=/home/user/.ssh/waveware_deploy
Host gist.github.com
    Hostname gist.github.com
    IdentityFile=/home/user/.ssh/waveware_deploy

EOM

ssh-add ~/.ssh/waveware_deploy

#stop pigpiod
sudo killall pigpiod

#initalize git
git config --global user.name "wavetank"

#Install Preliminaries
sudo apt update -y

sudo apt install git -y
sudo apt install gcc -y
sudo apt install g++ -y
sudo apt install build-essential -y
sudo apt install net-tools -y
sudo apt install gfortran -y
sudo apt install libatlas-base-dev -y

sudo apt install unzip,nettools -y
sudo apt install make,cmake,gcc,gfortran -y
sudo apt install python3-pip -y
sudo apt install python3-setuptools -y
sudo apt install python3-pigpio -y
sudo apt install libatlas3-base -y

echo 'Installing Anaconda Python (follow instructions, agree & yes^10)'
if [ -z "$CONDA_EXE" ] 
then
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    bash Miniforge3-$(uname)-$(uname -m).sh
    source ~/.bashrc
    
    ~/miniforge3/bin/conda init bash
    conda create -n py3 python=3.10 -y
    conda activate py3
    conda install -c anaconda pip 
    pip install -U -y pip-tools
else
    conda activate py3
fi

python -m pip install --force-reinstall ninja
python -m pip install git+ssh://git@github.com/neptunyalabs/wave_tank_driver.git

#Install pigpiod source
# wget https://github.com/joan2937/pigpio/archive/master.zip
# unzip master.zip
# cd pigpio-master
# make
# sudo make install




# read -p "Press enter to continue"
# 
# echo 'Installing Ottermatics Lib'
# git clone git@github.com:SoundsSerious/engforge.git
# cd engforge
# ~/miniconda3/bin/python3 -m pip install -r requirements.txt
# ~/miniconda3/bin/python3 setup.py install
#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

ln -sf ${SCRIPT_DIR}/.bash_profile ~/.bash_profile
ln -sf ${SCRIPT_DIR}/.bashrc ~/.bashrc
ln -sf ${SCRIPT_DIR}/.vim ~/.vim
ln -sf ${SCRIPT_DIR}/.vimrc ~/.vimrc
ln -sf ${SCRIPT_DIR}/.gitconfig ~/.gitconfig
ln -sf ${SCRIPT_DIR}/.gitignore_global ~/.gitignore_global

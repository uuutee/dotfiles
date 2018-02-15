#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

ln -s ${SCRIPT_DIR}/.bash_profile ~/.bash_profile
ln -s ${SCRIPT_DIR}/.bashrc ~/.bashrc
ln -s ${SCRIPT_DIR}/.vim ~/.vim
ln -s ${SCRIPT_DIR}/.vimrc ~/.vimrc
ln -s ${SCRIPT_DIR}/.gitconfig ~/.gitconfig
ln -s ${SCRIPT_DIR}/.gitignore_global ~/.gitignore_global

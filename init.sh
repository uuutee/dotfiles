#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

ln -s -f ${SCRIPT_DIR}/.bash_profile ~/.bash_profile
ln -s -f ${SCRIPT_DIR}/.bashrc ~/.bashrc
ln -s -f ${SCRIPT_DIR}/.vim ~/.vim
ln -s -f ${SCRIPT_DIR}/.vimrc ~/.vimrc
ln -s -f ${SCRIPT_DIR}/.gitconfig ~/.gitconfig
ln -s -f ${SCRIPT_DIR}/.gitignore_global ~/.gitignore_global

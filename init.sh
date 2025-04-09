#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

# Permit execute script
chmod +x ${SCRIPT_DIR}/scripts/*

# Create symlinks
ln -sf ${SCRIPT_DIR}/.bash_profile $HOME/.bash_profile
ln -sf ${SCRIPT_DIR}/.bashrc $HOME/.bashrc
ln -sf ${SCRIPT_DIR}/.zprofile $HOME/.zprofile
ln -sf ${SCRIPT_DIR}/.zshrc $HOME/.zshrc
ln -sf ${SCRIPT_DIR}/.vimrc $HOME/.vimrc

# vim (2重にsymlinkを作らないようにする)
if [[ ! -L "$HOME/.vim" ]]; then
    ln -s ${SCRIPT_DIR}/.vim $HOME/.vim
fi

# molokai.vim
(cd ${SCRIPT_DIR}; git submodule update --init)

# git
if [[ ! -L "$HOME/.config/git" ]]; then
    ln -s ${SCRIPT_DIR}/.config/git $HOME/.config/git
fi

# karabiner
if [[ ! -L "$HOME/.config/karabiner" ]]; then
    ln -s ${SCRIPT_DIR}/.config/karabiner $HOME/.config/karabiner
fi

# Remove localized
${SCRIPT_DIR}/scripts/remove_localized.sh

# Permit QuickLook plugin
# https://github.com/whomwah/qlstephen/issues/81#issuecomment-582365549
if [[ ! -L "$HOME/Library/QuickLook" ]]; then
    xattr -cr ~/Library/QuickLook/*.qlgenerator
    qlmanage -r
    qlmanage -r cache
fi

# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles TRUE

# Finderを再起動
killall Finder

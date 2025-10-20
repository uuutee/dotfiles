#! /bin/bash
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

link_shared_prompts() {
    local target_dir=$1
    local link_path=$2
    local parent_dir
    parent_dir=$(dirname "${link_path}")

    mkdir -p "${parent_dir}"

    if [[ -e "${link_path}" && ! -L "${link_path}" ]]; then
        mv "${link_path}" "${link_path}.bak.$(date +%Y%m%d%H%M%S)"
    fi

    ln -sfn "${target_dir}" "${link_path}"
}

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

# tmux
if [[ ! -L "$HOME/.tmux.conf" ]]; then
    ln -s ${SCRIPT_DIR}/.tmux.conf $HOME/.tmux.conf
fi

# Shared prompts for CLI tools
SHARED_PROMPTS_DIR=${SCRIPT_DIR}/prompts/shared
if [[ -d "${SHARED_PROMPTS_DIR}" ]]; then
    link_shared_prompts "${SHARED_PROMPTS_DIR}" "${HOME}/.codex/prompts"
    link_shared_prompts "${SHARED_PROMPTS_DIR}" "${HOME}/.claude/commands"
    link_shared_prompts "${SHARED_PROMPTS_DIR}" "${HOME}/.cursor/commands"
fi

# Remove localized
${SCRIPT_DIR}/scripts/remove-localized/main.sh

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

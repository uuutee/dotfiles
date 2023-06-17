# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# pyenv
export PATH="$HOME/.pyenv/shims:$PATH"
eval "$(pyenv init -)"

# rbenv
eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# direnv
eval "$(direnv hook zsh)"

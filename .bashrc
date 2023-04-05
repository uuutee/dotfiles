export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

#  rust
if [[ -d "$HOME/.cargo" ]]; then
  . "$HOME/.cargo/env"
fi

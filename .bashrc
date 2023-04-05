
# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f ~/.anyenv/envs/nodenv/versions/9.6.1/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash ] && . ~/.anyenv/envs/nodenv/versions/9.6.1/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f ~/.anyenv/envs/nodenv/versions/9.6.1/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash ] && . ~/.anyenv/envs/nodenv/versions/9.6.1/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

#  rust
if [[ -d "$HOME/.cargo" ]]; then
  . "$HOME/.cargo/env"
fi

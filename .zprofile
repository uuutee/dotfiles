# .zshrc を読み込んで、その設定をログインシェルにも適用する
if [ -f "$HOME/.zshrc" ]; then
  source "$HOME/.zshrc"
fi

# .bashrc を読み込んで、その設定をログインシェルにも適用する
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

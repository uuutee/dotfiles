# for titanium
ANDROID_SDK=/android-sdk
export PATH=$PATH:$ANDROID_SDK/tools
# titanium builder alias
alias ibuilder='/Users/ut/Library/Application\ Support/Titanium/mobilesdk/osx/2.1.4.GA/iphone/builder.py'
alias abuilder='/Users/ut/Library/Application\ Support/Titanium/mobilesdk/osx/2.1.4.GA/android/builder.py'
# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'
# findの置換でエラーが出るので
export LANG=C
# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoreboth:erasedups
# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="cd*:ls*:pwd"
# ヒストリのサイズを増やす
export HISTSIZE=10000
# lessの文字化け対策
export LESSCHARSET=utf-8
# adbコマンドを使うため、platform-toolsのディレクトリを指定
export PATH=$PATH:/Applications/adt-bundle-mac-x86/sdk/platform-tools
# .rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# homebrewのctagsを使うようにする
alias ctags="/usr/local/bin/ctags"
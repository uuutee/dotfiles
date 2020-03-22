# dotfiles

## Installation

Install dotfiles

```
git clone git@github.com:uuutee/dotfiles.git
cd dotfiles
chmod +x ./init.sh
./init.sh
```

Install brew packages

```
brew bundle --file etc/homebrew/Brewfile
```

## Development

Update Brewfile

```
brew bundle dump --file etc/homebrew/Brewfile --force
```

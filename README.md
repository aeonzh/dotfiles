# Usage

```sh
mkdir $HOME/src
git clone https://github.com/aeonzh/dotfiles.git $HOME/src/dotfiles
alias dots='git --git-dir=$HOME/src/dotfiles/ --work-tree=$HOME'
dots checkout
```

## Brew

```sh
cat ~/Brewfile* | brew bundle

# or alternatively choose only the files you intend to include
```

## WSL

### ZSH

```sh
sudo vi /etc/shells
```

Add
```sh
/home/linuxbrew/.linuxbrew/bin/zsh
```

Run
```sh
chsh -s $(which zsh)
```

Restart WSL
```sh
wsl --shutdonw
```

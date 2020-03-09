# Nix
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then source $HOME/.nix-profile/etc/profile.d/nix.sh; fi

# Aliases
alias delds="fd -H .DS_Store -x rm"
alias dots='git --git-dir=$HOME/src/dotfiles --work-tree=$HOME'
alias yabai-off="launchctl unload ~/Library/LaunchAgents/org.nixos.yabai.plist; launchctl unload ~/Library/LaunchAgents/org.nixos.skhd.plist"
alias yabai-on="launchctl load ~/Library/LaunchAgents/org.nixos.yabai.plist; launchctl load ~/Library/LaunchAgents/org.nixos.skhd.plist"
alias ls="exa -la --group-directories-first --icons"
alias tf="terraform"
alias circleci="circleci-cli"
alias g="git"
alias k="kubectl"

# Autocompletion
fpath=($HOME/.nix-profile/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit

# Options
setopt correct

# Better History
HISTORY_IGNORE='ls:bg:fg:history:n:nnn'
HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

# FZF
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"

_gen_fzf_default_opts() {

    local color00='00'
    local color01='10'
    local color02='11'
    local color03='08'
    local color04='12'
    local color05='07'
    local color06='13'
    local color07='15'
    local color08='01'
    local color09='09'
    local color0A='03'
    local color0B='02'
    local color0C='06'
    local color0D='04'
    local color0E='05'
    local color0F='14'

    export FZF_DEFAULT_OPTS="
      --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D
      --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
      --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D
    "

}

_gen_fzf_default_opts

# NNN
n()
{
    export NNN_TMPFILE=${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd

    nnn -dH"$@"

    if [ -f $NNN_TMPFILE ]; then
            . $NNN_TMPFILE
            rm $NNN_TMPFILE
    fi
}

# z.lua (Installed from nixpkgs)
export _ZL_CMD=j
export _ZL_DATA='~/.cache/z.lua'
eval "$(z --init zsh enhanced once fzf)"

# autosuggestions
source $HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh syntax
source $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

# direnv
eval "$(direnv hook zsh)"

# NeoVim
export VIMCONFIG=$HOME'/.vim/'
export EDITOR=nvim

# Restart service (for yabai, skhd)
restart()
{
    launchctl kickstart -k "gui/${UID}/$1"
}


# Using Nix or Homebrew
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then 
    PKGS_PREFIX=$HOME/.nix-profile
    source $HOME/.nix-profile/etc/profile.d/nix.sh
fi
if type brew &>/dev/null; then
    PKGS_PREFIX=$(brew --prefix)
fi

# Autocompletion
fpath+=$PKGS_PREFIX/share/zsh/site-functions

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

    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
     --color=fg:#cbccc6,bg:#1f2430,hl:#707a8c
     --color=fg+:#707a8c,bg+:#191e2a,hl+:#ffcc66
     --color=info:#73d0ff,prompt:#707a8c,pointer:#cbccc6
     --color=marker:#73d0ff,spinner:#73d0ff,header:#d4bfff'

}

_gen_fzf_default_opts

# NNN
n()
{
    export NNN_TMPFILE=${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd

    nnn -nadH"$@"

    if [ -f $NNN_TMPFILE ]; then
            . $NNN_TMPFILE
            rm $NNN_TMPFILE
    fi
}

export NNN_PLUG='o:preview-tui'

# z.lua (Installed from nixpkgs)
export _ZL_CMD=j
export _ZL_DATA='~/.cache/z.lua'
if [ -d $HOME/.nix-profile ]; then eval "$(z --init zsh enhanced once fzf)"; fi
if type brew &>/dev/null; then eval "$(lua /opt/homebrew/share/z.lua/z.lua --init zsh enhanced once fzf)"; fi

# autosuggestions
source $PKGS_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh syntax
source $PKGS_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NeoVim
export VIMCONFIG=$HOME'/.vim/'
export EDITOR=nvim

# Ruby
source $PKGS_PREFIX/share/chruby/chruby.sh
source $PKGS_PREFIX/share/chruby/auto.sh

# Add to prompt with precmd
if [[ ! "$precmd_functions" == *chruby_auto* ]]; then
    precmd_functions+=("chruby_auto")
fi

# Kubernetes
alias k="kubectl"
source <(kubectl completion zsh)
complete -F __start_kubectl k

kctx() {
    if [[ -z "$@" ]]; then
        kubectl config use $( kubectl config get-contexts -o name | fzf )
    else
        kubectl config use $@
    fi
}

kns() {
    if [[ -z "$@" ]]; then
        kubectl config set-context --current --namespace=$( kubectl get namespaces -o name | sed 's/^namespace\///g' | fzf )
    else
        if [[ "$#" -eq 1 ]]; then
            kubectl config set-context --current --namespace=$@
        else
            echo "error: choose only one namespace ($# found)."
        fi
    fi
}

kx() {
    if [[ -z "$@" ]]; then
        kubectl exec -it $( kubectl get pod -o name | sed 's/^pod\///' | fzf ) -- bash
    else
        kubectl exec -it $1 -- bash
    fi
}


# Aliases
alias delds="fd -H .DS_Store -x rm"
alias dots='git --git-dir=$HOME/src/dotfiles --work-tree=$HOME'
alias ls="exa -la --group-directories-first --icons"
alias tf="terraform"
alias circleci="circleci-cli"
alias g="git"

# direnv
eval "$(direnv hook zsh)"

eval "$(starship init zsh)"


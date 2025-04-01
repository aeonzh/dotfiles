# Homebrew
if [[ "$(uname)" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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
eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#313244,label:#cdd6f4"

# NNN
n() {
    export NNN_TMPFILE=${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd

    nnn -nadH"$@"

    if [ -f $NNN_TMPFILE ]; then
            . $NNN_TMPFILE
            rm $NNN_TMPFILE
    fi
}

export NNN_PLUG='o:preview-tui;j:autojump'

# Zoxide
export _ZO_DATA_DIR=$HOME/.local/share
eval "$(zoxide init zsh --cmd j)"

# autosuggestions
source $PKGS_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh syntax
source $PKGS_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NeoVim
export VIMCONFIG=$HOME'/.vim/'
export EDITOR=nvim

# Asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Kubernetes
alias k="kubectl"
source <(kubectl completion zsh)
export PATH="${PATH}:${HOME}/.krew/bin"

kctx() {
    if [[ -z "$@" ]]; then
        kubectl config use $(kubectl config get-contexts -o name | fzf)
    else
        kubectl config use $@
    fi
}

kns() {
    if [[ -z "$@" ]]; then
        kubectl config set-context --current --namespace=$(kubectl get namespaces -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}" | fzf)
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
        kubectl exec -it $(kubectl get pod -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}" | fzf) -- bash
    else
        kubectl exec -it $1 -- bash
    fi
}

helm-diff() {
    current_chart_folder=${PWD##*/}
    current_kubernetes_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    current_environment=${current_kubernetes_namespace##*-}
    release_name=$(helm ls -n "${current_kubernetes_namespace}" | grep $current_chart_folder | awk '{print $1}')
    var_path="vars"
    if [[ ! -d "${var_path}" ]]
    then
        var_path=${PWD//\/charts\//\/vars\/}
    fi
    helm diff upgrade "${release_name}" ./ -f "${var_path}/values.${current_environment}.yaml" --three-way-merge
}

# Aliases
alias delds="fd -H .DS_Store -x rm"
alias dots='git --git-dir=$HOME/src/dotfiles --work-tree=$HOME'
alias ls="eza -la --group-directories-first --icons"
alias tf="terraform"
alias g="git"

# direnv
eval "$(direnv hook zsh)"

eval "$(starship init zsh)"

tfws() {
    if [[ -z "$@" ]]; then
        terraform workspace select $(terraform workspace list | fzf)
    else
        terraform workspace select $1
    fi
}


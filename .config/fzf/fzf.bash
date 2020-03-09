# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/aeonzh/.vim/bundle/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.vim/bundle/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source $HOME/.vim/bundle/fzf/shell/completion.bash 2> /dev/null

# Key bindings
# ------------
source $HOME/.vim/bundle/fzf/shell/key-bindings.bash

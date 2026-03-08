# Completion
autoload -Uz compinit && compinit

# Zsh functions
fpath=($ZSHFN_PATH $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/sudo/sudo.plugin.zsh
source ~/.zsh/plugins/dirhistory/dirhistory.plugin.zsh
source $ZSH_GIT_PROMPT_PLUGIN/zshrc.sh

# History - managed by atuin
unset HISTFILE

# Key bindings
bindkey '^U' backward-kill-line
bindkey '^[k' kill-whole-line

git_prompt_info_wrapper() {
	if [[ -d .git ]]; then
		echo $(git_super_status)
	else
		echo $Status
	fi
}

# Aliases
alias gst='git status'
source $SCRIPTS_PATH/aliases.sh
source $SCRIPTS_PATH/aliases-terminal.sh
source $SCRIPTS_PATH/aliases-games.sh
source $SCRIPTS_PATH/aliases-projects.sh

# Tools
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# Atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# NVM
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion

# Ruby gems
PATH="/home/eugene/.local/share/gem/ruby/3.2.0/bin:$PATH"

# SSH
$SCRIPTS_PATH/ssh-init.sh >/dev/null 2>&1

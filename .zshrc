# Completion
autoload -Uz compinit && compinit

# Zsh functions
fpath=($ZSHFN_PATH $fpath)
autoload -Uz $fpath[1]/*(.:t)

# History
HISTFILE=~/.config/zsh/.history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS

# Plugins
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#e9f06d'
source $ZSH_PLUGINS_PATH/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_PLUGINS_PATH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_PLUGINS_PATH/sudo/sudo.plugin.zsh
source $ZSH_PLUGINS_PATH/dirhistory/dirhistory.plugin.zsh
source $ZSH_GIT_PROMPT_PLUGIN/zshrc.sh

git_prompt_info_wrapper() {
	if [[ -d .git ]]; then
		echo $(git_super_status)
	else
		echo $Status
	fi
}

PROMPT='%B%~%b$(git_prompt_info_wrapper) '

# Aliases
alias gst='git status'
source $SCRIPTS_PATH/aliases.sh
source $SCRIPTS_PATH/aliases-terminal.sh
source $SCRIPTS_PATH/aliases-games.sh
source $SCRIPTS_PATH/aliases-projects.sh

# Tools
source <(fzf --zsh)
eval "$(zoxide init zsh)"

# Prefix-based history search on up/down arrows
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"

# NVM
[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion

# Ruby gems
PATH="/home/eugene/.local/share/gem/ruby/3.2.0/bin:$PATH"

# SSH
source $SCRIPTS_PATH/ssh-init.sh >/dev/null 2>&1

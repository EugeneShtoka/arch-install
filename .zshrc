# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ssh-agent zsh-autosuggestions zsh-syntax-highlighting sudo dirhistory z)

source $ZSH/oh-my-zsh.sh

# Configure zsh-syntax-highlighting to recognize aliases
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=green'

source $ZSH_GIT_PROMPT_PLUGIN/zshrc.sh
source $SCRIPTS_PATH/aliases-terminal.sh
source $SCRIPTS_PATH/aliases.sh
source <(fzf --zsh)

# Do not show git status for non-git folders
git_prompt_info_wrapper() {
    if [[ -d .git ]]; then
        echo $(git_super_status)
    else
        echo $Status
    fi
}

PROMPT='%B%~%b$(git_prompt_info_wrapper) '

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Reload zsh functions. Uncomment, when adding at least one
#fpath=($ZSHFN_PATH $fpath);
#autoload -Uz $fpath[1]/*(.:t);

$SCRIPTS_PATH/ssh-init.sh >/dev/null 2>&1
#$SCRIPTS_PATH/status-show.sh

# Dedup history
sed ':start; /\\$/ { N; s/\\\n/\\\x00/; b start }' $HOME/.zsh_history | nl -nrz | tac | sort -t';' -u -k2 | sort | cut -d$'\t' -f2- | tr '\000' '\n' >$HOME/.zsh_history_deduped && mv $HOME/.zsh_history_deduped $HOME/.zsh_history

. "$HOME/.atuin/bin/env"

PATH="/home/eugene/.local/share/gem/ruby/3.2.0/bin:$PATH"
eval "$(atuin init zsh --disable-up-arrow)"

[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion

bindkey '^U' backward-kill-line
bindkey '^[k' kill-whole-line

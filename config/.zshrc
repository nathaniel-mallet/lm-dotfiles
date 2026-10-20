# Oh My Zsh - loaded first so the settings below override its defaults.
# No theme, since Starship draws the prompt.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS

# Start Starship prompt
eval "$(starship init zsh)"

# Aliases
source ~/.zsh/aliases.sh

# Functions
source ~/.zsh/functions.sh

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# NeoVim
export PATH="$PATH:/opt/nvim/bin"

# Chruby
source /usr/local/share/chruby/chruby.sh

# Go
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin

# opencode
export PATH="$HOME/.opencode/bin:$PATH"


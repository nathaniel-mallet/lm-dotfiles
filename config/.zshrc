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
export PATH="$PATH:/opt/nvim/"

# Chruby
source /usr/local/share/chruby/chruby.sh

# Go
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin


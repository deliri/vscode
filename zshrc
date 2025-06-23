# ~/.zshrc - Deliri's All-Purpose Shell Swiss Army Knife
# For sanity, speed, and the occasional witty remark.

# =========================
# Table of Contents
# 1. Helpers
# 2. Environment Variables
# 3. PATH Management
# 4. File Sourcing
# 5. Prompt and Appearance
# 6. Plugins
# 7. Aliases (Git, Build, Utility, File Mgmt, Editor, etc.)
# 8. Note-Taking Function
# 9. Default Working Directory
# =========================

############################
# 1. Helpers
############################

# Safe source: Only source if file exists and is non-empty
safesource() { [ -s "$1" ] && source "$1"; }

# Add to PATH once, at the front
add_to_path_once() {
  case ":$PATH:" in
    *":$1:"*) ;;  # Already present
    *) export PATH="$1:$PATH" ;;
  esac
}

############################
# 2. Environment Variables
############################

export LANG=en_US.UTF-8
export NVM_DIR="$HOME/.nvm"
export GOPRIVATE=github.com/deliri/*,github.com/moonlitstudio/*,github.com/IPPorganization/*
export LS_COLORS="sh=01;96:json=01;95:js=01;93:css=01;94:go=01;92:html=01;91:yaml=01;97:txt=01;90:di=01;94"

# Node, Bun, Rust, Go, pnpm
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

############################
# 3. PATH Management
############################

add_to_path_once "$HOME/.cargo/bin"
add_to_path_once "/usr/local/go/bin"
add_to_path_once "$HOME/go/bin"
add_to_path_once "$BUN_INSTALL/bin"
add_to_path_once "$PNPM_HOME"

############################
# 4. File Sourcing
############################

# Google Cloud SDK
safesource "$HOME/google-cloud-sdk/path.zsh.inc"
safesource "$HOME/google-cloud-sdk/completion.zsh.inc"

# Environment managers
safesource "$HOME/.config/envman/load.sh"
safesource "$HOME/.deno/env"
safesource "$NVM_DIR/nvm.sh"
safesource "/Users/d/.bun/_bun"
safesource "${HOME}/.iterm2_shell_integration.zsh"

############################
# 5. Prompt and Appearance
############################

# Terminal Prompt: Pick your poison (comment out one to avoid prompt-ception)
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh)"
fi
eval "$(starship init zsh)"

############################
# 6. Plugins
############################

# Oh My Zsh plugins (does nothing if not using Oh My Zsh)
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

############################
# 7. Aliases
############################

## --- Git Aliases ---
alias ga='git add .'                    # git add all
alias gc='git commit -m'                # git commit with message
alias gp='git push'                     # git push

## --- Package Manager Aliases ---
alias n='npm run dev'                   # npm dev server
alias ncu='npm-check-updates -u'        # update npm dependencies
alias ni='npm install'                  # npm install

alias b='bun run build'                 # bun build
alias bi='bun install'                  # bun install

alias mb='make build'                   # luna go build shortcut

## --- Programming ---
alias g='go run --race main.go'         # run Go with race detection

## --- System Maintenance ---
alias bu='brew update && brew upgrade && brew cleanup' # Homebrew full update
alias bt='btop'                          # System monitor

## --- Utility ---
alias c='clear'                         # Clear terminal
alias s='source ~/.zshrc'               # Reload shell config

## --- File Management ---
alias cat='bat'                         # Enhanced cat
alias l='eza -lh --icons --group-directories-first --color=always --git'         # List with style
alias ltree='eza --tree --level=2 --icons --git'                                # 2-level tree
alias lt='eza --tree --level=2 --long --icons --git'                            # Detailed 2-level tree

## --- Editor ---
alias v='nvim'                          # Neovim quick launch

# (Room for more aliases below!)

############################
# 8. Note-Taking Function
############################

note() {
  local note_dir="$HOME/notes"
  local note_file="$note_dir/drafts.txt"
  mkdir -p "$note_dir"

  if [ -z "$1" ]; then
    echo "Error: No note provided. Try 'note \"Buy milk\"'."
    return 1
  fi

  {
    echo "### Note added on: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "$*"
    echo ""
  } >> "$note_file"

  echo "Note added! See: $note_file"
}

############################
# 9. Default Working Directory (interactive shells only)
############################

if [[ $- == *i* ]]; then
  cd "$HOME/code"
  l
fi

# =========================
# End of ~/.zshrc
# =========================


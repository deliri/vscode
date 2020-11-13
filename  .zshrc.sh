#!/bin/zsh
# uncomment this and the last line for zprof info
# zmodload zsh/zprof

# shortcut to this dotfiles path is $DOTFILES
export DOTFILES="$HOME/.dotfiles"

# your project folder that we can `c [tab]` to
export PROJECTS="$HOME/Code"

# your default editor
export EDITOR='code'
# PATHS
export EDITOR="code -w"
export PATH=$PATH:/Users/d/npm-global/bin
export PATH=$PATH:$HOME/go/bin;
export GOPATH=$HOME/go;
export PATH=$PATH:$GOPATH/bin;
export PATH=$HOME/google-cloud-skd/bin:$PATH;
export PATH=/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH;
# The next line updates PATH for the Google Cloud SDK.
source /Users/d/google-cloud-sdk/path.zsh.inc;

# The next line enables zsh completion for gcloud.
source /Users/d/google-cloud-sdk/completion.zsh.inc;
export PATH=$PATH:$HOME/google-cloud-sdk/platform/google_appengine;
# End PATHS




# all of our zsh files
typeset -U config_files
config_files=($DOTFILES/*/*.zsh)

# load the path files
for file in ${(M)config_files:#*/path.zsh}; do
  source "$file"
done

# load antibody plugins
source ~/.zsh_plugins.sh

# load everything but the path and completion files
for file in ${${config_files:#*/path.zsh}:#*/completion.zsh}; do
  source "$file"
done

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C


# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}; do
  source "$file"
done

unset config_files updated_at

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
# shellcheck disable=SC1090
[ -f ~/.localrc ] && . ~/.localrc

# zprof

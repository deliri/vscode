# install
# brew install zsh
# curl -sL git.io/antibody | sh -s
# chsh -s $(which zsh) to switch to zshell
# antibody bundle zdharma/fast-syntax-highlighting
# antibody bundle zsh-users/zsh-autosuggestions
# antibody bundle zsh-users/zsh-history-substring-search
# antibody bundle zsh-users/zsh-completions
# antibody bundle marzocchi/zsh-notify
# brew install terminal-notifier
# antibody bundle buonomo/yarn-completion


#!/usr/bin/env zsh
export ZSH=$HOME/.oh-my-zsh;
curr="$pm/dotfiles"
export EDITOR="code -w"
export PATH=$PATH:$HOME/go/bin;
export GOPATH=$HOME/go;
export PATH=$PATH:$GOPATH/bin;
# export PATH=$HOME/go_appengine:$PATH;
export PATH=$HOME/google-cloud-skd/bin:$PATH;
export PATH=/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH;
# The next line updates PATH for the Google Cloud SDK.
source /Users/d/google-cloud-sdk/path.zsh.inc;

# The next line enables zsh completion for gcloud.
source /Users/d/google-cloud-sdk/completion.zsh.inc;
export PATH=$PATH:$HOME/google-cloud-sdk/platform/google_appengine;

# Enable autocompletions
autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi
zmodload -i zsh/complist
# Save history so we get auto suggestions
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
# Options
setopt auto_cd # cd by typing directory name if it's not a command
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different instances
setopt correct_all # autocorrect commands
setopt interactive_comments # allow comments in interactive shells
# Improve autocompletion style
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion
# Load antibody plugin manager
source <(antibody init)
# Plugins
antibody bundle zdharma/fast-syntax-highlighting
antibody bundle zsh-users/zsh-autosuggestions
antibody bundle zsh-users/zsh-history-substring-search
antibody bundle zsh-users/zsh-completions
antibody bundle marzocchi/zsh-notify
antibody bundle buonomo/yarn-completion
# Keybindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char
# Theme
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "
# Simplify prompt if we're using Hyper
if [[ "$TERM_PROGRAM" == "Hyper" ]]; then
  SPACESHIP_PROMPT_SEPARATE_LINE=false
  SPACESHIP_DIR_SHOW=false
  SPACESHIP_GIT_BRANCH_SHOW=false
fi
antibody bundle denysdovhan/spaceship-prompt
# Open new tabs in same directory
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  function chpwd {
    printf '\e]7;%s\a' "file://$HOSTNAME${PWD// /%20}"
  }
  chpwd
fi

#!/usr/bin/env zsh

# echo "Load end\t" $(gdate "+%s-%N")

autoload -U colors && colors

# Load and execute the prompt theming system.
fpath=("$curr/terminal" $fpath)
autoload -Uz promptinit && promptinit
prompt 'paulmillr'

# ==================================================================
# = Aliases =
# ==================================================================

alias -g f2='| head -n 2'
alias -g f10='| head -n 10'
alias -g l10='| tail -n 10'
# Simple clear command.
alias cl='clear'

# Disable sertificate check for wget.
alias wget='wget --no-check-certificate'

# Some macOS-only stuff.
if [[ "$OSTYPE" == darwin* ]]; then
  # Short-cuts for copy-paste.
  alias c='pbcopy'
  alias p='pbpaste'

  # Remove all items safely, to Trash (`brew install trash`).
  [[ -z "$commands[trash]" ]] || alias rm='trash' 2>&1 > /dev/null

  # Lock current session and proceed to the login screen.
  alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

  # Sniff network info.
  alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"

  # Developer tools shortcuts.
  alias tower='gittower'
  alias t='gittower'

  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fli'
else
  # Process grep should output full paths to binaries.
  alias pgrep='pgrep -fl'
fi

# Git short-cuts.
alias g='git'
alias ga='git add'
alias gr='git rm'

alias gf='git fetch'
alias gu='git pull'
alias gup='git pull && git push'

alias gs='git status --short'
alias gd='git diff'
alias gdisc='git discard'

function gc() {
  args=$@
  git commit -m "$args"
}
function gca() {
  args=$@
  git commit --amend -m "$args"
}

function cherry() {
  is_range=''
  case "$1" in # `sh`-compatible substring.
    *\.*)
    is_range='1'
  ;;
  esac
  # Check if it's one commit vs set of commits.
  if [ "$#" -eq 1 ] && [[ $is_range ]]; then
    log=$(git rev-list --reverse --topo-order $1 | xargs)
    setopt sh_word_split 2> /dev/null # Ignore for `sh`.
    commits=(${log}) # Convert string to array.
    unsetopt sh_word_split 2> /dev/null # Ignore for `sh`.
  else
    commits=("$@")
  fi

  total=${#commits[@]} # Get last array index.
  echo "Picking $total commits:"
  for commit in ${commits[@]}; do
    echo $commit
    git cherry-pick -n $commit || break
    [[ CC -eq 1 ]] && cherrycc $commit
  done
}

alias gp='git push'

function gcp() {
  title="$@"
  git commit -am $title && git push -u origin
}
alias gcl='git clone'
alias gch='git checkout'
alias gbr='git branch'
alias gbrcl='git checkout --orphan'
alias gbrd='git branch -D'
function gl() {
  count=$1
  [[ -z "$1" ]] && count=10
  git --no-pager log --graph --no-merges --max-count=$count
}

# own git workflow in hy origin with Tower

# ===============
# Dev short-cuts.
# ===============

# Brunch.
alias bb='brunch build'
alias bbp='brunch build --production'
alias bw='brunch w'
alias bws='brunch w --server'

# Package managers.
alias nr='npm run'
alias brewup='brew update && brew upgrade'
alias jk='jekyll serve --watch' # lol jk
# alias serve='python -m SimpleHTTPServer'
alias serve='http-serve' # npm install http-server
alias server='http-serve'

# Ruby.
alias bx='bundle exec'
alias bex='bundle exec'
alias migr='bundle exec rake db:migrate'

# Checks whether connection is up.
alias net="ping google.com | grep -E --only-match --color=never '[0-9\.]+ ms'"

# Pretty print json
alias json='python -m json.tool'

# Lists the ten most used commands.
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

# ==================================================================
# = Functions =
# ==================================================================
# Gets password from macOS Keychain.
# $ get-pass github
function get-pass() {
  keychain="$HOME/Library/Keychains/login.keychain"
  security -q find-generic-password -g -l $@ $keychain 2>&1 |\
    awk -F\" '/password:/ {print $2}';
}

# Opens file in EDITOR.
function edit() {
  local dir=$1
  [[ -z "$dir" ]] && dir='.'
  $EDITOR $dir
}
alias e=edit

# Execute commands for each file in current directory.
function each() {
  for dir in *; do
    # echo "${dir}:"
    cd $dir
    $@
    cd ..
  done
}

# Find files and exec commands at them.
# $ find-exec .coffee cat | wc -l
# # => 9762
function find-exec() {
  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
}

# Better find(1)
function ff() {
  find . -iname "*${1:-}*"
}

# Count code lines in some directory.
# $ loc py js css
# # => Lines of code for .py: 3781
# # => Lines of code for .js: 3354
# # => Lines of code for .css: 2970
# # => Total lines of code: 10105
function loc() {
  local total
  local firstletter
  local ext
  local lines
  total=0
  for ext in $@; do
    firstletter=$(echo $ext | cut -c1-1)
    if [[ firstletter != "." ]]; then
      ext=".$ext"
    fi
    lines=`find-exec "*$ext" cat | wc -l`
    lines=${lines// /}
    total=$(($total + $lines))
    echo "Lines of code for ${fg[blue]}$ext${reset_color}: ${fg[green]}$lines${reset_color}"
  done
  echo "${fg[blue]}Total${reset_color} lines of code: ${fg[green]}$total${reset_color}"
}

# Show how much RAM application uses.
# $ ram safari
# # => safari uses 154.69 MBs of RAM.
function ram() {
  local sum
  local items
  local app="$1"
  if [ -z "$app" ]; then
    echo "First argument - pattern to grep from processes"
  else
    sum=0
    for i in `ps aux | grep -i "$app" | grep -v "grep" | awk '{print $6}'`; do
      sum=$(($i + $sum))
    done
    sum=$(echo "scale=2; $sum / 1024.0" | bc)
    if [[ $sum != "0" ]]; then
      echo "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM."
    else
      echo "There are no processes with pattern '${fg[blue]}${app}${reset_color}' are running."
    fi
  fi
}

# $ size dir1 file2.js
function size() {
  # du -sh "$@" 2>&1 | grep -v '^du:' | sort -nr
  du -shck "$@" | sort -rn | awk '
      function human(x) {
          s="kMGTEPYZ";
          while (x>=1000 && length(s)>1)
              {x/=1024; s=substr(s,2)}
          return int(x+0.5) substr(s,1,1)
      }
      {gsub(/^[0-9]+/, human($1)); print}'
}

# $ git log --no-merges --pretty=format:"%ae" | stats
# # => 514 a@example.com
# # => 200 b@example.com
function stats() {
  sort | uniq -c | sort -r
}

# Shortcut for searching commands history.
# hist git
function hist() {
  history 0 | grep $@
}

# $ aes-enc file.zip
function aes-enc() {
  openssl enc -aes-256-cbc -e -in $1 -out "$1.aes"
}

# $ aes-dec file.zip.aes
function aes-dec() {
  openssl enc -aes-256-cbc -d -in $1 -out "${1%.*}"
}

# Monitor IO in real-time (open files etc).
function openfiles() {
  sudo dtrace -n 'syscall::open*:entry { printf("%s %s",execname,copyinstr(arg0)); }'
}

# 4 lulz.
function compute() {
  while true; do head -n 100 /dev/urandom; sleep 0.1; done \
    | hexdump -C | grep "ca fe"
}

# Load 8 cores at once.
function maxcpu() {
  dn=/dev/null
  yes > $dn & yes > $dn & yes > $dn & yes > $dn &
  yes > $dn & yes > $dn & yes > $dn & yes > $dn &
}

# $ retry ping google.com
function retry() {
  echo Retrying "$@"
  $@
  sleep 1
  retry $@
}

# install in /etc/zsh/zshrc or your personal .zshrc

# gc
prefixes=(5 6 8)
for p in $prefixes; do
	compctl -g "*.${p}" ${p}l
	compctl -g "*.go" ${p}g
done

# standard go tools
compctl -g "*.go" gofmt

# gccgo
compctl -g "*.go" gccgo

# go tool
__go_tool_complete() {
  typeset -a commands build_flags
  commands+=(
    'build[compile packages and dependencies]'
    'clean[remove object files]'
    'doc[run godoc on package sources]'
    'env[print Go environment information]'
    'fix[run go tool fix on packages]'
    'fmt[run gofmt on package sources]'
    'generate[generate Go files by processing source]'
    'get[download and install packages and dependencies]'
    'help[display help]'
    'install[compile and install packages and dependencies]'
    'list[list packages]'
    'run[compile and run Go program]'
    'test[test packages]'
    'tool[run specified go tool]'
    'version[print Go version]'
    'vet[run go tool vet on packages]'
  )
  if (( CURRENT == 2 )); then
    # explain go commands
    _values 'go tool commands' ${commands[@]}
    return
  fi
  build_flags=(
    '-a[force reinstallation of packages that are already up-to-date]'
    '-n[print the commands but do not run them]'
    '-p[number of parallel builds]:number'
    '-race[enable data race detection]'
    '-x[print the commands]'
    '-work[print temporary directory name and keep it]'
    '-ccflags[flags for 5c/6c/8c]:flags'
    '-gcflags[flags for 5g/6g/8g]:flags'
    '-ldflags[flags for 5l/6l/8l]:flags'
    '-gccgoflags[flags for gccgo]:flags'
    '-compiler[name of compiler to use]:name'
    '-installsuffix[suffix to add to package directory]:suffix'
    '-tags[list of build tags to consider satisfied]:tags'
  )
  __go_packages() {
      local gopaths
      declare -a gopaths
      gopaths=("${(s/:/)$(go env GOPATH)}")
      gopaths+=("$(go env GOROOT)")
      for p in $gopaths; do
        _path_files -W "$p/src" -/
      done
  }
  __go_identifiers() {
      compadd $(godoc -templates $ZSH/plugins/golang/templates ${words[-2]} 2> /dev/null)
  }
  case ${words[2]} in
  doc)
    _arguments -s -w \
      "-c[symbol matching honors case (paths not affected)]" \
      "-cmd[show symbols with package docs even if package is a command]" \
      "-u[show unexported symbols as well as exported]" \
      "2:importpaths:__go_packages" \
      ":next identifiers:__go_identifiers"
      ;;
  clean)
    _arguments -s -w \
      "-i[remove the corresponding installed archive or binary (what 'go install' would create)]" \
      "-n[print the remove commands it would execute, but not run them]" \
      "-r[apply recursively to all the dependencies of the packages named by the import paths]" \
      "-x[print remove commands as it executes them]" \
      "*:importpaths:__go_packages"
      ;;
  fix|fmt|list|vet)
      _alternative ':importpaths:__go_packages' ':files:_path_files -g "*.go"'
      ;;
  install)
      _arguments -s -w : ${build_flags[@]} \
        "-v[show package names]" \
        '*:importpaths:__go_packages'
      ;;
  get)
      _arguments -s -w : \
        ${build_flags[@]}
      ;;
  build)
      _arguments -s -w : \
        ${build_flags[@]} \
        "-v[show package names]" \
        "-o[output file]:file:_files" \
        "*:args:{ _alternative ':importpaths:__go_packages' ':files:_path_files -g \"*.go\"' }"
      ;;
  test)
      _arguments -s -w : \
        ${build_flags[@]} \
        "-c[do not run, compile the test binary]" \
        "-i[do not run, install dependencies]" \
        "-v[print test output]" \
        "-x[print the commands]" \
        "-short[use short mode]" \
        "-parallel[number of parallel tests]:number" \
        "-cpu[values of GOMAXPROCS to use]:number list" \
        "-run[run tests and examples matching regexp]:regexp" \
        "-bench[run benchmarks matching regexp]:regexp" \
        "-benchmem[print memory allocation stats]" \
        "-benchtime[run each benchmark until taking this long]:duration" \
        "-blockprofile[write goroutine blocking profile to file]:file" \
        "-blockprofilerate[set sampling rate of goroutine blocking profile]:number" \
        "-timeout[kill test after that duration]:duration" \
        "-cpuprofile[write CPU profile to file]:file:_files" \
        "-memprofile[write heap profile to file]:file:_files" \
        "-memprofilerate[set heap profiling rate]:number" \
        "*:args:{ _alternative ':importpaths:__go_packages' ':files:_path_files -g \"*.go\"' }"
      ;;
  help)
      _values "${commands[@]}" \
        'gopath[GOPATH environment variable]' \
        'packages[description of package lists]' \
        'remote[remote import path syntax]' \
        'testflag[description of testing flags]' \
        'testfunc[description of testing functions]'
      ;;
  run)
      _arguments -s -w : \
          ${build_flags[@]} \
          '*:file:_files -g "*.go"'
      ;;
  tool)
      if (( CURRENT == 3 )); then
          _values "go tool" $(go tool)
          return
      fi
      case ${words[3]} in
      [568]g)
          _arguments -s -w : \
              '-I[search for packages in DIR]:includes:_path_files -/' \
              '-L[show full path in file:line prints]' \
              '-S[print the assembly language]' \
              '-V[print the compiler version]' \
              '-e[no limit on number of errors printed]' \
              '-h[panic on an error]' \
              '-l[disable inlining]' \
              '-m[print optimization decisions]' \
              '-o[file specify output file]:file' \
              '-p[assumed import path for this code]:importpath' \
              '-u[disable package unsafe]' \
              "*:file:_files -g '*.go'"
          ;;
      [568]l)
          local O=${words[3]%l}
          _arguments -s -w : \
              '-o[file specify output file]:file' \
              '-L[search for packages in DIR]:includes:_path_files -/' \
              "*:file:_files -g '*.[ao$O]'"
          ;;
      dist)
          _values "dist tool" banner bootstrap clean env install version
          ;;
      *)
          # use files by default
          _files
          ;;
      esac
      ;;
  esac
}

compdef __go_tool_complete go

# aliases: go<~>
alias gob='go build'
alias goc='go clean'
alias god='go doc'
alias gof='go fmt'
alias gofa='go fmt ./...'
alias gog='go get'
alias goi='go install'
alias gol='go list'
alias gop='cd $GOPATH'
alias gopb='cd $GOPATH/bin'
alias gops='cd $GOPATH/src'
alias gor='go run'
alias got='go test'
alias gov='go vet'
alias gg="go get -u -v "
alias gcsc="gcloud config set project"
alias gcad="gcloud app deploy"
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias cdg="cd go/src/github.com/deliri"


_buffalo() {
	local line

	cmds="((build\:'Builds a Buffalo binary, including bundling of assets (packr & webpack)'
		db\:'A tasty treat for all your database needs'
		destroy\:'Allows to destroy generated code.'
		dev\:'Runs your Buffalo app in development mode'
		generate\:'A collection of generators to make life easier'
		help\:'Help about any command'
		info\:'Prints off diagnostic information useful for debugging'
		new\:'Creates new Buffalo application'
		routes\:'Print out all defined routes'
		setup\:'Setups a newly created, or recently checked out application.'
		task\:'Runs your grift tasks'
		test\:'Runs the tests for your Buffalo app'
		update\:'will attempt to upgrade a Buffalo application to newer version'
		version\:'Print the version number of buffalo'))"
	_arguments -C \
		{-h,--help}"[help for buffalo]"\
		"1:command:$cmds"\
		"*::arg:->args"

	case $line[1] in
		b|bill|build)
			_buffalo_build
			;;
		db)
			_buffalo_db
			;;
		d|destroy)
			_buffalo_destroy
			;;
		dev)
			_buffalo_dev
			;;
		g|generate)
			_buffalo_generate
			;;
		help)
			_buffalo_help
			;;
		new)
			_buffalo_new
			;;
	esac
}

_buffalo_build() {
	_arguments \
		{-c,--compress}"[compress static files in the binrary (default true)]"\
		{--debug,-d}"[print debugging informantion]"\
		"--environment=[set the environment for the binary (default development)]:string:( )"\
		{-e,--extract-assets}"[extract the assets and put them in a distinct archive]"\
		{-h,--help}"[help for build]"\
		"--ldflags=[set any ldflags to be passed to the go build]:string:( )"\
		{-o=,--output=}"[set the name of the binary]"\
		{-k,--skip-assets}"[skip running webpack and building assets]:string:( )"\
		"--skip-template-validation[skip validating plush templates]"\
		{-s,--static}"[build a static binary using --ldflags '-linkmode external -extldflags \\\"-static\\\"']"\
		{-t=,--tags=}"[compile with specific build tags]:string:( )"
}

_buffalo_db() {
	local line

	cmds="((create\:'Creates database for you'
		destroy\:'Allows to destroy generated code'
		drop\:'Drop database for you'
		generate\:''
		migrate\:'Runs migrations against your database'
		schema\:'Tools for working with your database scheam'))"
	_arguments -C \
		"1:command:$cmds"\
		{-c=,--config=}"[The configuration file you would like to use]:string"\
		{-d,--debug}"[Use debug/verbose mode]"\
		{-e=,--env=}"[]:string"\
		{-h,--help}"[help for db]"\
		{-p=,--path=}"[Path to the migrations folder (default \\\"./migrations\\\")]:string"\
		{-v,--version}"[Show version information]"
		"*::arg:->args"

	case $line[1] in
	esac

}

_buffalo_destroy() {
}

_buffalo_dev() {
}

_buffalo_generate() {
	local line

	cmds="((action\:'Generates new action(s)'
		docker\:'Generates a Dockerfile'
		mailer\:'Generates a new mailer for Buffalo'
		resource\:'Generates a new action/resource file'
		task\:'Generates a grift task'))"
	_arguments -C \
		"1:command:$cmds"\
		"*::arg:->args"

	case $line[1] in
		a|action|actions)
			_buffalo_generate_action
			;;
	esac

}

_buffalo_generate_action() {
	_arguments \
		"-h[help for action]"\
		"-m[change the HTTP method for the generate action(s) (default GET)]"\
		"--skip-template[skip generation of templates for action(s)]"
		"1:name"\
		"*:handler name..."
}


_buffalo_help() {
	_arguments \
		"1:command:(build db destroy dev generate help info new routes setup task test update version)"
}

_buffalo_new() {
	_arguments \
		"1:name:( )"\
		"--api[skip all front-end code and configure for an API server]"\
		"--bootstrap[specify version for Bootstrap \\[3, 4\\] (default 3)]"\
		"--ci-provider[specify the type of ci file you would like buffalo to generate \\[none, travis, gitlab-ci\\] (default none)]"\
		"--db-type[specify the type of database you want to use \\[postgres, mysql, cockroach\\] (default postgres)]"\
		"--docker[specify the type of Docker file to generate \\[none, multi, standard\\] (default multi)]"\
		{-f,--force}"[delete and remake if the app already exists]"\
		{-h,--help}"[help for new]"\
		"--skip-pop[skips adding pop/soda to your app]"\
		"--skip-webpack[skips adding Webpack to your app]"\
		"--skip-yarn[use npm instead of yarn for frontend dependencies management]"\
		"--vcs[specify the Version control system you would like to use \\[none, git, bzr\\] (default git)]"\
		{-v,--verbose}"[verbosely print out the go get commands]"\
		"--with-dep[adds github.com/golang/dep to your dep]"
}

compdef _buffalo buffalo


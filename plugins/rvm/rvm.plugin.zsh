# Completion
fpath+=("${rvm_path}/scripts/zsh/Completion")

typeset -g -A _comps
autoload -Uz _rvm
_comps[rvm]=_rvm

# Aliases
alias rubies='rvm list rubies'
alias rvms='rvm gemset'
alias gemsets='rvms list'


# rb{version} utilities
# From `rvm list known`
typeset -A rubies
rubies=(
  18  'ruby-1.8.7'
  19  'ruby-1.9.3'
  20  'ruby-2.0.0'
  21  'ruby-2.1'
  22  'ruby-2.2'
  23  'ruby-2.3'
  24  'ruby-2.4'
  25  'ruby-2.5'
  26  'ruby-2.6'
  27  'ruby-2.7'
  30  'ruby-3.0'
  31  'ruby-3.1'
  32  'ruby-3.2'
)

for v in ${(k)rubies}; do
  version="${rubies[$v]}"
  functions[rb${v}]="rvm use ${version}\${1+"@\$1"}"
  functions[_rb${v}]="compadd \$(ls -1 \"\${rvm_path}/gems\" | grep '^${version}@' | sed -e 's/^${version}@//' | awk '{print $1}')"
  compdef _rb$v rb$v
done
unset rubies v version


function rb20 {
	if [ -z "$1" ]; then
		rvm use "$ruby20"
	else
		rvm use "$ruby20@$1"
	fi
}

_rb20() {compadd `ls -1 $rvm_path/gems | grep "^$ruby20@" | sed -e "s/^$ruby20@//" | awk '{print $1}'`}
compdef _rb20 rb20

function rb21 {
	if [ -z "$1" ]; then
		rvm use "$ruby21"
	else
		rvm use "$ruby21@$1"
	fi
}

_rb21() {compadd `ls -1 $rvm_path/gems | grep "^$ruby21@" | sed -e "s/^$ruby21@//" | awk '{print $1}'`}
compdef _rb21 rb21

function rb25 {
	if [ -z "$1" ]; then
		rvm use "$ruby25"
	else
		rvm use "$ruby25@$1"
	fi
}

_rb25() {compadd `ls -1 $rvm_path/gems | grep "^$ruby25@" | sed -e "s/^$ruby25@//" | awk '{print $1}'`}
compdef _rb25 rb25

function rb26 {
	if [ -z "$1" ]; then
		rvm use "$ruby26"
	else
		rvm use "$ruby26@$1"
	fi
}

_rb26() {compadd `ls -1 $rvm_path/gems | grep "^$ruby26@" | sed -e "s/^$ruby26@//" | awk '{print $1}'`}
compdef _rb26 rb26

function rb27 {
	if [ -z "$1" ]; then
		rvm use "$ruby27"
	else
		rvm use "$ruby27@$1"
	fi
}

_rb27() {compadd `ls -1 $rvm_path/gems | grep "^$ruby27@" | sed -e "s/^$ruby27@//" | awk '{print $1}'`}
compdef _rb27 rb27

function rb30 {
	if [ -z "$1" ]; then
		rvm use "$ruby30"
	else
		rvm use "$ruby30@$1"
	fi
}

_rb30() {compadd `ls -1 $rvm_path/gems | grep "^$ruby30@" | sed -e "s/^$ruby30@//" | awk '{print $1}'`}
compdef _rb30 rb30

function rvm-update {
  rvm get head
}

# TODO: Make this usable w/o rvm.
function gems {
  local current_ruby=`rvm-prompt i v p`
  local current_gemset=`rvm-prompt g`

  gem list $@ | sed -E \
    -e "s/\([0-9, \.]+( .+)?\)/$fg[blue]&$reset_color/g" \
    -e "s|$(echo $rvm_path)|$fg[magenta]\$rvm_path$reset_color|g" \
    -e "s/$current_ruby@global/$fg[yellow]&$reset_color/g" \
    -e "s/$current_ruby$current_gemset$/$fg[green]&$reset_color/g"
}

# TODO: Make this usable w/o rvm.
function gems {
  local current_ruby=`rvm-prompt i v p`
  local current_gemset=`rvm-prompt g`

  gem list $@ | sed -E \
    -e "s/\([0-9, \.]+( .+)?\)/$fg[blue]&$reset_color/g" \
    -e "s|$(echo $rvm_path)|$fg[magenta]\$rvm_path$reset_color|g" \
    -e "s/$current_ruby@global/$fg[yellow]&$reset_color/g" \
    -e "s/$current_ruby$current_gemset$/$fg[green]&$reset_color/g"
}

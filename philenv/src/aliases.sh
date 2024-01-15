#!/bin/sh
########################################################################################################################
# Aliases concernant des commandes existantes :
########################################################################################################################

alias l="ls -lh --group-directories-first --color=tty"
alias ll="l"
alias ltr="l -tr"
alias la="l -A"

alias head="head -n50"

alias tree="tree -A -C -N --dirsfirst"
alias tt="tree"
alias t="tt"
alias t1="t -L 1"
alias t2="t -L 2"
alias t3="t -L 3"
alias t4="t -L 4"
alias t5="t -L 5"

alias caly='cal "$(date +%Y)"'
alias calw='ncal -w'
alias calyw='ncal -w "$(date +%Y)"'
alias calwy=calyw

alias d="detach"
alias dn="detach_no_exit"

alias h="history 25"
alias grep="grep --color=auto"


# Protections contre les mauvaises manip en root :
if [ "$(whoami)" = root ]
then
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
fi


# Affichage de mon IP :
alias myip="curl http://wtfismyip.com/text"

alias dco="docker-compose"
# alias myclangformat="clang-format -style=\"{BasedOnStyle: Chromium, IndentWidth: 4, ColumnLimit: 100, SortIncludes: false}\""

# gs lance ghostscript, que je n'utilise strictement jamais
# quand je tape "gs", c'est que je me suis gouré et que je voulais taper gst :
alias gs=gst

########################################################################################################################
# Aliases de navigation indépendants de la machine considérée :
########################################################################################################################

alias rego='cd $(pwd -P)'

# Remontée/descente dans les répertoires :
PHILENV_current_b_commandname="b"
PHILENV_current_b_dir=".."
PHILENV_current_f_commandname="f"
PHILENV_base_f_command="popd &> /dev/null"
PHILENV_current_f_command="${PHILENV_base_f_command}"

# Boucles définissant les commandes utiles :
for i in {1..8}
do
    # Back :
    eval "alias ${PHILENV_current_b_commandname}=\"pushd ${PHILENV_current_b_dir} &> /dev/null\""
    eval "alias b${i}=\"pushd ${PHILENV_current_b_dir} &> /dev/null\""

    # Forward :
    eval "alias ${PHILENV_current_f_commandname}=\"${PHILENV_current_f_command}\""
    eval "alias f${i}=\"${PHILENV_current_f_command}\""

    # On met à jour les variables :
    PHILENV_current_b_commandname="${PHILENV_current_b_commandname}b"
    PHILENV_current_f_commandname="${PHILENV_current_f_commandname}f"
    PHILENV_current_b_dir="${PHILENV_current_b_dir}/.."
    PHILENV_current_f_command="${PHILENV_current_f_command} ; ${PHILENV_base_f_command}"
done

########################################################################################################################
# Fin du fichier.
########################################################################################################################

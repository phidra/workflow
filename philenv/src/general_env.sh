#!/bin/sh
########################################################################################################################
#
# Fichier de personnalisation de l'environnement.
#
########################################################################################################################


########################################################################################################################
# Fonction d'ajout de chemin au path / pythonpath :
########################################################################################################################
type addPath &> /dev/null || function addPath ()
{
    [ -z "$1" ] && return;
    [ ! -d "$1" ] && return;
    added_path="PATH";
    [ "$2" != "" ] && added_path="$2";
    if pushd "$1" &>/dev/null; then
        local path_to_add="$(pwd)";
        popd &>/dev/null;
        local test_path_command='if echo ":${';
        test_path_command+="${added_path}";
        test_path_command+='}:" | grep -v -q ":${path_to_add}:"; then export ';
        test_path_command+="${added_path}";
        test_path_command+='="${path_to_add}:${';
        test_path_command+="${added_path}";
        test_path_command+='}"; fi';
        eval ${test_path_command};
    fi
}

# Chemins utiles :
addPath "/usr/bin"
addPath "/sbin"
local_bin_dir="${HOME}/.local/bin"
[ -d "${local_bin_dir}" ] && addPath "${local_bin_dir}"

########################################################################################################################
# Autres configuration d'environnement général :
########################################################################################################################

# Taille max des coredumps :
ulimit -c unlimited

# Longueur et format de date de l'historique bash :
export HISTSIZE=3000      # cf. man bash, le nombre de commandes max de la session courante à transférer dans l'historique
export HISTFILESIZE=15000  # cf. man bash, le nombre de ligne max de l'historique
[ "${HISTTIMEFORMAT}" = "" ] && export HISTTIMEFORMAT="[%d %h %H:%M:%S] "


# Durcissement du umask par défaut, pour tout le monde sauf root (sinon personne ne peut utiliser ce que peut installer root) :
if [ "$(whoami)" = root ]
then
    umask 0022
else
    umask 0027
fi

# modif début 2023 = annuler le GIT_PAGER pour autoriser diff-so-fancy :
# export GIT_PAGER=cat
unset GIT_PAGER

[ -e "/usr/lib/ccache" ] && export PATH="/usr/lib/ccache:$PATH"
[ -e "~/git-subrepo/.rc" ] && source ~/git-subrepo/.rc

########################################################################################################################
# Fin du fichier.
########################################################################################################################

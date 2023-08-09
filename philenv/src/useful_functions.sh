#!/bin/sh
#
# Mes fonctions utiles pour mon environnement.
#

# OBJET : Recherche un fichier en fonction d'un pattern, de façon insensible à la casse.
# INPUT1 = pattern à chercher
# En cas d'argument manquant, sort en erreur.
function mamie_voyante()
{
    [ "$1" = "" ] && echo "Erreur, pattern à rechercher manquant !" && return
    local pattern="${1}"
    find . -iname "*${pattern}*"|egrep -v "\.hg|\.swp$|[^t]_build"
}
# Le même, mais sensible à la casse :
function mamie_voyante_sensitive()
{
    [ "$1" = "" ] && echo "Erreur, pattern à rechercher manquant !" && return
    local pattern="${1}"
    find . -name "*${pattern}*"|egrep -v "\.hg|\.swp$|[^t]_build"

}


# OBJET : Lance une commande détachée du terminal, qui survivra lorsqu'on fermera le terminal.
# (ça évite de devoir laisser le terminal qui a servi à lancer la commande ouvert).
# INPUT1 = commande à lancer.
# En cas d'argument manquant, sort en erreur.
function detach_no_exit()
{
    [ "$1" = "" ] && echo "Erreur, commande à lancer manquante !" && return
    nohup $@& &> /dev/null
    sleep 1
    rm -f nohup.out &> /dev/null
}

# OBJET : Lance une commande détachée du terminal, et ferme celui-ci.
# INPUT1 = commande à lancer.
# En cas d'argument manquant, sort en erreur.
function detach()
{
    # Par rapport à no exit, il faut valider que la commande existe avant de fermer :
    type "$1" &> /dev/null
    [ $? != 0 ] && echo "Erreur, commande \"$1\" inconnue !" && return

    detach_no_exit "$@"
    sleep 1
    exit
}


# OBJET : recherche récursivement et détruit les fichiers correspondant au pattern. Indique le nombre de fichiers détruits.
function delfile()
{
    local pattern="${1}"
    [ "${pattern}" = "" ] && echo "Pattern des fichiers à supprimer manquant !" && return 1
    local number_of_deleted_files=$(find . -name "${pattern}"|wc -l)
    [ "${number_of_deleted_files}" = "" ] && number_of_deleted_files="0"
    echo "Suppression de ${number_of_deleted_files} fichier(s) ${pattern}."
    find . -name "${pattern}" -exec rm {} \;

}
alias delpyc='delfile "*\.pyc"'
alias deltilde='delfile "*~"'
alias delswp='delfile "*\.swp"'


# OBJET : remplace magiquement une chaîne par une autre dans les fichiers de l'arborescence actuelle.
# INPUT1 = chaîne à rechercher.
# INPUT2 = chaîne de remplacement.
# En cas d'argument manquant, sort en erreur.
function harry_potter()
{
    [ "$3" != "" ] && echo "ERROR - too many arguments..." && return
    local chaine_a_chercher="$1"
    local chaine_de_remplacement="$2"

    old_IFS="${IFS}"
    export IFS=$'\n'

    harry_potter_tmpdir="/tmp/harry_potter"
    [ ! -d "${harry_potter_tmpdir}" ] && mkdir "${harry_potter_tmpdir}"


    # Recherche de la chaîne :
    for corresponding_file in $(grep -IRl "${chaine_a_chercher}" .|grep -v "~$")
    do
        if [ -w "${corresponding_file}" ]
        then
            # On "sauvegarde" les permissions et propriétaires du fichier :
            permission_and_ownership_saver="$(mktemp)"
            chown --reference="${corresponding_file}" "${permission_and_ownership_saver}"
            chmod --reference="${corresponding_file}" "${permission_and_ownership_saver}"

            # On copie le fichier (pour travailler tranquillement dessus, et ne modifier l'original de la façon la plus ACID possible) :
            corresponding_file_copy="$(mktemp)"
            cp "${corresponding_file}" "${corresponding_file_copy}"


            # On effectue la transformation dans un buffer, auquel on donne les permissions du fichier original :
            buffer="$(mktemp)"
            sed -e s@"${chaine_a_chercher}"@"${chaine_de_remplacement}"@g "${corresponding_file_copy}" > "${buffer}"
            chown --reference="${permission_and_ownership_saver}" "${buffer}"
            chmod --reference="${permission_and_ownership_saver}" "${buffer}"

            # On remplace le fichier de la façon la plus ACID possible, tout en sauvegardant le fichier original :
            saved=$(mktemp --suffix="_harry_potter" --tmpdir="${harry_potter_tmpdir}")
            mv "${corresponding_file}" "${saved}"
            mv "${buffer}" "${corresponding_file}"

            echo "Just replaced \"${chaine_a_chercher}\" by \"${chaine_de_remplacement}\" in \"${corresponding_file}\" (orig saved in \"${saved}\")"


            # On fait le ménage car on est propres (mais on ne supprime pas la sauvegarde) :
            rm -f "${buffer}" "${permission_and_ownership_saver}" "${corresponding_file_copy}"
        else
            echo "ERROR - No access to \"${corresponding_file}\" !"
        fi
    done

    export IFS="${old_IFS}"
}


# OBJET : créé un répertoire et s'y rend.
function mkg()
{
    [ "$1" = "" ] && echo "ERREUR - répertoire à créer manquant !"
    mkdir "$1"
    cd "$1"
}



# OBJET : calcule le hash md5 du répertoire passé en argument.
# INPUTS = répertoires dont on calcule les hashs
# En cas d'argument manquant, sort en erreur.
function dirhash_internal_function()
{
    [ "$1" = "" ] && echo "ERREUR - argument manquant = répertoire dont on veut calculer le hash !"
    for i in "$@"
    do
        echo -n -e "${i%\/}\t\t"
        pushd "${i}" 1> /dev/null
        md5content=$(find . -type f -print0 | sort -z | xargs -0 cat | md5sum)
        md5files=$(find . -type f -print0 | sort -z | md5sum) # on intègre les chemins des fichiers au hash
        popd 1> /dev/null
        echo "${md5content}${md5files}" | md5sum
    done
}
function dirhash()
{
    dirhash_internal_function "$@" | column -t
}



# OBJET : changer la priorité du shell courant pour le rendre moins consommateur
# INPUTS = la niceness CPU (si non-précisé : 19 = le moins prioritaire)
function nini()
{
    local niceness=19
    [ "$1" != "" ] && niceness="$1"

    # Diminution de la priorité IO :
    ionice -c3 -p $$

    # Diminution de la niceness :
    renice -n "${niceness}" $$
}



# OBJET : écriture régulière d'un heartbeat sur la sortie standard, pour maintenir en vie une connexion SSH.
# INPUT (facultatif) = le nombre de secondes entre les heartbeats (défaut = 600 secondes = 10 minutes)
function heartbeat_ssh()
{
    # Temps entre les heartbeats :
    local default_sleep_in_s=600
    local sleep_in_s="${default_sleep_in_s}"
    [ "$1" != "" ] && sleep_in_s=$1


    # On boucle :
    while true
    do
        echo "HEARTBEAT every "${sleep_in_s}"s (if you want to kill me, here is my PID : $$)  --  $(date)"
        sleep "${sleep_in_s}"

        # Si le sleep foire, on sort en erreur :
        sleep_returncode="$?"
        [ "${sleep_returncode}" != "0" ] && echo "ERROR - non-zero sleep returncode : ${sleep_returncode}" && return ${sleep_returncode}

    done
}


# OBJET : créer une session vierge avec 3 windows : EDIT, TERMINAL et TERMINALBIS
# INPUT (facultatif) : le nom de la session
function tmux-smart-new-session()
{
    [ -z "$1" ] && echo "ERROR - missing session name..." && return
    local SESSION_NAME="$1"

    # exiting early if already in tmux session :
    [ ! -z "${TMUX}" ] && echo "Nope, already in TMUX session :  $(tmux display-message -p '#S')" && return 10

    # already is an existing session with same name :
    tmux has-session -t "$SESSION_NAME" &> /dev/null && echo "Nope, already existing TMUX session with name :  ${SESSION_NAME}" && return 20

    # creating session :
    tmux new-session -d -s "$SESSION_NAME" || return 40

    # setting windows :
    tmux rename-window -t "$SESSION_NAME:0" "EDIT"
    tmux new-window -t "$SESSION_NAME:1" -n "TERMINAL"
    tmux new-window -t "$SESSION_NAME:2" -n "TERMINALBIS"

    tmux attach-session -t "$SESSION_NAME:0"
}
alias tnew="tmux-smart-new-session"


# Cette fonction ne fonctionne que si on lui passe le répertoire racine des projets git en argument.
# Elle a vocation à être utilisée par une fonction de plus haut-niveau qui lui sette son argument
#     function gogit { gogit_base "/path/to/projects/github/" }
# (en effet, gogit est machine-dependant)
function gogit_base
{
    local gitprojects="$1"
    if ! fzf --version &> /dev/null
    then
        echo "ERROR : can't execute fzf gogit : missing fzf. Falling back to 'cd'"
        cd "${gitprojects}"
        return
    fi

    # see : https://seb.jambor.dev/posts/improving-shell-workflows-with-fzf/
    cd "$gitprojects/$(ls "$gitprojects" | fzf)"
}


cheatsheet()
{
    cat << EOF

Pour afficher cette cheatsheet :   help  /  cheatsheet  /  cheat

======= MES ALIAS PERSOS  (cf. /opt/philenv.d/) :
    mkg               mkdir + cd
    dirhash           md5sum de tout un répertoire
    mamie_voyante     recherche de fichiers par nom (mamie_voyante_sensitive = sensible à la casse)
    harry_potter      remplacement de chaîne dans l'arborescence actuelle
    nini              minimiser la niceness + io-niceness du terminal courant
    heartbeat_ssh     echo toutes les 10 minutes (pour maintenir artificiellement une connexion SSH)
    tnew [NAME]       créée une section nouvelle tmux (de nom optionnel NAME) avec 3 windows

======= TIPS :
    compression / décompression *.tar.7z :
     ├─ tar -cvf - file1 file2  |  7z a -si archive.tar.7z
     └─ 7z x archive.tar.7z -so | tar -xvf -

======= ZSH / BASH :
    alias | grep git    retrouver les alias git
    hsi PATTERN       grepper PATTERN dans l'historique
    GIT
     ├─ ga            git add
     ├─ gcam          git commit -a -m
     ├─ gcmsg         git commit -m
     ├─ gl / gp       git pull / git push
     ├─ gco           git checkout
     └─ gd            git diff
    CONFIG
     ├─ setopt        activer une option de zsh (man zshoptions)
     ├─ autoload      marquer une string comme fonction de zsh (pour ne pas la confondre avec une fonction du même nom)
     ├─ zmodload      charger un module de zsh
     └─ zstyle        configurer un module de zsh
    pyclean           nettoyer le répertoire courant (et ses fils) de *.pyc/__pycache__/...
    nvim **/*.py      ouvrir tous les fichiers *.py dans l'arborescence courante
    Ctrl+S            c'est l'opposé de Ctrl+R (qui recherche dans l'historique vers l'avant)
    watch -n 0.5 ls   lancer "ls" toutes les 0.5 secondes

EOF
}

alias cheat=cheatsheet
alias help=cheatsheet

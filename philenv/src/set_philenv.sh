#!/bin/sh
########################################################################################################################
#
# Point d'entrée du philenv (qui source les autres fichiers) :
#
########################################################################################################################


# Répertoire racine du philenv (passé en premier argument, ou s'il n'est pas précisé : /opt/philenv.d) :
default_philenv_absolute_dir="/opt/philenv.d"
philenv_absolute_dir="${default_philenv_absolute_dir}"
[ "$1" != "" ] && philenv_absolute_dir="$1"

# Il faut les droits d'accès sur le répertoire de mon environnement :
if [ -r "${philenv_absolute_dir}" -a -x "${philenv_absolute_dir}" ]
then
    source "${philenv_absolute_dir}/general_env.sh"
    source "${philenv_absolute_dir}/useful_functions.sh"
    source "${philenv_absolute_dir}/aliases.sh"
    source "${philenv_absolute_dir}/machine_dependent_stuff.sh"
else
    echo ""
    echo "ERREUR - impossible d'installer le philenv : répertoire \"${philenv_absolute_dir}\" inaccessible !"
    echo ""
fi


########################################################################################################################
# Fin du fichier.
########################################################################################################################

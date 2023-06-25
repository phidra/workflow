#!/bin/bash
########################################################################################################################
#
# Fichier de release du philenv.
# Génère un répertoire à copier quelque part (par exemple dans "/opt/philenv.d"), puis à sourcer depuis le bashrc.
# Produit en sortie le nom du répertoire du philenv.
#
########################################################################################################################

relative_script_dir=$(dirname "${0}")
script_dir=$(readlink -e "${relative_script_dir}")

pushd "${script_dir}" &> /dev/null

# Copie des sources dans un répertoire released :
DATE=$(date +'%d%B%Y_%Hh%Mm%Ss')
released_dirname="${script_dir}/RELEASED_philenv.d_${DATE}"
cp -R "philenv" "${released_dirname}"

# Remplissage du fichier de version et copie :
GIT_VERSION=$(git show --summary)
git_version_filename="philenv.version"
git_version_file="${released_dirname}/${git_version_filename}"
echo "RELEASE DATE = ${DATE}" > "${git_version_file}"
echo "" >> "${git_version_file}"
echo "GIT_VERSION = ${GIT_VERSION}" >> "${git_version_file}"

popd "${script_dir}" &> /dev/null

# Nom du répertoire produit :
echo "${released_dirname}"





########################################################################################################################
# Fin du fichier.
########################################################################################################################

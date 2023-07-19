#!/bin/bash
# Fichier de release du philenv.
# Génère un répertoire à copier quelque part (par exemple dans "/opt/philenv.d"), puis à sourcer depuis le bashrc.

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

this_script_parent="$(realpath "$(dirname "$0")" )"


pushd "${this_script_parent}" &> /dev/null

# Copie des sources dans un répertoire released :
DATE=$(date +'%d%B%Y_%Hh%Mm%Ss')
released_dirname="${this_script_parent}/RELEASED_philenv.d_${DATE}"
cp -R "src" "${released_dirname}"

# Remplissage du fichier de version et copie :
GIT_VERSION=$(git show --summary)
git_version_filename="philenv.version"
git_version_file="${released_dirname}/${git_version_filename}"
echo "RELEASE DATE = ${DATE}" > "${git_version_file}"
echo "" >> "${git_version_file}"
echo "GIT_VERSION = ${GIT_VERSION}" >> "${git_version_file}"

popd &> /dev/null

# On indique le répertoire créé :
echo "${released_dirname}"

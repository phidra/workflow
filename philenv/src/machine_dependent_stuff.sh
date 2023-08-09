# Ce fichier a vocation à être différent pour chaque machine sur lequel le philenv est installé.
# Il contient ce qui est machine-dependent (e.g. le répertoire des projets gits)
# Il doit être édité manuellement sur chaque machine où le philenv est installé.


#################################################################################
# projects related :
#################################################################################

export projects="/media/DATA/projects"
export gitprojects="${projects}/github"
function gogit
{
    gogit_base "$gitprojects"
}
alias gojour="cd ${projects}/JournauxDeSuivi"

#################################################################################
# ci-dessous, les autres trucs machine-related :
#################################################################################

export DATA="/media/DATA"
alias godata="cd ${DATA}"
alias god="godata"

# À moins qu'on ait ouvert le terminal sur une localisation spéciale (dans ce cas, le pwd n'est pas HOME), on va directement dans DATA :
[ "$(pwd)" = "${HOME}" ] && cd "${DATA}"

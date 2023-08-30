# Ce fichier a vocation à être différent pour chaque machine sur lequel le philenv est installé.
# Il contient ce qui est machine-dependent (e.g. le répertoire des projets gits)
# Il doit être édité manuellement sur chaque machine où le philenv est installé.
# GUIDELINE : rien dans le reste du philenv ne doit dépendre du contenu de ce fichier.

function gogit
{
    gogit_base "/media/DATA/projects/github"
}
alias gojour="cd /media/DATA/projects/JournauxDeSuivi"
alias godata="cd /media/DATA"
alias god="godata"

# À moins qu'on ait ouvert le terminal sur une localisation spéciale (dans ce cas, le pwd n'est pas HOME), on va directement dans DATA :
[ "$(pwd)" = "${HOME}" ] && cd "/media/DATA"

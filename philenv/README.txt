NOTES LORS DU TRANSFERT SUR GITHUB LE 25 JUIN 2023 = comme j'ai fait un peu de cleaning, ce serait sans doute plus simple d'agréger un gros bloc de code dans le zshrc, plutôt que de maintenir un projet séparé.

================================================================================
Pour installer le philenv sur une machine :
================================================================================
    1. Appeler ./release_philenv.sh
    2. En root, copier le répertoire créé dans "/opt"

        sudo cp -R RELEASED_philenv.d_14décembre2013_11h08m30s /opt

    3. Le rendre accessible en lecture et exécution à tout le monde, récursivement :

        sudo chmod -R o+rx /opt/RELEASED_philenv.d_14décembre2013_11h08m30s

    4. En créer un lien sous "/opt/philenv.d" :

        sudo ln -s RELEASED_philenv.d_14décembre2013_11h08m30s philenv.d


================================================================================
Derrière, si ce n'est pas déjà fait, pour chaque utilisateur (y compris root) :
================================================================================

    Ajouter la ligne suivante à la fin du ".bashrc" : ". /opt/philenv.d/set_philenv.sh"


================================================================================
Adapter le philenv à la machine qui l'utilise :
================================================================================
    vim /opt/philenv.d/machine_dependent_stuff.sh
        modifier le contenu machine-dependent, tel que le gitprojects

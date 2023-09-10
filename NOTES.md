* [Name et email git](#name-et-email-git)
   * [Contexte](#contexte)
   * [Différents niveaux de configuration git](#différents-niveaux-de-configuration-git)
   * [Le workflow retenu](#le-workflow-retenu)
   * [WARNING les points d'attention pour le futur](#warning-les-points-dattention-pour-le-futur)

# Name et email git

## Contexte

J'ai passé un peu de temps à corriger mes repos publics pour utiliser mon adresse phidra plutôt que mon adresse perso. Le présent workflow vise à éviter les mêmes soucis à l'avenir.

Objectif = ne pas laisser publics mes informations personnelles (prénom + nom + adresse perso).

Le point un peu délicat, c'est que mes contributions dans le cadre de mon travail doivent utiliser l'adresse fournie par mon employeur et non mon adresse phidra

## Différents niveaux de configuration git

Il y a 3 niveaux de config git dans lesquels je peux définir mon nom+email :

```
/etc/gitconfig                 = système (mieux vaut ne pas y toucher)
~/.gitconfig                   = global (commun à tous les projets)
/path/to/myproject/.git/config = per-project
```

Il faut éviter de toucher au niveau système.

Du coup, on a le choix entre éditer la config COMMUNE ou PER-PROJECT :

```sh
git config --edit --global  # COMMUNE
git config --edit           # PER-PROJECT
```

## Le workflow retenu

- j'ai une adresse "publique pour le dev" = mon adresse phidra
- l'idée de base est :
    - d'utiliser mon adresse pour le dev pour mes projets
    - tout en pouvant utiliser l'adresse fournie par mon employeur pour les repos git de mon boulot

Solution mise en oeuvre :

- mes postes à moi (PC fixe + PC creanov) :
    - la config globale `~/.gitconfig` sette mon adresse "publique pour le dev" phidra
    - je ne contribue pas à des projets git de mon employeur depuis ces PC (mais si jamais je le faisais, la config per-projet devrait renseigner l'adresse fournie par mon employeur)
- poste de mon employeur :
    - la config global NE DOIT PAS renseigner de nom + email
        ```sh
        git config --global --edit  # supprimer la section user
        ```
    - ça force à définir le nom+email de chaque projet, ce qui est bien ce que je veux
    - dans chaque projet, je sette le nom+email fourni par mon employeur
        ```sh
        git config --edit  # ajouter une section user avec name + email
        ```

## WARNING les points d'attention pour le futur

**ATTENTION** : si je contribue à un repo git public, bien regarder de quel poste je le fais + l'adresse que j'utilise, pour ne pas faire fuiter d'informations personnelles.

**ATTENTION** : je n'ai PAS fait la passe de suppression de mes informations personnelles pour mes repos privés ; si je dois passer un repo privé en public, il faut IMPÉRATIVEMENT :

- soit que je fasse le même travail de réécriture de l'historique
- soit que je crée un NOUVEAU repo public dans lequel je copie à la main le contenu du repo privé (plutôt que de modifier la visibilité du repo privé)
- dans tous les cas, contrôler le nom + email du nouveau repo

**ATTENTION** : quand je crée un nouveau repo public : contrôler le nom + email du nouveau repo.

**ATTENTION** : si je réécris l'historique :

- remettre à jour les liens qui pointent vers des commits de repos phidra
- (à l'exception d'un unique lien dans ULTRA, seul le repo notes avait de tels liens)


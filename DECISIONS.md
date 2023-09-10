* [Installation d'une nouvelle machine](#installation-dune-nouvelle-machine)
* [Name et email git](#name-et-email-git)
   * [Contexte](#contexte)
   * [Différents niveaux de configuration git](#différents-niveaux-de-configuration-git)
   * [Le workflow retenu](#le-workflow-retenu)
   * [WARNING les points d'attention pour le futur](#warning-les-points-dattention-pour-le-futur)
* [Autologin, gnome-keyring, passphrase ssh, et ssh-agent](#autologin-gnome-keyring-passphrase-ssh-et-ssh-agent)
   * [Contexte](#contexte-1)
   * [Le workflow retenu](#le-workflow-retenu-1)
   * [Alternative écartée](#alternative-écartée)



# Installation d'une nouvelle machine

cf. [les notes brutes dédiées](./fresh_installation_notes).

# Name et email git

## Contexte

cf. notes du 12 septembre 2023 dans mon journal K2.

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


# Autologin, gnome-keyring, passphrase ssh, et ssh-agent

## Contexte

cf. notes du 14 septembre 2023 dans mon journal K2.

Le contexte est l'utilisation d'une adresse email protonmail :

- pour consulter mes mails protonmail sur thunderbird, j'ai besoin de protonmail-bridge
- pour utiliser protonmail-bridge sans avoir à entrer un password à chaque fois, j'ai besoin que gnome-keyring soit déverrouillé
- pour déverrouiller automatiquement gnome-keyring au démarrage du PC, j'ai besoin que l'autologin soit désactivé
- je profite de l'occasion pour essayer d'utiliser gnome-keyring pour les passphrases SSH (spoiler-alert : c'est possible, mais ça n'est pas ce que j'ai retenu)
- du coup je définis mon workflow ssh

## Le workflow retenu

- je n'utilise plus l'autologin, car il empêche le déverrouillage automatique de gnome-keyring → du coup la première connexion au démarrage du PC fixe requiert un mot de passe
    - Dans `/etc/lightdm/lightdm.conf`, commenter la ligne `#autologin-user=`
- gnome-keyring est alors déverouillé automatiquement lorsqu'on se connecte au PC → les applis qui en ont besoin peuvent utiliser le keyring
- notamment, une fois le PC démarré, protonmail-bridge (et donc la consultation des mails protonmail via thunderbird) est utilisable sans action supplémentaire
- je décide que gnome-keyring ne gère PAS les passphrases des clés ssh ; si besoin, supprimer manuellement la gestion des clés ssh par le keyring :
    - utiliser seahorse (aka "Mots de passe et clés") pour afficher les applications ayant mémorisé une clé (`Connexion` = la liste des mots de passe gérés par gnome-keyring)
    - l'une des applications a pour titre `Mot de passe de déverrouillage pour <adresse-email-de-la-clé>`
    - on peut voir dans ses "Détails" que c'est une clé SSH, il indique ssh-store + le chemin de la clé
- à la place, c'est le plugin zsh qui gère un ssh-agent : couplé à l'option `lazy` + à `AddKeysToAgent`, ça fait à peu près ce que je veux :
    ```sh
    # ~/.zshrc :
    zstyle :omz:plugins:ssh-agent lazy yes
    plugins=(... ssh-agent ...)

    # ~/.ssh/config (créer le fichier si besoin) :
    AddKeysToAgent yes
    ```

Résultats :

- le gnome-keyring est déverrouillé automatiquement lorsque je me connecte
- ssh n'est pas géré par gnome-keyring, les deux sont complètement indépendants
- lorsque j'ouvre mon premier shell (peu importe qu'il soit remote ou local), zsh démarre ssh-agent
- plus tard, à ma première utilisation d'une clé ssh (e.g. premier `git pull`), zsh me demande la passphrase (l'utilisation de `AddKeysToAgent` assure alors que la passphrase soit stockée par ssh-agent)
- pour toutes les utilisations suivantes, je peux utiliser la clé ssh sans passphrase :
    - même si la première utilisation était sur un shell local et les suivantes sur des shells remote (ou le contraire)
    - même si entre temps je me suis déconnecté de tous les shell

## Alternative écartée

L'alternative que j'ai écartée était d'utiliser gnome-keyring pour gérer les clés SSH.

L'avantage était de ne jamais avoir besoin de rentrer la passphrase de la clé SSH, vu qu'elle est stockée dans le keyring, et que celui-ci est délocké quand je me connecte (a contrario, avec le workflow retenu ci-dessus, je dois entrer la passphrase de la clé ssh une fois = à la première utilisation).

L'inconvénient est que gnome-keyring ne fonctionne que pour une session graphique : du coup, quand je me connectais en SSH sur le PC fixe depuis un PC portable, gnome-keyring était inutilisable, et je devais rentrer la passphrase à chaque fois (ou bidouiller avec l'agent).

Mais cette alternative reste intéressante en soi : si un jour je suis certain de ne JAMAIS utiliser le PC fixe via SSH, alors mieux vaudra utiliser gnome-keyring que le plugin zsh.


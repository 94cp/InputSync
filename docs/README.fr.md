[简体中文](../README.md) · [English](../docs/README.en.md) · [繁體中文](../docs/README.zh-Hant.md) · [日本語](../docs/README.ja.md) · [한국어](../docs/README.ko.md) · [Deutsch](../docs/README.de.md) · [Français](../docs/README.fr.md) · [Español](../docs/README.es.md)

# Synchro de saisie · InputSync

Un utilitaire de barre des menus pour Mac qui synchronise la source de saisie distante avec le Mac local via Partage d’écran. **Installation locale uniquement**, sans configuration à distance.

![Démonstration InputSync — interface simulée, pas une capture vidéo](assets/inputsync-demo.gif)

## Démarrage

1. Téléchargez le dernier fichier `.dmg` depuis les [GitHub Releases](https://github.com/94cp/InputSync/releases/latest) du projet. Ouvrez-le, glissez **InputSync** dans **Applications**, puis lancez l’app depuis ce dossier. Xcode et la compilation ne sont pas nécessaires.
2. Autorisez l’accès depuis l’entrée des permissions de l’app. Selon macOS, la rubrique correspond à Accessibilité ou au contrôle de l’appareil et à l’accès aux données.
3. Connectez-vous au Mac distant avec Partage d’écran d’Apple.
4. Activez la synchronisation de la langue du clavier dans InputSync, ou dans le menu Édition de Partage d’écran sur le Mac local.
5. Activez la synchronisation dans InputSync. Changez de source de saisie locale, puis attendez environ une seconde avant de saisir à distance.

L’app démarre toujours en pause, même à la connexion. Un menu distant peut apparaître brièvement pendant la synchronisation.

### Premier lancement bloqué

Cette version n’est ni signée avec un identifiant Apple Developer ID ni notariée. macOS peut indiquer qu’il ne peut pas vérifier le développeur ou rechercher des logiciels malveillants.

Si vous l’avez téléchargée depuis les [GitHub Releases](https://github.com/94cp/InputSync/releases/latest) de ce projet :

1. Ouvrez InputSync une fois depuis **Applications**. Si elle est bloquée, fermez l’alerte sans placer l’app dans la corbeille.
2. Ouvrez **Réglages Système → Confidentialité et sécurité**, puis descendez jusqu’à **Sécurité**.
3. Repérez le message concernant InputSync et cliquez sur **Ouvrir quand même**.
4. Si demandé, utilisez votre mot de passe de session Mac ou Touch ID, puis cliquez sur **Ouvrir** dans la confirmation.

Si le bouton manque, essayez à nouveau d’ouvrir l’app, puis revenez aux réglages. InputSync apparaît ensuite dans la barre des menus, sans fenêtre principale. Accordez alors l’autorisation d’accessibilité demandée par l’app : elle est distincte de l’autorisation d’ouverture.

## Fonctionnement

La synchronisation de la langue du clavier peut modifier l’indicateur distant sans appliquer le changement à l’app active. Lors de nos essais, ouvrir puis fermer brièvement un menu distant rendait le changement effectif. InputSync automatise cette manipulation.

1. Observer les notifications macOS de changement de source de saisie locale, quelle que soit la touche ou le raccourci utilisé.
2. Attendre le délai configuré (0,5 seconde par défaut), pour laisser Partage d’écran synchroniser la langue.
3. Repérer l’écran partagé dans la fenêtre active via les API d’accessibilité, cliquer en haut à gauche de la barre des menus distante, puis envoyer Échap pour fermer le menu.

C’est un contournement de l’interface vérifié par des essais, pas un appel direct à une API de saisie distante. La barre des menus doit être accessible à l’emplacement prévu. Son apparition brève fait partie du mécanisme.

Vous pouvez déplacer ou redimensionner la fenêtre. Si elle change pendant une actualisation en attente, celle-ci est ignorée ; changez à nouveau de source après l’ajustement. Toutes les combinaisons de plein écran et de zoom ne sont pas testées.

## Symbole et langue

Dans « Plus », choisissez le symbole de la barre des menus. Le mode automatique utilise la disposition reconnue du clavier, puis la région du système :

- Chine continentale, Taïwan, Hong Kong, Macao : **中/英**
- Japon : **英数 / かな**
- Corée du Sud : **한/영**
- Autres régions : globe

Il s’agit d’une suggestion, pas d’une lecture des inscriptions des touches. Le choix manuel est prioritaire. Le symbole ne modifie ni les raccourcis ni la source de saisie.

L’interface suit la langue de l’app définie dans Langue et région de macOS. Huit langues sont incluses ; sinon, l’anglais est utilisé.

## Dépannage

- **Accès autorisé mais indisponible :** désactivez puis réactivez l’autorisation de cette app, puis relancez-la. Une nouvelle autorisation peut être nécessaire après une mise à jour.
- **Pas de synchronisation :** vérifiez les options des deux apps, gardez la fenêtre distante active ou augmentez le délai.
- **Journal :** accessible depuis « Plus ».

Validé avec ABC et le pinyin simplifié intégré à macOS 27.2. Les autres méthodes de saisie et anciennes versions ne sont pas entièrement testées. Conçu pour Partage d’écran d’Apple, sans modèle de Mac ni taille de fenêtre imposés.

## Désinstallation

Désactivez l’ouverture à la connexion, quittez l’app et supprimez-la. Vous pouvez aussi supprimer le journal : `~/Library/Logs/InputSync/events.log`.

## Soutenir le développement

Si InputSync vous est utile, vous pouvez m’offrir un café. Une étoile sur GitHub me fait aussi plaisir !

| WeChat Pay | Alipay |
| :---: | :---: |
| <img src="assets/donate/wechat.png" alt="WeChat Pay" width="180"> | <img src="assets/donate/alipay.png" alt="Alipay" width="180"> |

[Développement](DEVELOPMENT.md)

## Licence

Distribué sous [licence MIT](../LICENSE).

# aiden_fps_gate

Script FiveM client-only qui bloque automatiquement un joueur lorsque ses FPS depassent la limite configurée.

Le but est de forcer les joueurs a limiter leurs FPS pour eviter les avantages lies a un framerate trop eleve, notamment sur les serveurs course-poursuite, conduite ou RP.

## Apercu

<img width="2031" height="614" alt="image" src="https://github.com/user-attachments/assets/51e0f41b-42ee-46f5-8cb9-cb295110b541" />

## Fonctionnalites

- Detection des FPS coté client avec `GetFrameTime()`.
- Blocage automatique si le joueur depasse la limite trop longtemps.
- Freeze du joueur et du vehicule.
- Désactivation des contrôles, y compris la caméra.
- Affichage d'un message plein écran pendant le blocage.
- Déblocage automatique quand les FPS repassent sous la limite.
- Ressource optimisée: pas de boucle lourde permanente hors blocage.
- Aucun script serveur requis.

## Installation

1. Placez le dossier `aiden_fps_gate` dans le dossier `resources` de votre serveur.
2. Ajoutez la ressource dans votre `server.cfg`:

```cfg
ensure aiden_fps_gate
```

3. Redemarrez le serveur ou lancez:

```txt
restart aiden_fps_gate
```

## Configuration

Tous les réglages principaux se trouvent dans `config.lua`.

```lua
Config.MaxFPS = 120
Config.Tolerance = 3
Config.SampleMs = 1000
Config.SampleFrames = 5
Config.BlockAfterMs = 3000
Config.UnlockAfterMs = 3000
```

## Paramètres essentiels

| Paramètre | Description |
| --- | --- |
| `Config.MaxFPS` | Limite FPS autorisee par le serveur. |
| `Config.Tolerance` | Marge ajoutee a la limite pour eviter les faux positifs. |
| `Config.SampleMs` | Delai entre chaque verification FPS, en millisecondes. |
| `Config.SampleFrames` | Nombre de frames lues a chaque verification. |
| `Config.BlockAfterMs` | Temps necessaire au-dessus de la limite avant blocage. |
| `Config.UnlockAfterMs` | Temps necessaire sous la limite avant deblocage. |
| `Config.MessageTitle` | Titre affiche pendant le blocage. |
| `Config.MessageSubtitle` | Sous-titre affiche pendant le blocage. |

Avec la configuration par défaut:

- limite configurée: `120 FPS`;
- tolerance: `3 FPS`;
- seuil réel de blocage: au-dessus de `123 FPS`;
- blocage apres `3 secondes`;
- déblocage apres `3 secondes` sous la limite.

## Exemple pour limiter à 60 FPS

Pour forcer les joueurs à rester autour de 60 FPS:

```lua
Config.MaxFPS = 60
Config.Tolerance = 3
```

Dans cet exemple, le joueur sera bloqué au-dessus de `63 FPS`.

## Fonctionnement

Le script vérifie périodiquement les FPS du joueur. Si les FPS restent au-dessus de `Config.MaxFPS + Config.Tolerance` pendant `Config.BlockAfterMs`, le joueur est bloqué.

Pendant le blocage:

- le ped est freeze;
- le véhicule est freeze et rendu non conduisible;
- les contrôles sont desactivés;
- la camera est bloquée;
- un message est affiché à l'écran.

Quand le joueur limite ses FPS et reste sous la limite pendant `Config.UnlockAfterMs`, le script le débloque automatiquement.

## Notes

FiveM ne permet pas de brider directement les FPS d'un joueur via un script. Le script peut uniquement détecter les FPS et bloquer le joueur jusqu'a ce qu'il limite ses FPS lui-meme via V-Sync, NVIDIA Control Panel, AMD Software, RTSS ou un autre limiteur.

La ressource est volontairement client-only: le serveur ne connait pas les FPS réels d'un joueur et un systeme serveur ajouterait du réseau sans rendre la detection plus fiable.

# Guide d'installation - LiveShop

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **Flutter SDK** (version 3.0 ou supérieure)
- Téléchargez depuis : https://flutter.dev/docs/get-started/install
- **Un éditeur de code** (VS Code ou Android Studio recommandé)
- **Git** pour cloner le projet

## Installation

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd liveshop
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Générer les fichiers de code

L'application utilise `json_serializable` pour la sérialisation. Générez les fichiers nécessaires :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Ou utilisez la commande plus courte :

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Copier les données mock

Copiez le fichier de données mock dans le dossier assets :

```bash
# Sur Windows
copy lib\mock-api-data.json assets\mock-api-data.json

# Sur macOS/Linux
cp lib/mock-api-data.json assets/mock-api-data.json
```

### 5. Lancer l'application

#### Sur Chrome (Web)
```bash
flutter run -d chrome
```



## Dépannage

### Erreur : "Target of URI hasn't been generated"

Si vous voyez cette erreur, exécutez :
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Erreur : "Unable to load asset"

Vérifiez que le fichier `assets/mock-api-data.json` existe et que `pubspec.yaml` contient :
```yaml
flutter:
  assets:
    - assets/mock-api-data.json
```

### Problème de connexion réseau (images)

L'application charge des images depuis des URLs externes. Assurez-vous d'avoir une connexion internet active.

## Commandes utiles

```bash
# Nettoyer le projet
flutter clean

# Réinstaller les dépendances
flutter pub get

# Vérifier les problèmes
flutter doctor

# Analyser le code
flutter analyze

# Formater le code
dart format .
```

## Développement

Pour le développement en mode watch (régénération automatique) :

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Support

Pour toute question ou problème, consultez :
- Documentation Flutter : https://flutter.dev/docs
- Stack Overflow : https://stackoverflow.com/questions/tagged/flutter

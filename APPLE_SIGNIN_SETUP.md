# Configuration Sign in with Apple - Guide Complet

## ⚠️ Erreur 1000 - Causes et Solutions

L'erreur `AuthorizationErrorCode.unknown (error 1000)` survient généralement pour ces raisons :

### 1. Configuration manquante dans Apple Developer Portal

**Bundle ID**: `com.gytx.pogupConciergerieApp`
**Team ID**: `8KQFUCHM9G`

#### Étapes à suivre dans le portail Apple Developer :

1. **Accédez à** : https://developer.apple.com/account/resources/identifiers/list
2. **Sélectionnez** votre App ID : `com.gytx.pogupConciergerieApp`
3. **Vérifiez la capacité "Sign in with Apple"** :
   - ✅ La case "Sign in with Apple" doit être cochée
   - Cliquez sur "Edit" si nécessaire
   - Activez "Sign in with Apple"
   - Choisissez "Enable as a primary App ID"
   - **Sauvegardez** les modifications

### 2. L'appareil doit être connecté à iCloud

- Allez dans **Réglages** → **[Votre nom]** → **iCloud**
- Vérifiez que vous êtes bien connecté avec un Apple ID
- Sign in with Apple ne fonctionne pas sans connexion iCloud active

### 3. Version iOS

- Sign in with Apple nécessite **iOS 13.0 ou supérieur**
- Vérifiez la version iOS de votre appareil

### 4. Rebuild complet nécessaire

Après avoir activé la capacité dans le portail développeur Apple :

```bash
# Nettoyer complètement le projet
cd /Users/antagonist/Desktop/Pog-Up-Conciergerie-main
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Réinstaller les dépendances
flutter pub get
cd ios && pod install

# Rebuild depuis Xcode
open ios/Runner.xcworkspace
```

### 5. Vérification dans Xcode

1. Ouvrez le projet : `ios/Runner.xcworkspace`
2. Sélectionnez le target **Runner**
3. Allez dans l'onglet **Signing & Capabilities**
4. Vérifiez que **"Sign in with Apple"** apparaît dans la liste des capacités
5. Si absent, cliquez sur **"+ Capability"** et ajoutez **"Sign in with Apple"**

### 6. Fichiers modifiés (déjà fait)

✅ `ios/Runner/Runner.entitlements` créé avec :
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

✅ `ios/Runner.xcodeproj/project.pbxproj` mis à jour avec :
```
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
```

## 🔧 Commandes de diagnostic

### Vérifier si Sign in with Apple est disponible
Le code vérifie maintenant automatiquement avec `SignInWithApple.isAvailable()`

### Logs à surveiller
```
flutter: Démarrage de l'authentification Apple...
flutter: Sign in with Apple disponible: true/false
flutter: Nonce généré, demande de credentials Apple...
```

## 📝 Checklist de résolution

- [ ] Bundle ID `com.gytx.pogupConciergerieApp` configuré dans Apple Developer Portal
- [ ] Capacité "Sign in with Apple" activée pour ce Bundle ID
- [ ] Appareil iOS connecté à iCloud avec un Apple ID valide
- [ ] iOS 13.0 ou supérieur
- [ ] Fichier `Runner.entitlements` présent et correctement configuré
- [ ] Projet nettoyé avec `flutter clean`
- [ ] Pods réinstallés avec `pod install`
- [ ] App reconstruite complètement depuis Xcode ou Flutter
- [ ] Capacité "Sign in with Apple" visible dans Xcode → Signing & Capabilities

## 🎯 Prochaines étapes

1. Vérifiez la configuration dans le portail Apple Developer
2. Assurez-vous que l'appareil est connecté à iCloud
3. Reconstruisez complètement l'application
4. Testez à nouveau Sign in with Apple

## ⚡ Solution rapide si tout est configuré

Si tout est bien configuré dans le portail mais l'erreur persiste :

```bash
# Solution complète de nettoyage
cd /Users/antagonist/Desktop/Pog-Up-Conciergerie-main
flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/build
flutter pub get
cd ios && pod install --repo-update
cd ..
flutter run
```

## 📚 Ressources supplémentaires

- [Documentation Apple - Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Flutter sign_in_with_apple package](https://pub.dev/packages/sign_in_with_apple)
- [Supabase Apple Sign In Guide](https://supabase.com/docs/guides/auth/social-login/auth-apple)

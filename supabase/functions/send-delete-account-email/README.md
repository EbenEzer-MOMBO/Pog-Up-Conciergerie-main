# Fonction Supabase : Envoi d'email de suppression de compte

Cette fonction Edge Function de Supabase envoie un email via Resend API lorsqu'un utilisateur soumet une demande de suppression de compte.

## Configuration

### Variables d'environnement

Définissez les variables d'environnement suivantes dans votre projet Supabase :

```bash
RESEND_API_KEY=re_Zq2tDt23_JFzrSgTPiZCe5Kyp7unofZSc
```

### Configuration dans Supabase Dashboard

1. Allez dans votre projet Supabase
2. Naviguez vers **Edge Functions**
3. Créez une nouvelle fonction ou modifiez celle existante
4. Ajoutez la variable d'environnement `RESEND_API_KEY` dans les paramètres de la fonction

## Déploiement

### Via Supabase CLI

```bash
# Installer Supabase CLI si ce n'est pas déjà fait
npm install -g supabase

# Se connecter à votre projet
supabase login

# Lier votre projet
supabase link --project-ref votre-project-ref

# Déployer la fonction
supabase functions deploy send-delete-account-email
```

### Via Supabase Dashboard

1. Allez dans **Edge Functions** dans votre dashboard Supabase
2. Cliquez sur **Create a new function**
3. Nommez-la `send-delete-account-email`
4. Copiez le contenu de `index.ts` dans l'éditeur
5. Ajoutez la variable d'environnement `RESEND_API_KEY`
6. Cliquez sur **Deploy**

## Utilisation

La fonction est appelée depuis la page HTML `delete_account.html` avec une requête POST contenant :

```json
{
  "email": "user@example.com",
  "prenom": "John",
  "nom": "Doe",
  "raison": "Raison de la suppression",
  "userId": "uuid-de-l-utilisateur"
}
```

## Endpoint

L'endpoint de la fonction sera accessible à :

```
https://[votre-project-ref].supabase.co/functions/v1/send-delete-account-email
```

Remplacez `[votre-project-ref]` par votre référence de projet Supabase (ex: `sazaveplwyjpbdkjobec`).

## Email envoyé

L'email est envoyé à `mahelnguindja@gmail.com` depuis `pogup@gytx.dev` avec :

- Le sujet : "Demande de suppression de compte - [email]"
- Le contenu HTML formaté avec toutes les informations de l'utilisateur
- Le reply-to configuré sur l'email de l'utilisateur

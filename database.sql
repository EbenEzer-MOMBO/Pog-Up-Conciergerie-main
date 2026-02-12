-- ============================================
-- Database schema for Pog-Up Conciergerie
-- Professional setup with RLS, triggers, and optimizations
-- 
-- ATTENTION: Ce fichier crée les tables depuis zéro
-- Si vos tables existent déjà, utilisez migrate_existing_database.sql
-- ============================================

-- ============================================
-- STEP 1: Enable necessary extensions
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- STEP 2: Tables without dependencies
-- ============================================

-- Table: utilisateurs (Users)
CREATE TABLE public.utilisateurs (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  prenom text NOT NULL,
  nom text NOT NULL,
  date_naissance date,
  genre text CHECK (genre = ANY (ARRAY['Homme'::text, 'Femme'::text, 'Autre'::text])),
  contact text NOT NULL,
  email text NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text),
  role text DEFAULT 'user'::text CHECK (role = ANY (ARRAY['user'::text, 'admin'::text, 'super_admin'::text])),
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  email_confirmed boolean DEFAULT false NOT NULL,
  profile_complete boolean DEFAULT false NOT NULL,
  display_name text,
  fcm_id text
);

CREATE INDEX idx_utilisateurs_email ON public.utilisateurs(email);
CREATE INDEX idx_utilisateurs_role ON public.utilisateurs(role);

-- Table: services (Services)
CREATE TABLE public.services (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  type_service text NOT NULL CHECK (
    type_service = ANY (
      ARRAY['transport'::text, 'hebergement'::text, 'livraison'::text, 'autres'::text]
    )
  ),
  titre text,
  description text,
  prix_estimatif numeric(10,2),
  created_at timestamptz DEFAULT now() NOT NULL,
  image_url text
);

CREATE INDEX idx_services_type_service ON public.services(type_service);
CREATE INDEX idx_services_created_at ON public.services(created_at DESC);

-- Table: liens_utiles (Useful Links)
CREATE TABLE public.liens_utiles (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nom_entreprise text NOT NULL,
  description text,
  logo_url text,
  lien text NOT NULL,
  categorie text CHECK (categorie = ANY (ARRAY['partenaire'::text, 'service'::text, 'contact'::text, 'urgence'::text, 'autre'::text])),
  telephone text,
  email text,
  actif boolean DEFAULT true NOT NULL,
  ordre integer DEFAULT 0 NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_liens_utiles_categorie ON public.liens_utiles(categorie);
CREATE INDEX idx_liens_utiles_actif ON public.liens_utiles(actif) WHERE actif = true;
CREATE INDEX idx_liens_utiles_ordre ON public.liens_utiles(ordre);

-- Table: partnerships (Partnerships)
CREATE TABLE public.partnerships (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  nom_entreprise text NOT NULL,
  secteur_activite text,
  service_souhaite text,
  contact text NOT NULL,
  description text,
  fichier_circuit text,
  statut text DEFAULT 'en_attente'::text CHECK (statut = ANY (ARRAY['en_attente'::text, 'accepte'::text, 'refuse'::text, 'en_cours'::text])) NOT NULL,
  date_soumission timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_partnerships_statut ON public.partnerships(statut);
CREATE INDEX idx_partnerships_date_soumission ON public.partnerships(date_soumission DESC);

-- ============================================
-- STEP 3: Tables depending on utilisateurs
-- ============================================

-- Table: annonces (Announcements)
CREATE TABLE public.annonces (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  titre text NOT NULL,
  description text,
  image_url text,
  lien text,
  date_publication timestamptz DEFAULT now() NOT NULL,
  date_expiration timestamptz,
  utilisateur_id uuid REFERENCES public.utilisateurs(id) ON DELETE SET NULL,
  statut_validation text DEFAULT 'en_attente'::text CHECK (statut_validation = ANY (ARRAY['en_attente'::text, 'validee'::text, 'refusee'::text])) NOT NULL,
  date_validation timestamptz,
  validee_par uuid REFERENCES public.utilisateurs(id) ON DELETE SET NULL,
  commentaire_validation text
);

CREATE INDEX idx_annonces_utilisateur_id ON public.annonces(utilisateur_id);
CREATE INDEX idx_annonces_statut_validation ON public.annonces(statut_validation);
CREATE INDEX idx_annonces_date_publication ON public.annonces(date_publication DESC);
CREATE INDEX idx_annonces_date_expiration ON public.annonces(date_expiration) WHERE date_expiration IS NOT NULL;

-- Table: demandes (Requests)
CREATE TABLE public.demandes (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  utilisateur_id uuid REFERENCES public.utilisateurs(id) ON DELETE CASCADE NOT NULL,
  type_service text NOT NULL CHECK (length(TRIM(BOTH FROM type_service)) > 0),
  statut text DEFAULT 'en_attente'::text CHECK (statut = ANY (ARRAY['en_attente'::text, 'en_cours'::text, 'termine'::text, 'annule'::text])) NOT NULL,
  date_creation timestamptz DEFAULT now() NOT NULL,
  details jsonb CHECK (details IS NULL OR jsonb_typeof(details) = 'object'::text),
  updated_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_demandes_utilisateur_id ON public.demandes(utilisateur_id);
CREATE INDEX idx_demandes_statut ON public.demandes(statut);
CREATE INDEX idx_demandes_type_service ON public.demandes(type_service);
CREATE INDEX idx_demandes_date_creation ON public.demandes(date_creation DESC);
CREATE INDEX idx_demandes_details ON public.demandes USING gin(details) WHERE details IS NOT NULL;

-- Table: notifications (Notifications)
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  utilisateur_id uuid REFERENCES public.utilisateurs(id) ON DELETE CASCADE NOT NULL,
  type text,
  message text NOT NULL,
  statut text DEFAULT 'envoye'::text CHECK (statut = ANY (ARRAY['envoye'::text, 'lu'::text, 'non_lu'::text])) NOT NULL,
  date_envoi timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_notifications_utilisateur_id ON public.notifications(utilisateur_id);
CREATE INDEX idx_notifications_statut ON public.notifications(statut);
CREATE INDEX idx_notifications_date_envoi ON public.notifications(date_envoi DESC);
CREATE INDEX idx_notifications_utilisateur_statut ON public.notifications(utilisateur_id, statut) WHERE statut = 'non_lu';

-- ============================================
-- STEP 4: Tables depending on services
-- ============================================

-- Table: hebergements (Accommodations)
CREATE TABLE public.hebergements (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  service_id uuid UNIQUE REFERENCES public.services(id) ON DELETE CASCADE NOT NULL,
  sous_type text NOT NULL CHECK (
    sous_type = ANY (
      ARRAY['chambres_hotes'::text, 'hotels'::text, 'appartements'::text]
    )
  ),
  localisation text,
  capacite integer CHECK (capacite > 0),
  prix numeric(10,2) CHECK (prix >= 0),
  description text
);

CREATE INDEX idx_hebergements_sous_type ON public.hebergements(sous_type);
CREATE INDEX idx_hebergements_service_id ON public.hebergements(service_id);
CREATE INDEX idx_hebergements_localisation ON public.hebergements(localisation) WHERE localisation IS NOT NULL;

-- Table: livraisons (Deliveries)
CREATE TABLE public.livraisons (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  service_id uuid UNIQUE REFERENCES public.services(id) ON DELETE CASCADE NOT NULL,
  sous_type text NOT NULL CHECK (
    sous_type = ANY (
      ARRAY['alimentaire'::text, 'fragile'::text, 'paquets'::text, 'documents'::text, 'tous'::text]
    )
  ),
  adresse_depart text,
  adresse_arrivee text,
  type_colis text,
  poids numeric(10,2) CHECK (poids >= 0),
  instructions text
);

CREATE INDEX idx_livraisons_sous_type ON public.livraisons(sous_type);
CREATE INDEX idx_livraisons_service_id ON public.livraisons(service_id);

-- Table: transports (Transport)
CREATE TABLE public.transports (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  service_id uuid UNIQUE REFERENCES public.services(id) ON DELETE CASCADE NOT NULL,
  sous_type text NOT NULL CHECK (
    sous_type = ANY (
      ARRAY['scolaire'::text, 'location'::text, 'vtc'::text, 'bus'::text]
    )
  ),
  depart text,
  arrivee text,
  horaire text,
  frequence text,
  capacite integer CHECK (capacite > 0),
  marque text,
  modele text,
  option_vtc text,
  prix numeric(10,2) CHECK (prix >= 0),
  heure_depart time,
  heure_arrivee time,
  CONSTRAINT transports_horaires_check CHECK (
    (sous_type = 'scolaire'::text AND heure_depart IS NOT NULL AND heure_arrivee IS NOT NULL)
    OR (sous_type <> 'scolaire'::text AND heure_depart IS NULL AND heure_arrivee IS NULL)
  )
);

CREATE INDEX idx_transports_sous_type ON public.transports(sous_type);
CREATE INDEX idx_transports_service_id ON public.transports(service_id);
CREATE INDEX idx_transports_depart_arrivee ON public.transports(depart, arrivee) WHERE depart IS NOT NULL AND arrivee IS NOT NULL;

-- Table: autres_services (Other Services)
CREATE TABLE public.autres_services (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  service_id uuid REFERENCES public.services(id) ON DELETE CASCADE NOT NULL,
  nom_service text NOT NULL,
  description text
);

CREATE INDEX idx_autres_services_service_id ON public.autres_services(service_id);

-- ============================================
-- STEP 5: Tables depending on multiple tables
-- ============================================

-- Table: messages (Messages)
CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  demande_id uuid REFERENCES public.demandes(id) ON DELETE CASCADE NOT NULL,
  emetteur uuid REFERENCES public.utilisateurs(id) ON DELETE CASCADE NOT NULL,
  contenu text NOT NULL,
  date_envoi timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_messages_demande_id ON public.messages(demande_id);
CREATE INDEX idx_messages_emetteur ON public.messages(emetteur);
CREATE INDEX idx_messages_date_envoi ON public.messages(date_envoi DESC);
CREATE INDEX idx_messages_demande_date ON public.messages(demande_id, date_envoi DESC);

-- ============================================
-- STEP 6: Trigger function for updated_at
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER set_updated_at_utilisateurs
  BEFORE UPDATE ON public.utilisateurs
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_liens_utiles
  BEFORE UPDATE ON public.liens_utiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_partnerships
  BEFORE UPDATE ON public.partnerships
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_demandes
  BEFORE UPDATE ON public.demandes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- STEP 6.5: Helper functions (avoids RLS recursion)
-- ============================================

-- Créer une fonction helper sécurisée pour vérifier le rôle admin
-- Cette fonction contourne RLS (SECURITY DEFINER) pour éviter la récursion infinie
CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.utilisateurs
    WHERE id = user_id 
    AND role IN ('admin', 'super_admin')
  );
END;
$$;

-- Fonction pour permettre l'insertion du profil lors de l'inscription
-- Cette fonction contourne RLS pour permettre l'insertion du profil initial
-- Elle vérifie que l'ID correspond à un utilisateur dans auth.users
-- (même si l'utilisateur n'est pas encore connecté, par exemple si l'email doit être confirmé)
CREATE OR REPLACE FUNCTION public.insert_user_profile(
  p_id uuid,
  p_prenom text,
  p_nom text,
  p_email text,
  p_contact text,
  p_date_naissance date DEFAULT NULL,
  p_genre text DEFAULT NULL,
  p_role text DEFAULT 'user',
  p_email_confirmed boolean DEFAULT false,
  p_profile_complete boolean DEFAULT false,
  p_created_at timestamptz DEFAULT now(),
  p_updated_at timestamptz DEFAULT now()
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_exists boolean;
  v_current_uid uuid;
BEGIN
  -- Récupérer l'ID de l'utilisateur actuellement authentifié (peut être NULL)
  v_current_uid := auth.uid();
  
  -- Vérifier si l'utilisateur existe dans auth.users
  SELECT EXISTS(SELECT 1 FROM auth.users WHERE id = p_id) INTO v_user_exists;
  
  -- Autoriser l'insertion si :
  -- 1. L'utilisateur est authentifié ET l'ID correspond, OU
  -- 2. L'utilisateur existe dans auth.users (même s'il n'est pas encore connecté)
  IF (v_current_uid IS NOT NULL AND v_current_uid = p_id) OR v_user_exists THEN
    -- Insérer le profil (contourne RLS grâce à SECURITY DEFINER)
    INSERT INTO public.utilisateurs (
      id, prenom, nom, email, contact, date_naissance, genre, 
      role, email_confirmed, profile_complete, created_at, updated_at
    )
    VALUES (
      p_id, p_prenom, p_nom, p_email, p_contact, p_date_naissance, p_genre,
      p_role, p_email_confirmed, p_profile_complete, p_created_at, p_updated_at
    );
  ELSE
    RAISE EXCEPTION 'Unauthorized: Cannot insert profile for different user or user does not exist';
  END IF;
END;
$$;

-- ============================================
-- STEP 7: Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE public.utilisateurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liens_utiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partnerships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.annonces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.demandes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hebergements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.livraisons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.autres_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 8: RLS Policies
-- ============================================

-- Policies for utilisateurs
CREATE POLICY "Users can view their own profile"
  ON public.utilisateurs FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.utilisateurs FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.utilisateurs FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can view all users"
  ON public.utilisateurs FOR SELECT
  USING (public.is_admin(auth.uid()));

-- Policies for services (public read, admin write)
CREATE POLICY "Anyone can view active services"
  ON public.services FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage services"
  ON public.services FOR ALL
  USING (public.is_admin(auth.uid()));

-- Policies for liens_utiles (public read, admin write)
CREATE POLICY "Anyone can view active useful links"
  ON public.liens_utiles FOR SELECT
  USING (actif = true);

CREATE POLICY "Admins can manage useful links"
  ON public.liens_utiles FOR ALL
  USING (public.is_admin(auth.uid()));

-- Policies for partnerships (users can create, admins can manage)
CREATE POLICY "Authenticated users can create partnerships"
  ON public.partnerships FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can view their own partnerships"
  ON public.partnerships FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage all partnerships"
  ON public.partnerships FOR ALL
  USING (public.is_admin(auth.uid()));

-- Policies for annonces (public read validated, users can create)
CREATE POLICY "Anyone can view validated announcements"
  ON public.annonces FOR SELECT
  USING (statut_validation = 'validee' AND (date_expiration IS NULL OR date_expiration > now()));

CREATE POLICY "Authenticated users can create announcements"
  ON public.annonces FOR INSERT
  WITH CHECK (auth.uid() = utilisateur_id);

CREATE POLICY "Users can view their own announcements"
  ON public.annonces FOR SELECT
  USING (auth.uid() = utilisateur_id);

CREATE POLICY "Users can update their own pending announcements"
  ON public.annonces FOR UPDATE
  USING (auth.uid() = utilisateur_id AND statut_validation = 'en_attente');

CREATE POLICY "Admins can manage all announcements"
  ON public.annonces FOR ALL
  USING (public.is_admin(auth.uid()));

-- Policies for demandes (users manage their own)
CREATE POLICY "Users can view their own requests"
  ON public.demandes FOR SELECT
  USING (auth.uid() = utilisateur_id);

CREATE POLICY "Users can create their own requests"
  ON public.demandes FOR INSERT
  WITH CHECK (auth.uid() = utilisateur_id);

CREATE POLICY "Users can update their own requests"
  ON public.demandes FOR UPDATE
  USING (auth.uid() = utilisateur_id);

CREATE POLICY "Admins can view all requests"
  ON public.demandes FOR SELECT
  USING (public.is_admin(auth.uid()));

-- Policies for notifications (users view their own)
CREATE POLICY "Users can view their own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = utilisateur_id);

CREATE POLICY "Users can update their own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = utilisateur_id);

CREATE POLICY "System can insert notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (true);

-- Policies for service detail tables (public read, admin write)
CREATE POLICY "Anyone can view service details"
  ON public.hebergements FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view service details"
  ON public.livraisons FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view service details"
  ON public.transports FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view service details"
  ON public.autres_services FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage service details"
  ON public.hebergements FOR ALL
  USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage service details"
  ON public.livraisons FOR ALL
  USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage service details"
  ON public.transports FOR ALL
  USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage service details"
  ON public.autres_services FOR ALL
  USING (public.is_admin(auth.uid()));

-- Policies for messages (users view messages for their requests)
CREATE POLICY "Users can view messages for their requests"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.demandes
      WHERE demandes.id = messages.demande_id
      AND demandes.utilisateur_id = auth.uid()
    )
  );

CREATE POLICY "Users can create messages for their requests"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = emetteur AND
    EXISTS (
      SELECT 1 FROM public.demandes
      WHERE demandes.id = messages.demande_id
      AND demandes.utilisateur_id = auth.uid()
    )
  );

CREATE POLICY "Admins can view all messages"
  ON public.messages FOR SELECT
  USING (public.is_admin(auth.uid()));

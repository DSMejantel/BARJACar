-- 1. Intégration du Shell dynamique
SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

-- 2. Variables de configuration (à ajuster si besoin)
SET nom_commune = 'Mairie de Barjac';
SET adresse_mairie = 'Place de la Mairie, 48000 Barjac';
SET telephone_mairie = '04 66 47 01 04';
SET email_mairie = 'mairie-de-barjac48@wanadoo.fr';
SET nom_maire = 'David SOULIÉ, Maire de Barjac';
SET nom_hebergeur = 'OVH SAS';
SET adresse_hebergeur = '2 rue Kellermann - 59100 Roubaix - France';

-- 3. En-tête de la page
SELECT 'title' AS component,
       'Politique de confidentialité' AS title,
       'Informations réglementaires concernant la plateforme municipale de covoiturage BARJACar.' AS description;


-- 4. Protection des données personnelles (RGPD)
SELECT 'card' AS component,
       'Protection des données personnelles (RGPD)' AS title,
       'shield-check' AS icon,
       'green' AS color;

SELECT 'columns' AS component;
SELECT 'Responsable du traitement' AS title,
       'La **' || $nom_commune || '** s''engage à ce que la collecte et le traitement de vos données soient conformes au Règlement Général sur la Protection des Données (RGPD).' AS description_md;

SELECT 'Finalités du traitement' AS title,
       'Les données collectées (nom, téléphone, adresse email, trajets) sont uniquement utilisées pour :
- La mise en relation entre conducteurs et passagers.
- L''envoi de notifications Push relatives à vos trajets et suggestions.' AS description_md;

SELECT 'Conservation & Droits' AS title,
       'Vos données sont conservées le temps de l''utilisation du service. Conformément au RGPD, vous disposez d''un droit d''accès, de rectification et de suppression de vos données. Pour l''exercer, contactez : [' || $email_mairie || '](mailto:' || $email_mairie || ').' AS description_md;


-- 5. Cookies et Notifications Push
SELECT 'card' AS component,
       'Cookies & Notifications Push' AS title,
       'cookie' AS icon,
       'orange' AS color;

SELECT 'columns' AS component;
SELECT 'Gestion des cookies' AS title,
       'L''application **BARJACar** n''utilise que des jetons de session strictement nécessaires à son fonctionnement (connexion utilisateur). Aucun cookie de suivi publicitaire ou tiers n''est déposé.' AS description_md;

SELECT 'Notifications Web Push' AS title,
       'L''abonnement aux notifications Push est facultatif. Il s''effectue à votre initiative depuis votre profil. Vous pouvez vous désabonner à tout moment depuis l''onglet **Mon profil** ou les paramètres de votre navigateur.' AS description_md;


-- 6. Accessibilité Numérique
SELECT 'card' AS component,
       'Accessibilité Numérique' AS title,
       'accessibility' AS icon,
       'purple' AS color;

SELECT 'columns' AS component;
SELECT 'Statut de conformité' AS title,
       '**Accessibilité : partiellement conforme**  
La Mairie de Barjac s''efforce de rendre la plateforme BARJACar accessible au plus grand nombre, conformément au Référentiel Général d''Amélioration de l''Accessibilité (RGAA).' AS description_md;

SELECT 'Signalement & Contact' AS title,
       'Si vous rencontrez une difficulté d''accès à un contenu ou un service, vous pouvez contacter la Mairie : [' || $email_mairie || '](mailto:' || $email_mairie || ').' AS description_md;


-- 7. Bouton de retour
SELECT 'button' AS component,
       'center' AS justify;
SELECT 'Retour à l''accueil' AS title,
       '/' AS link,
       'home' AS icon,
       'secondary' AS color;

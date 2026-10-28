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
       'Mentions légales & Politique de confidentialité' AS title,
       'Informations réglementaires concernant la plateforme municipale de covoiturage BARJACar.' AS description;

-- 4. Éditeur de la plateforme
SELECT 'card' AS component,
       'Éditeur du service' AS title,
       'building-community' AS icon,
       'blue' AS color;

SELECT 'columns' AS component;
SELECT 'Collectivité éditrice' AS title,
       '**' || $nom_commune || '**  
' || $adresse_mairie || '  
Téléphone : ' || $telephone_mairie || '  
Courriel : [' || $email_mairie || '](mailto:' || $email_mairie || ')' AS description_md;

SELECT 'Directeur de la publication' AS title,
       '**' || $nom_maire || '**  
En sa qualité de représentant légal de la commune de Barjac.' AS description_md;


-- 5. Hébergement & Conception technique
SELECT 'card' AS component,
       'Hébergement & Conception' AS title,
       'server' AS icon,
       'teal' AS color;

SELECT 'columns' AS component;
SELECT 'Hébergeur' AS title,
       '**' || $nom_hebergeur || '**  
' || $adresse_hebergeur AS description_md;

SELECT 'Technologies utilisées' AS title,
       'Développé avec **SQLPage**.  
Icônes : **Tabler Icons**.  
Cartographie : **OpenStreetMap**.' AS description_md;



-- 7. Bouton de retour
SELECT 'button' AS component,
       'center' AS justify;
SELECT 'Retour à l''accueil' AS title,
       '/' AS link,
       'home' AS icon,
       'secondary' AS color;

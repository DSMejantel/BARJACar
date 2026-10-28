-- 1. Intégration du Shell
SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

-- 2. En-tête de la page
SELECT 'text' AS component,
       'Installer BARJACar sur votre mobile' AS title;
       
SELECT 'alert' AS component,
       'teal' AS color,
       'bulb' AS icon,
       'Simple et pratique !' AS title,     
       'Profitez d''un accès rapide en plein écran et recevez vos notifications en temps réel sur votre téléphone ou ordinateur.' AS description;

-- 3. Information importante
SELECT 'alert' AS component,
       'orange' AS color,
       'info-circle' AS icon,
       'Application Web (PWA)' AS title,
       'Aucun téléchargement depuis Google Play ou l''App Store n''est requis. L''installation se fait directement depuis votre navigateur en quelques secondes !' AS description;


-- 4. Tutoriel pour Android
SELECT 'card' AS component,
       'Sur Android (Google Chrome)' AS title,
       'brand-android' AS icon,
       'teal' AS color;

SELECT 'columns' AS component;
SELECT '1. Ouvrir le site' AS title,
       'teal' as icon_color,
       'world' AS icon,
       'Lancer **Google Chrome** et naviguer sur l''application BARJACar.' AS description_md;
SELECT '2. Ouvrir le menu' AS title,
       'teal' as icon_color,
       'dots-vertical' AS icon,
       'Appuyer sur les 3 petits points **⋮** en haut à droite de l''écran.' AS description_md;
SELECT '3. Installer' AS title,
       'teal' as icon_color,
       'device-desktop-down' AS icon,
       'Sélectionner **« Ajouter à l''écran d''accueil »** ou **« Installer l''application »**.' AS description_md;
SELECT '4. Confirmer' AS title,
       'teal' as icon_color,
       'device-mobile-check' AS icon,
       'Valider l''installation. L''icône BARJACar apparaît sur votre téléphone.' AS description_md;


-- 5. Tutoriel pour iOS (iPhone/iPad)
SELECT 'card' AS component,
       'Sur iPhone / iPad (iOS - Safari)' AS title,
       'brand-apple' AS icon,
       'dark' AS color;

SELECT 'columns' AS component;
SELECT '1. Ouvrir Safari' AS title,
       'teal' as icon_color,
       'brand-safari' AS icon,
       'Ouvrir obligatoirement le navigateur **Safari** sur votre iPhone.' AS description_md;
SELECT '2. Bouton Partager' AS title,
        'teal' as icon_color,
       'share-2' AS icon,
       'Appuyer sur l''icône de **Partage** (carré avec une flèche vers le haut **↑** en bas de l''écran).' AS description_md;
SELECT '3. Écran d''accueil' AS title,
       'teal' as icon_color,
       'square-plus' AS icon,
       'Faire défiler le menu vers le bas et toucher **« Sur l''écran d''accueil »**.' AS description_md;
SELECT '4. Valider' AS title,
       'teal' as icon_color,
       'device-mobile-check' AS icon,
       'Appuyer sur **« Ajouter »** en haut à droite pour finaliser.' AS description_md;


-- 6. Activation des Notifications Push
SELECT 'card' AS component,
       'Activer les notifications Push' AS title,
       'bell-ringing' AS icon,
       'orange' AS color;

SELECT 'text' AS component,
       'Une fois l''application lancée depuis votre écran d''accueil, suivez ces étapes simples :' AS contents;

SELECT 'columns' AS component;
SELECT 'Étape 1' AS title,
       'teal' as icon_color,
       'user-check' AS icon,
       'Se connecter à votre compte BARJACar.' AS description_md;
SELECT 'Étape 2' AS title,
       'teal' as icon_color,
       'user-circle' AS icon,
       'Se rendre sur la **page d''accueil** ou sur **Mon profil**. depuis le menu **Mon compte**' AS description_md;
SELECT 'Étape 3' AS title,
       'teal' as icon_color,
       'bell-plus' AS icon,
       'Cliquer sur le bouton orange **« Activer les notifications »**.' AS description_md;



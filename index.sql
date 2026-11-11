-- Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, 
       sqlpage.run_sql('shell.sql', json_object('group_id', $group_id)) AS properties;

-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' 
    as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

SELECT 'alert' as component,
    'Attention !' as title,
    'Le code est invalide. Il faut reprendre la prodédure d''inscription'  as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $code_incorrect IS NOT NULL;

-- RGPD effacement données au delà de 30 jours
UPDATE trajets
SET user_id = NULL
WHERE jour <= date('now', '-30 days');

UPDATE resa
SET user_id = NULL
WHERE user_id IS NOT NULL
  AND trajet_id IN (
      SELECT id
      FROM trajets
      WHERE jour <= datetime('now', '-30 days')
  );
  
-- Effacement des demandes dont la date a expirée
DELETE FROM besoins WHERE jour < datetime('now', '-1 days');

-- Message : retour réservation
SELECT 'alert' as component,
    'Merci !' as title,
    'La demande a bien été prise en compte. Le conducteur a été averti par courriel.' 
    as description_md,
    TRUE as dismissible,
    'car' as icon,
    'green' as color
WHERE $booking=1;

SELECT 'alert' as component,
    'Attention !' as title,
    'Cette demande ne peut pas être prise en compte faute de places suffisamment disponibles.' 
    as description_md,
    TRUE as dismissible,
    'car' as icon,
    'red' as color
WHERE $booking=0;

----------------------------------------------
--- Bannière d'accueil (Non-connectés) ---
----------------------------------------------
SELECT 'hero' AS component,
    'BARJACar' AS title,
    'Le covoiturage solidaire et gratuit à Barjac.    
    Proposez vos trajets ou trouvez un conducteur en quelques clics.' AS description_md
WHERE $group_id = 0 AND $tab is Null;

------------------------------------------------------
--- Accès rapide Connexion / Inscription  ---
------------------------------------------------------
SELECT 
    'Créer un compte' AS title,
    'Inscrivez-vous en 1 minute pour proposer ou réserver des trajets.' AS description,
    'user-plus' AS icon,
    'teal' AS color,
    '/comptes/create.sql' AS link,
    'S''inscrire' AS button
WHERE $group_id = 0 AND $tab is Null;

SELECT 
    'Déjà inscrit ?' AS title,
    'Accédez à votre espace pour gérer vos réservations et vos alertes.' AS description,
    'lock' AS icon,
    'orange' AS color,
    '/comptes/signin.sql' AS link,
    'Se connecter' AS button
WHERE $group_id = 0 AND $tab is Null;

SELECT 
    'Comment ça marche ?' AS title,
    'Découvrez le fonctionnement du covoiturage solidaire à Barjac.' AS description,
    'help' AS icon,
    'orange' AS color,
    '/aide.sql' AS link,
    'En savoir plus' AS button
WHERE $group_id = 0 AND $tab is Null;

SELECT 
    'Installer l''application' AS title,
    'Accédez à BARJACar en un clic depuis votre écran d''accueil Android ou iPhone.' AS description,
    'device-mobile-down' AS icon,
    'teal' AS color,
    '/application.sql' AS link,
    'Mode d''emploi' AS button
WHERE $group_id = 0 AND $tab is Null;

-- Dashboard
SET is_subscribed = coalesce((
    SELECT COUNT(*) 
    FROM user_push_subscriptions 
    WHERE user_id = (
        SELECT username 
        FROM login_session 
        WHERE id = sqlpage.cookie('session')
    )
), 0);

SELECT 'button' AS component 
WHERE $group_id > 0 AND $is_subscribed = 0;

SELECT 'Activer les notifications' AS title,
       '#' AS link,
       'btn-pwa-push' AS id,
       'bell' AS icon,
       'orange' AS color
WHERE $group_id > 0 AND $is_subscribed = 0;

SET unread_notifs = coalesce((
    SELECT COUNT(*) 
    FROM notifications 
    WHERE user_id = (
        SELECT username 
        FROM login_session 
        WHERE id = sqlpage.cookie('session')
    ) AND coalesce(is_read, 0) = 0
), 0);

-- Onglets
SET tab = coalesce($tab, 1);
SELECT 'tab' AS component, TRUE AS center;
SELECT '' AS title, 'leaf' AS icon, 'index.sql?tab=7' AS link, CASE WHEN $tab='7' THEN 'teal' ELSE 'secondary' END AS color;
SELECT 'Mes trajets' AS title, 'car' AS icon, 'index.sql?tab=3' AS link, CASE WHEN $tab='3' THEN 'teal' ELSE 'secondary' END AS color WHERE $group_id>0;
SELECT 'Calendrier' AS title, 'calendar' AS icon, 'index.sql?tab=2' AS link, CASE WHEN $tab='2' THEN 'teal' ELSE 'secondary' END AS color;
SELECT 'Carte' AS title, 'map-search' AS icon, 'index.sql?tab=1' AS link, CASE WHEN $tab='1' THEN 'teal' ELSE 'secondary' END AS color;
SELECT 'Besoins' AS title, 'world-question' AS icon, 'index.sql?tab=4' AS link, CASE WHEN $tab='4' THEN 'teal' ELSE 'secondary' END AS color WHERE $group_id>0;
SELECT 'Aires' AS title, 'bus-stop' AS icon, 'index.sql?tab=5' AS link, CASE WHEN $tab='5' THEN 'teal' ELSE 'secondary' END AS color;
SELECT 
    CASE WHEN $unread_notifs > 0 THEN 'Notifs (' || $unread_notifs || ')' ELSE 'Notifs' END AS title, 
    CASE WHEN $unread_notifs > 0 THEN 'bell-ringing' ELSE 'bell' END AS icon, 
    'index.sql?tab=6' AS link, 
    CASE WHEN $tab='6' THEN 'teal' ELSE 'secondary' END AS color 
WHERE $group_id > 0;

-- Chargement dynamique de l'onglet actif
SELECT 'dynamic' AS component, 
sqlpage.run_sql(
    CASE $tab
        WHEN '1' THEN 'index_onglet_1.sql'
        WHEN '2' THEN 'index_onglet_2.sql'
        WHEN '3' THEN 'index_onglet_3.sql'
        WHEN '4' THEN 'index_onglet_4.sql'
        WHEN '5' THEN 'index_onglet_5.sql'
        WHEN '6' THEN 'index_onglet_6.sql'
        WHEN '7' THEN 'index_onglet_7.sql'
        ELSE 'index_onglet_1.sql'
    END,
    json_object('group_id', $group_id, 'tab', $tab, 'stab', $stab, 'm', $m, 'y', $y, 'recherche', $recherche, 'notif_id', $notif_id)) AS properties;

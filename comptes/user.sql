SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    
SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

--Onglets
SET tab=coalesce($tab,'Mon profil');
select 'tab' as component;
select  'Mon profil' as title, 'user-circle' as icon, CASE WHEN $tab='Mon profil' THEN 1 ELSE 0 END as active, CASE WHEN $tab='Mon profil' THEN 'teal' ELSE 'secondary' END as color;
select  'Mes préférences' as title, 'map-search' as icon, CASE WHEN $tab='Mes préférences' THEN 1 ELSE 0 END as active, CASE WHEN $tab='Mes préférences' THEN 'teal' ELSE 'secondary' END as color;
select  'Mes besoins' as title, 'map-search' as icon, CASE WHEN $tab='Mes besoins' THEN 1 ELSE 0 END as active, CASE WHEN $tab='Mes besoins' THEN 'teal' ELSE 'secondary' END as color;
select  'Ma boîte à idées' as title, 'bulb' as icon, CASE WHEN $tab='Ma boîte à idées' THEN 1 ELSE 0 END as active, CASE WHEN $tab='Ma boîte à idées' THEN 'teal' ELSE 'secondary' END as color;


---- Ligne d'identification de l'utilisateur et de son mode de connexion
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));


 -- Boutons administration du profil
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'start' as justify
    where $tab='Mon profil';
select 
    'Je veux modifier mon Compte' as title,
    'comptes_user.sql' as link,
    'pencil' as icon,
    'teal' as outline
    where $tab='Mon profil';
select 
    'Je veux changer mon mot de passe' as title,
    'comptes_user_password.sql' as link,
    'lock' as icon,
    'teal' as outline
    where $tab='Mon profil';
select 
    'Je veux supprimer mon compte' as title,
    'demande.sql?user_edit='||$user_edit as link,
    'trash' as icon,
    'danger' as outline
    where $tab='Mon profil';
   
-- Profil
-- Récupération du nombre de souscriptions pour la session active
SET is_subscribed = coalesce((
    SELECT COUNT(*) 
    FROM user_push_subscriptions 
    WHERE user_id = $user_edit), 0);
/*
SELECT 'table' as component,
    'nom' as Nom,
    'prenom' as Prénom,
    'tel' as Téléphone,
    'courriel' as courriel
        where $tab='Mon profil';
SELECT 
  username as Identifiant,
  nom AS Nom,
  prenom AS Prénom,
  tel as Téléphone,
  courriel as courriel
FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';
*/
select 
    'datagrid' as component where $tab='Mon profil';;
select 
    'Identifiant' as title,
    username      as description
    FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';
select 
    'Nom' as title,
    nom          as description
    FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';
select 
    'Prénom' as title,
    prenom  as description
    FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';
select 
    'Notification' as title,
    CASE WHEN $is_subscribed>0 THEN 'teal' ELSE 'orange'  END as color,
    CASE WHEN $is_subscribed>0 THEN 'bell-ringing' ELSE 'bell-off'  END as icon,
    CASE WHEN $is_subscribed>0 THEN 'OUI' ELSE 'NON'  END as description
    FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';
select 
    'Téléphone' as title,
    tel          as description
    FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';
select 
    'Courriel' as title,
    courriel  as description
    FROM user_info WHERE username=$user_edit
    and $tab='Mon profil';

---------------------------------------------------------------
-- A. Affichage du bouton "Activer" si non abonné ($is_subscribed = 0)
SELECT 'button' AS component 
WHERE $group_id > 0 AND $is_subscribed = 0 and $tab='Mon profil';

SELECT 'Activer les notifications' AS title,
       '#' AS link,
       'btn-pwa-push' AS id,
       'bell-plus' AS icon,
       'orange' AS color
WHERE $group_id > 0 AND $is_subscribed = 0 and $tab='Mon profil';

-- B. Affichage du bouton "Désactiver" si déjà abonné ($is_subscribed > 0)
SELECT 'button' AS component 
WHERE $group_id > 0 AND $is_subscribed > 0 and $tab='Mon profil';

SELECT 'Désactiver les notifications' AS title,
       'javascript:disableNotifications();' AS link,
       'btn-pwa-push-disable' AS id,
       'bell-off' AS icon,
       'secondary' AS color
WHERE $group_id > 0 AND $is_subscribed > 0 and $tab='Mon profil';

-- Lien vers tutoriel d'installation de l'appli
SELECT 'button' AS component 
WHERE $group_id > 0 AND $is_subscribed = 0 and $tab='Mon profil';

SELECT 'Installer l''application' AS title,
       '/application.sql' AS link,
       'device-mobile-down' AS icon,
       'teal' AS color
WHERE $group_id > 0 AND $is_subscribed > 0 and $tab='Mon profil';


-- Mes Préférences 
select 
    'text'              as component,
    'Ces deux lieux te seront proposés par défaut quand tu programmeras un trajet.' as contents;
 
select 
    'card' as component,
    2  as columns WHERE $tab='Mes préférences';
select 
    '/preferences/departs.sql?_sqlpage_embed' as embed WHERE $tab='Mes préférences';
select 
    '/preferences/arrivees.sql?_sqlpage_embed' as embed  WHERE $tab='Mes préférences';

-- Mes besoins   
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab='Mes besoins';
select 
    'Je demande une destination' as title,
    '/besoin.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab='Mes besoins';

select 'list' as component,
    'Mes demandes' as title,
    '' as empty_title,
    'Pas de demandes en cours' as empty_description,
    TRUE                   as compact WHERE $tab='Mes besoins';
select 
    besoin as title,
    'map-search' as icon,
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||' '||strftime('%d/%m/%Y',jour)||' à '||strftime('%Hh%M',heure) as description,
  '/besoin_delete.sql?id='||id as delete_link
      FROM besoins WHERE user_id=$user_edit AND $tab='Mes besoins';

select 'map' as component,
  '3.410306' as longitude,
  '44.502909'as latitude,
  11 as zoom WHERE $tab='Mes besoins';

select 
  besoin as title,
  besoin_Lat as latitude,
  besoin_Lon as longitude,
  'map-search' as icon,
  '/index.sql?tab=2&recherche='||besoin as link
      FROM besoins WHERE user_id=$user_edit AND $tab='Mes besoins';
      
-- Mes Suggestions   
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab='Ma boîte à idées';
select 
    'Je signale une amélioration à apporter' as title,
    '/suggestions/suggestion.sql' as link,
    'bulb' as icon,
    'teal' as outline WHERE $tab='Ma boîte à idées';

-- Initialisation du composant list
SELECT 'list' AS component,
    'Ma boîte à idées' AS title,
    'Pas de remarque déposée' AS empty_description,
    TRUE AS compact
WHERE $tab = 'Ma boîte à idées';

-- Éléments de la liste
SELECT 
    idee || CHAR(10) || CHAR(10) || 'Réponse : ' || coalesce(reponse, 'Pas encore de réponse') AS description_md,
    CASE 
        WHEN lecture = -1 THEN 'mail'
        WHEN validation = 1 THEN 'bulb'
        WHEN validation = -1 THEN 'bulb-off'
        ELSE 'bulb'
    END AS icon,
    CASE 
        WHEN lecture = -1 THEN 1 
        ELSE 0 
    END AS active
FROM idees 
WHERE username = $user_edit 
  AND $tab = 'Ma boîte à idées';

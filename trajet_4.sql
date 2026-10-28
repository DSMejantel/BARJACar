SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;


-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' 
    as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

-- Étapes
select 
    'steps'  as component,
    TRUE     as counter,
    'teal' as color;
select 
    'Trajet' as title,
    'directions'             as icon,
    'Départ et arrivée' as description;
select 
    'Carte'   as title,
    'map-check'                 as icon,
    'Vérification sur la carte' as description;
select 
    'Aller' as title,
    'paramètres du ou des trajets' as description,
    'clock'            as icon;
select 
    'Retour' as title,
    'paramètres du ou des retours' as description,
    'history'            as icon;
select 
    'Validation' as title,
    'Enregistrement' as description,
    'check'              as icon,
    TRUE                     as active;

-- Message : validation proposition trajet
SELECT 'alert' as component,
    'Merci !' as title,
    'La proposition de trajet a bien été prise en compte.' 
    as description_md,
    TRUE as dismissible,
    'car' as icon,
    'green' as color;
    
select 
    'index.sql'       as link,
    'Retour' as title;




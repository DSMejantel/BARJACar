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
    'Départ et arrivée' as description,
    TRUE                     as active;
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
    'check'              as icon;

-- Nouveau trajet     
SELECT 
    'form' as component,
    'trajet_1.sql' as action,
    'trajet_1' as id,
    ''  as validate;
/*
SELECT 'hidden' as type, 'user' as name, user_info.username as value FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session');
SELECT 'Date' AS label, 'dep_date' AS name, 'date' as type, (select date('now')) as value, 4 as width, TRUE as required;
SELECT 'Heure d''arrivée' AS label, 'heure' AS name, 'time' as type, strftime('%H:%M','now') as value, 4 as width, TRUE as required;
SELECT 'places' AS name, 'places' AS label, 'number' AS type, 1 AS step, 1 as min, 4 as width, 1 as value, TRUE as required;
select 'switch' as type,  'Aller/Retour' as label, 'retour' as name, FALSE as checked, 1 as value;
SELECT 'aire[]' AS name, 'Aires sur le trajet' AS label, TRUE as required, 'Je sélectionne un ou plusieurs points de rencontre (voir carte ci-dessus)' as placeholder, 'select' AS type, 8 as width, true as multiple, true as dropdown, json_group_array(json_object("label" , covoit, "value", id,'selected', id IN (
                SELECT CAST(value AS INTEGER) 
                FROM json_each(COALESCE(NULLIF(:aire, ''), '[]'))))) as options FROM (select * FROM aires ORDER BY covoit ASC);
SELECT 'infos' as name, 'Précisions' as label, 12 as width;
*/
select 'user_search_D' as name, 'Ville ou adresse de DÉPART' as label, 'home' as prefix_icon, 'Code postal, adresse, COMMUNE' as description, TRUE as required, coalesce((SELECT depart FROM pref_dep WHERE user_id=(SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'))),'') as value, 6 as width; 
select 'user_search_A' as name, 'Ville ou adresse d''ARRIVÉE' as label, 'map-route' as prefix_icon, 'Code postal, adresse, COMMUNE' as description, TRUE as required, coalesce((SELECT arrivee FROM pref_arr  WHERE user_id=(SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'))),'') as value, 6 as width; 
/*
select 'select' as type, 'user_search_D' as name, 'Ville ou adresse de DÉPART' as label, 'Code postal, adresse, COMMUNE' as description, 'départ de ...' as empty_option, TRUE as dropdown, TRUE as create_new, TRUE as required, json_group_array(json_object("label" , depart, "value", depart)) as options FROM (select depart, user_id FROM pref_dep ORDER BY depart ASC) WHERE user_id=(SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')); 
select 'select' as type, 'user_search_A' as name, 'Ville ou adresse d''ARRIVÉE' as label, 'Code postal, adresse, COMMUNE' as description, 'arrivée à ...' as empty_option, TRUE as dropdown, TRUE as create_new, TRUE as required, json_group_array(json_object("label" , arrivee, "value", arrivee)) as options FROM (select arrivee, user_id FROM pref_arr ORDER BY arrivee ASC) WHERE user_id=(SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')); 
*/


   
select 
    'button' as component,
    'center' as justify;    
select 
    'trajet_1' as form,
    'trajet_1.sql' as link,
    'orange'    as outline,
    'world' as icon,
    'Proposer'  as title; 




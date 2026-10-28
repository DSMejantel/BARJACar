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
    'clock'            as icon,
    TRUE                     as active;
select 
    'Retour' as title,
    'paramètres du ou des retours' as description,
    'history'            as icon;
select 
    'Validation' as title,
    'Enregistrement' as description,
    'check'              as icon;

-- Formulaire    
select 
    'form' as component,
    'trajet' as id,
    ''  as validate,    
    'square-plus' as icon,
    'teal' as color;


select 'user_search_D' as name, 'Départ' as label, :user_search_D as value, 'home' as prefix_icon, TRUE as readonly, 4 as width;
select 'user_search_A' as name, 'Arrivée' as label, :user_search_A as value, 'map-route' as prefix_icon, TRUE as readonly, 4 as width;
SELECT 'hidden' as type, 'username' as name, user_info.username as value FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session');
SELECT 'hidden' as type, 'courriel' as name, user_info.courriel as value FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session');
SELECT 'hidden' as type, 'dep_Lon' as name, :dep_Lon as value;
SELECT 'hidden' as type, 'dep_Lat' as name, :dep_Lat as value;
SELECT 'hidden' as type, 'arr_Lon' as name, :arr_Lon as value;
SELECT 'hidden' as type, 'arr_Lat' as name, :arr_Lat as value;

SELECT 'aire[]' AS name, 'Aires sur le trajet' AS label, 'bus-stop' as prefix_icon, TRUE as required, 'Je sélectionne un ou plusieurs points de rencontre (voir carte ci-dessus)' as placeholder, 'select' AS type, 4 as width, true as multiple, true as dropdown, json_group_array(json_object("label" , covoit, "value", id,'selected', id IN (
                SELECT CAST(value AS INTEGER) 
                FROM json_each(COALESCE(NULLIF(:aire, ''), '[]'))))) as options FROM (select * FROM aires ORDER BY covoit ASC);

SELECT 'Date' AS label, 'dep_date' AS name, 'date' as type, (select date('now')) as value, 'calendar-week' as prefix_icon, 4 as width, TRUE as required;
SELECT 'Heure d''arrivée' AS label, 'heure' AS name, 'time' as type, strftime('%H:%M','now') as value, 'clock' as prefix_icon, 4 as width, TRUE as required;
SELECT 'places' AS name, 'places' AS label, 'number' AS type, 1 AS step, 1 as min, 4 as max, 'users' as prefix_icon, 4 as width, 1 as value, TRUE as required;

SELECT 'select' as type, 'recurrence' as name, 'Rythme de récurrence' as label, 'calendar-repeat' as prefix_icon, 6 as width, json_array(
    json_object('label', 'Trajet ponctuel (une seule fois)', 'value', 'none'),
    json_object('label', 'Tous les jours (jusqu''au Dimanche)', 'value', 'daily'),
    json_object('label', 'Jours ouvrés (jusqu''au Vendredi)', 'value', 'weekdays'),
    json_object('label', 'Ce jour chaque semaine', 'value', 'weekly')
) as options, COALESCE(:recurrence, 'none') as value;

-- Sélection de la durée en semaines 
SELECT 'select' as type, 'duree_semaine' as name, 'Période' as label, 'reload' as prefix_icon, 'semaine(s)' as suffix, 6 as width, json_array(
    json_object('label', '0', 'value', '0'),
    json_object('label', '1', 'value', '1'),
    json_object('label', '2', 'value', '2'),
    json_object('label', '3', 'value', '3'),
    json_object('label', '4', 'value', '4')
) as options, COALESCE(:duree_semaine, '0') as value;

select 'switch' as type,  'Prévoir le retour' as label, 'cocher pour un aller-retour' as description, 'retour' as name, FALSE as checked, 1 as value, 6 as width;

select 'switch' as type, 'Proposer aussi comme une demande' as label, 'Cocher pour publier ce trajet comme un besoin recherché' as description, 'publier_besoin' as name, FALSE as checked, 1 as value, 6 as width;
              
SELECT 'infos' as name, 'message' as prefix_icon, 'Précisions' as label, 12 as width;
  
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'trajet_3.sql' as link,
    'trajet'         as form,
    'teal'      as color,
    'checks' as icon,
    'Je valide'         as title;




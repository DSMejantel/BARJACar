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
    'Vérification sur la carte' as description,
    TRUE                     as active;
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
    
    
-- Trajet

set url = '{
    "url": "https://nominatim.openstreetmap.org/search?format=json&q=' || sqlpage.url_encode(:user_search_D) ||'",
    "headers": {"user-agent": "mobilites_barjac/1.0"} 
}'
set api_results = sqlpage.fetch($url);
set Dlat = CAST($api_results->>0->>'lat' AS FLOAT)
set Dlon = CAST($api_results->>0->>'lon' AS FLOAT)

set url = '{
    "url": "https://nominatim.openstreetmap.org/search?format=json&q=' || sqlpage.url_encode(:user_search_A) ||'",
    "headers": {"user-agent": "mobilites_barjac/1.0"} 
}'
set api_results = sqlpage.fetch($url);
set Alat = CAST($api_results->>0->>'lat' AS FLOAT)
set Alon = CAST($api_results->>0->>'lon' AS FLOAT)


  
--Carte
select 'map' as component,
  11 as zoom,
  $Alat as latitude,
  $Alon as longitude;

select 
    'Trajet'      as title,
    JSON('{"type":"LineString","coordinates":[['||CAST($Dlon as DECIMAL)||','||CAST($Dlat as DECIMAL)||'],['||CAST($Alon as DECIMAL)||','||CAST($Alat as DECIMAL)||']]}') as geojson,
    'teal'                    as color,
    :places||' place(s) proposée(s)' as description;
    
select covoit as title,
  covoit_Lat as latitude,
  covoit_Lon as longitude,
      'bus-stop' as icon
      FROM aires;

select :user_search_D as title,
  'home'   as icon,
  'teal' as color,
  $Dlat as latitude,
  $Dlon as longitude;
select :user_search_A as title,
  'car'   as icon,
  'red' as color,
  $Alat as latitude,
  $Alon as longitude;




-- Formulaire    
select 
    'form' as component,
    'trajet' as id,
    ''  as validate,    
    'square-plus' as icon,
    'teal' as color;

select 'user_search_D' as name, 'Départ' as label, :user_search_D as value, 'home' as prefix_icon, TRUE as required, 6 as width;
select 'user_search_A' as name, 'Arrivée' as label, :user_search_A as value, 'map-route' as prefix_icon, TRUE as required, 6 as width;
SELECT 'hidden' as type, 'dep_Lon' as name, $Dlon as value;
SELECT 'hidden' as type, 'dep_Lat' as name, $Dlat as value;
SELECT 'hidden' as type, 'arr_Lon' as name, $Alon as value;
SELECT 'hidden' as type, 'arr_Lat' as name, $Alat as value;


  
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'trajet_1.sql' as link,
    'trajet'            as form,
    'orange'          as outline,
    'refresh-dot' as icon,
    'Je visualise les modifications'         as title;
select 
    'trajet_2.sql' as link,
    'trajet'         as form,
    'teal'      as color,
    'checks' as icon,
    'J''ai tout vérifié et je valide'         as title;




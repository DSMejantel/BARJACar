 SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties where :retour=1;

   
-- Mise à jour des tables et enregistrement
-- Insertion multi-trajets avec prise en compte du trajet ponctuel prioritaire
INSERT INTO trajets (user_id, jour, heure, depart, arrivee, places, reserves, dep_Lon, dep_Lat, arr_Lon, arr_Lat, infos)
WITH RECURSIVE dates(d) AS (
    SELECT date(:dep_date)
    UNION ALL
    SELECT date(d, '+1 day')
    FROM dates
    WHERE 
        CASE 
            WHEN :recurrence = 'none' OR :duree_semaine = '0' THEN 0
            ELSE d < date(:dep_date, '+' || (CAST(:duree_semaine AS INTEGER) * 7) || ' day')
        END
)
SELECT 
    :username as user_id,
    d as jour,
    :heure as heure,
    :user_search_D as depart,
    :user_search_A as arrivee,
    :places as places,
    0 as reserves,
    :dep_Lon as dep_Lon,
    :dep_Lat as dep_Lat,
    :arr_Lon as arr_Lon,
    :arr_Lat as arr_Lat,
    NULLIF(:infos,'') as infos
FROM dates
WHERE 
    CASE 
        WHEN :recurrence = 'none' OR :duree_semaine = '0' THEN d = date(:dep_date)
        WHEN :recurrence = 'daily' THEN 1
        WHEN :recurrence = 'weekdays' THEN strftime('%w', d) BETWEEN '1' AND '5'
        WHEN :recurrence = 'weekly' THEN strftime('%w', d) = strftime('%w', :dep_date)
        ELSE d = date(:dep_date)
    END;

-- Association des aires pour TOUS les trajets qui viennent d'être insérés par cet utilisateur à cette date de départ initiale (ou via last_insert_rowid / filtrage récent)
-- Note : Si vous gérez plusieurs insertions d'un coup, l'association des arrets peut se faire en ciblant les trajets créés :
INSERT INTO arrets(trajet_id, aire_id)
SELECT t.id, CAST(a.value AS integer)
FROM trajets t
CROSS JOIN json_each(:aire) a
WHERE t.user_id = :username 
  AND t.jour >= date(:dep_date)
  AND t.jour <= date(:dep_date, '+' || (COALESCE(CAST(:duree_semaine AS INTEGER), 1) * 7) || ' day')
  AND NOT EXISTS (
      SELECT 1 FROM arrets ar WHERE ar.trajet_id = t.id AND ar.aire_id = CAST(a.value AS integer)
  );
  
-- Insertion conditionnelle dans la table 'besoins' si l'utilisateur a activé le switch
INSERT INTO besoins (besoin, besoin_Lon, besoin_Lat, user_id, courriel, jour, heure, precisions)
WITH RECURSIVE dates(d) AS (
    SELECT date(:dep_date)
    UNION ALL
    SELECT date(d, '+1 day')
    FROM dates
    WHERE 
        CASE 
            WHEN :recurrence = 'none' OR :duree_semaine = '0' THEN 0
            ELSE d < date(:dep_date, '+' || (CAST(:duree_semaine AS INTEGER) * 7) || ' day')
        END
)
SELECT 
    :user_search_A as besoin,
    :arr_Lon as besoin_Lon,
    :arr_Lat as besoin_Lat,
    :username as user_id,
    :courriel as courriel,
    d as jour,
    :heure as heure,
    NULLIF(:infos,'') as precisions
FROM dates
WHERE 
    CAST(COALESCE(:publier_besoin, '0') AS TEXT) IN ('1', 'on', 'true')
    AND CASE 
        WHEN :recurrence = 'none' OR :duree_semaine = '0' THEN d = date(:dep_date)
        WHEN :recurrence = 'daily' THEN 1
        WHEN :recurrence = 'weekdays' THEN strftime('%w', d) BETWEEN '1' AND '5'
        WHEN :recurrence = 'weekly' THEN strftime('%w', d) = strftime('%w', :dep_date)
        ELSE d = date(:dep_date)
    END;

/*-- Table temporaire
create temporary table if not exists alerte(besoin, user_id, courriel, bjour, bheure, precisions, pjour, pheure, arrivee);
delete from alerte; 
insert into alerte (besoin, user_id, courriel, bjour, bheure, precisions, pjour, pheure, arrivee)
SELECT 
  besoins.besoin as besoin, 
  besoins.user_id as user_id, 
  besoins.courriel as courriel, 
  besoins.jour as bjour,
  besoins.heure as bheure, 
  besoins.precisions as precisions,   
  :dep_date as pjour, 
  :heure as pheure,
  :user_search_A as arrivee
  FROM besoins WHERE :arr_Lon>(besoin_Lon-0.03) AND :arr_Lon<(besoin_Lon+0.03) AND :arr_Lat>(besoin_Lat-0.03) AND :arr_Lat<(besoin_Lat+0.03) AND besoins.jour=:dep_date AND pheure <= bheure AND besoins.user_id != :username;
*/

-- Exécution muette des envois de mail (via le fichier secondaire)
SET mail_results = sqlpage.run_sql('envoi_alerte.sql'); 

-- Redirection
    select 'redirect' AS component,
    'trajet_4.sql' AS link WHERE COALESCE(CAST(:retour AS INTEGER), 0) != 1;
    
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
    'history'            as icon,
    TRUE                     as active;
select 
    'Validation' as title,
    'Enregistrement' as description,
    'check'              as icon;



select 
    'form' as component,
    'Trajet de retour' as title,
    'trajet' as id,
    '' AS validate,
    'checks' as icon,
    'teal' as color;
select 'hidden' as type, 'retour' as name, 0 as value;
SELECT 'hidden' as type, 'publier_besoin' as name, :publier_besoin as value;
select 'user_search_D' as name, 'Départ' as label, :user_search_A as value, 'home' as prefix_icon, TRUE as required, 4 as width;
select 'user_search_A' as name, 'Arrivée' as label, :user_search_D as value, 'map-route' as prefix_icon, TRUE as required, 4 as width;
SELECT 'hidden' as type, 'dep_Lon' as name, :arr_Lon as value;
SELECT 'hidden' as type, 'dep_Lat' as name, :arr_Lat as value;
SELECT 'hidden' as type, 'arr_Lon' as name, :dep_Lon as value;
SELECT 'hidden' as type, 'arr_Lat' as name, :dep_Lat as value;

SELECT 'select' AS type, 'aire[]' AS name, 'Aires sur le trajet' AS label, TRUE as required, 'Je sélectionne un ou plusieurs points de rencontre (voir carte ci-dessus)' as placeholder, 'bus-stop' as prefix_icon, 4 as width, true as multiple, true as dropdown, json_group_array(json_object("label" , covoit, "value", id,'selected', id IN (
                SELECT CAST(value AS INTEGER) 
                FROM json_each(COALESCE(NULLIF(:aire, ''), '[]'))))) as options FROM (select * FROM aires ORDER BY covoit ASC);

SELECT 'hidden' as type, 'recurrence' as name, :recurrence as value;
SELECT 'hidden' as type, 'duree_semaine' as name, :duree_semaine as value;

SELECT 'hidden' as type, 'username' as name, user_info.username as value FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session');
SELECT 'hidden' as type, 'courriel' as name, user_info.courriel as value FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session');

SELECT 'Date' AS label, 'dep_date' AS name, 'date' as type, (select date(:dep_date)) as value, 4 as width, 'calendar-week' as prefix_icon, TRUE as required;
SELECT 'Heure d''arrivée' AS label, 'heure' AS name, 'time' as type, 4 as width, 'clock' as prefix_icon, TRUE as required;
SELECT 'places' AS name, 'places' AS label, 'users' as prefix_icon, 'number' AS type, 1 AS step, 1 as min, 4 as max, 4 as width, :places as value, TRUE as required;



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
    


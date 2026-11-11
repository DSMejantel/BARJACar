------------------------------------------------
--- Carte pour non-connectés ---
------------------------------------------------
SELECT 'map' AS component,
  'Les trajets à venir' AS title,
  '3.410306' AS longitude,
  '44.502909' AS latitude,
  11 AS zoom WHERE $group_id=0;
  
SELECT arrivee AS title,
  'car' AS icon,
  CASE WHEN (SUM(places)-SUM(reserves))=0 THEN 'red' ELSE 'green' END AS color,
  arr_Lat AS latitude,
  arr_Lon AS longitude,
CASE 
  WHEN (SUM(places) - SUM(reserves)) <= 0 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' : 0 plus de place disponible '
  WHEN (SUM(places) - SUM(reserves)) = 1 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour 1 place proposée '
  ELSE
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour ' || (SUM(places) - SUM(reserves)) || ' places proposées '
END || '[![](/icons/eye-search.svg)](/index.sql?tab=2&recherche=' || REPLACE(arrivee, ' ', '%20') || ' "je visualise les trajets")' AS description_md,
  '/index.sql?tab=2&recherche='||arrivee AS link
FROM trajets WHERE datetime(date(jour))>datetime(date('now', '-1 day')) and $group_id=0 GROUP BY arr_Lat, arr_Lon;

----------------------------------------------
--- Tableau de bord utilisateurs connectés ---
----------------------------------------------
SELECT 
    'button' AS component,
    'sm'     AS size,
    'pill'   AS shape WHERE $group_id>0;
SELECT 
    'Je propose un trajet' AS title,
    'trajet.sql' AS link,
    'circle-plus' AS icon,
    'teal' AS outline WHERE $group_id>0;
SELECT 
    'Préférences' AS title,
    'map-star' AS icon,
    '/comptes/user.sql?tab=Mes préférences' AS link,
    'teal' AS color WHERE $group_id>0;

-- Cartes des destinations
SELECT 'map' AS component,
  'Les trajets à venir' AS title,
  '3.410306' AS longitude,
  '44.502909' AS latitude,
  11 AS zoom WHERE $group_id>0;

SELECT arrivee AS title,
  'car' AS icon,
  CASE WHEN (SUM(places)-SUM(reserves))=0 THEN 'red' ELSE 'teal' END AS color,
  arr_Lat AS latitude,
  arr_Lon AS longitude,
CASE 
  WHEN (SUM(places) - SUM(reserves)) <= 0 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' : 0 plus de place disponible '
  WHEN (SUM(places) - SUM(reserves)) = 1 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour 1 place proposée '
  ELSE
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour ' || (SUM(places) - SUM(reserves)) || ' places proposées '
END || '[![](/icons/eye-search.svg)](/index.sql?tab=2&recherche=' || REPLACE(arrivee, ' ', '%20') || ' "je visualise les trajets")' AS description_md,
  '/index.sql?tab=2&recherche='||arrivee AS link
FROM trajets WHERE datetime(date(jour))>datetime(date('now', '-1 day')) and $group_id>0 GROUP BY arr_Lat, arr_Lon;

-- Liste
SELECT 
    'toast' AS component,
    'help1' AS id,
    'help1' AS trigger,
    'Aide' AS title,
    'Tu peux utiliser la barre de recherche pour trouver une destination. Clique sur ![](/icons/hand-click.svg) pour réserver' AS description_md,
    'help' AS icon,
    'teal' AS color,
    0 AS duration,
    TRUE AS dismissible
WHERE $group_id>0;
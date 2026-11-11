SELECT 'alert' AS component,
    'C''est bon !' AS title,
    'La demande de destination a bien été prise en compte.' 
    AS description_md,
    TRUE AS dismissible,
    'map-search' AS icon,
    'green' AS color
WHERE $validation=2;

SELECT 
    'toast' AS component,
    'help2' AS id,
    'help2' AS trigger,
    'Aide' AS title,
    'Tu peux demander une destination pour une date précise. Si un conducteur propose un trajet qui correspond, tu recevras un courriel immédiatement.' AS description_md,
    'help' AS icon,
    'teal' AS color,
    0 AS duration,
    TRUE AS dismissible;

SELECT 
    'button' AS component,
    'sm'     AS size,
    'pill'   AS shape WHERE $group_id>0;
SELECT 
    'Je demande une destination' AS title,
    'besoin.sql' AS link,
    'circle-plus' AS icon,
    'teal' AS outline WHERE $group_id>0;
SELECT 
    'Je gère mes demandes' AS title,
    '/comptes/user.sql?tab=Mes besoins' AS link,
    'map-search' AS icon,
    'teal' AS outline WHERE $group_id>0;
SELECT 
    'help' AS icon,
    '#help2' AS link,
    'teal' AS color;

SELECT 'map' AS component,
  'Les destinations demandées' AS title,
  '3.410306' AS longitude,
  '44.502909' AS latitude,
  11 AS zoom WHERE $group_id>0;

SELECT besoin AS title,
  besoin_Lat AS latitude,
  besoin_Lon AS longitude,
  'map-search' AS icon,
  '/index.sql?tab=2&recherche='||besoin AS link,
  CASE WHEN count(distinct id)>1 THEN count(distinct id)||' demandes pour '||besoin ELSE count(distinct id)||' demande pour '||besoin END AS description_md
FROM besoins WHERE $group_id>0 GROUP BY besoin;
      
SELECT 'list' AS component,
    'Demandes en cours' AS title,
    '' AS empty_title,
    'Pas de demandes en cours' AS empty_description,
    TRUE AS compact WHERE $group_id>0;
SELECT 
    besoin AS title,
    'map-search' AS icon,
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||' '||strftime('%d/%m/%Y',jour)||' à '||strftime('%Hh%M',heure) AS description,
    CASE WHEN user_id = (SELECT username FROM login_session WHERE id = sqlpage.cookie('session')) THEN 'besoin_delete.sql?id='||id END AS delete_link
FROM besoins WHERE $group_id>0;
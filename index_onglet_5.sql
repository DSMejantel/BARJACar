SELECT 
    'button' AS component,
    'sm'     AS size,
    'pill'   AS shape WHERE $group_id>0;
SELECT 
    'Je demande un nouveau point de covoiturage' AS title,
    '/aires/demande.sql' AS link,
    'circle-plus' AS icon,
    'teal' AS outline WHERE $group_id>0;

SELECT 'map' AS component,
  'Les lieux de covoiturage' AS title,
  '3.410306' AS longitude,
  '44.502909' AS latitude,
  11 AS zoom;

SELECT covoit AS title,
  covoit_Lat AS latitude,
  covoit_Lon AS longitude,
  'bus-stop' AS icon
FROM aires;
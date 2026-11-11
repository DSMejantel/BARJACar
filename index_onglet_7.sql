-- Info Valorisation environnementale
-- Mise à jour des trajets pour calcul CO2 épargné
UPDATE trajets 
SET 
    distance_km = ROUND(
        (6371 * ACOS(
            COS(dep_Lat * 0.0174532925) * COS(arr_Lat * 0.0174532925) * 
            COS((arr_Lon * 0.0174532925) - (dep_Lon * 0.0174532925)) + 
            SIN(dep_Lat * 0.0174532925) * SIN(arr_Lat * 0.0174532925)
        ) * 1.25), 
    1),
    co2_kg = ROUND(
        (
            (6371 * ACOS(
                COS(dep_Lat * 0.0174532925) * COS(arr_Lat * 0.0174532925) * 
                COS((arr_Lon * 0.0174532925) - (dep_Lon * 0.0174532925)) + 
                SIN(dep_Lat * 0.0174532925) * SIN(arr_Lat * 0.0174532925)
            ) * 1.25) 
            * (SELECT COALESCE(SUM(r.places), 0) FROM resa r WHERE r.trajet_id = trajets.id AND r.validation = 1)
            * 0.104
        ), 
    1)
WHERE distance_km IS NULL
  AND date(jour) <= date('now')
  AND EXISTS (
      SELECT 1 
      FROM resa r 
      WHERE r.trajet_id = trajets.id 
        AND r.validation = 1
  );
  
SELECT 
    'columns' AS component;

SELECT 
    'Impact Environnemental' AS title,
    ROUND(SUM(co2_kg), 1) || ' kg' AS value,
    'de CO2 épargné' AS small_text,
    'leaf' AS icon,
    'teal' AS icon_color,
    'orange' AS value_color,
    'Basé sur les covoiturages réalisés' AS description,
    -- Total des kilomètres partagés
    json_object(
        'icon', 'map-route', 
        'color', 'teal', 
        'description', ROUND((
            SELECT COALESCE(SUM(t.distance_km * r.places), 0)
            FROM resa r
            JOIN trajets t ON r.trajet_id = t.id
            WHERE r.validation = 1 
              AND t.co2_kg IS NOT NULL 
        ), 1) || ' km de trajets partagés'
    ) AS item,
    -- Total des passagers
    json_object(
        'icon', 'users', 
        'color', 'teal', 
        'description', 'avec ' || (
            SELECT COALESCE(SUM(r.places), 0) 
            FROM resa r
            WHERE r.validation = 1 
              AND r.trajet_id IN (SELECT id FROM trajets WHERE co2_kg IS NOT NULL)
        ) || ' passagers'
    ) AS item,
    4 AS size
FROM trajets
WHERE co2_kg IS NOT NULL;
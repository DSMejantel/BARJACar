 SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
        


UPDATE trajets SET heure=:heure
WHERE id = $trajet_id;

-- Récupérer les informations du trajet mis à jour pour alimenter les variables nécessaires aux alertes

SET dep_date = (SELECT jour FROM trajets WHERE id = $trajet_id);
SET user_search_A = (SELECT arrivee FROM trajets WHERE id = $trajet_id);
SET arr_Lon = (SELECT arr_Lon FROM trajets WHERE id = $trajet_id);
SET arr_Lat = (SELECT arr_Lat FROM trajets WHERE id = $trajet_id);

-- Exécution muette des envois de mail (via le fichier secondaire)
SET mail_results = sqlpage.run_sql('envoi_alerte.sql'); 

    
    select 'redirect' AS component,
    '/index.sql?tab=3&stab=1' AS link;
    


SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

        
SELECT 'alert' as component,
    'Modification de l''heure' as title,
    'Pour le ' || strftime('%d/%m', jour) || ' initialement à ' || strftime('%Hh%M', heure) || ' pour **' || TRIM(arrivee) || '** depuis ' || depart as description_md,
     $info AS description_md,
    'alert-circle' as icon,
    'orange' as color
    FROM trajets WHERE id = $id;

SELECT 
    'form' as component,
    'horaire' as id,
    '' AS validate,
    'clock-code' as icon,
    'teal' as color;
SELECT 'Heure d''arrivée' AS label, 'heure' AS name, 'time' as type, strftime('%H:%M', heure) as value, 4 as width FROM trajets WHERE id = $id;
 select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape,
    'center' as justify;
select 
    'horaire'         as form,
    'arrow-back-up' as icon,
    '/index.sql?tab=3&stab=1'       as link,
    'Je ne change rien' as title,
    'orange'    as color;    
select 
    'horaire'  as form,
    'clock-code' as icon,
    'trajet_clock_update.sql?trajet_id='||$id       as link,
    'Je confirme le changement' as title,
    'teal'    as color;


    


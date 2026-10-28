SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

        
SELECT 'alert' as component,
    'Annulation de trajet' as title,
    'Le ' || strftime('%d/%m', jour) || ' à ' || strftime('%Hh%M', heure) || ' pour **' || TRIM(arrivee) || '** depuis ' || depart as description_md,
     $info AS description_md,
    'alert-circle' as icon,
    'orange' as color
    FROM trajets WHERE id = $trajet_id;
select 
    '/index.sql?tab=3&stab=1'       as link,
    'Je ne change rien' as title,
    'orange'    as color;    
select 
    'trajet_delete_update.sql?trajet_id='||$trajet_id       as link,
    'Je confirme la suppression' as title,
    'secondary'    as color;


    


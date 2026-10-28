SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
 
 --Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;


select 'alert' as component,
    'Attention !' as title,
    'alert-triangle' as icon,
    'Une fois la demande prise en compte par nos services, la suppression est définitive !' as description_md,
    'red' as color;
    
   

-- Formulaire
SELECT 'form' AS component,
    '' AS title,
    'supprimer' as id,
    ''AS validate,
    'red'           as validate_color;

SELECT 'hidden' as type, 'username' AS name, (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')) as value;
SELECT 'hidden' as type, 'courriel' AS name, (SELECT user_info.courriel FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')) as value;
SELECT 'En cas de confirmation, un courriel est adressé à l''administrateur des comptes' as value, TRUE as readonly;
    
select 
    'button' as component;
select 
    'user.sql' as link,
    'supprimer'            as form,
    'orange'          as color,
    'Non, je conserve mon compte'    as title;
select 
    'demande_validation.sql' as link,
    'supprimer'            as form,
    'red'          as color,
    'Je confirme la suppression'    as title;


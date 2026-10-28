
--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

SELECT 'alert' as component,
    'Mot de passe changé !' as title,
    'Pour information,  le mot pour '|| $username ||' a bien été changé.' as description_md,
    'succes' as icon,
    'green' as color;
    



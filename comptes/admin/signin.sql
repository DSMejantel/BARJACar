--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

SELECT 'alert' as component,
    'Attention' as title,
    'Vous devez vous connecter pour accéder à ce contenu' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $error IS NOT NULL;

SELECT 'alert' as component,
    'Attention' as title,
    'Votre code d''activation n''est pas valable.' as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $activation IS NOT NULL;

SELECT 'form' AS component,
    'Connexion' AS title,
    'auth' as id,
    '' AS validate;
    --'login.sql' AS action;

SELECT 'username' AS name, 'Identifiant' as label, 4 as width;
SELECT 'code' AS name, 'Code d''activation' as label, 'text' AS type, 'Code d''activation de 1ère connexion' as placeholder, 4 as width;

select 
    'button' as component;

select 
    'comptes_user_activation.sql' as link,
    'auth'         as form,
    'orange'      as color,
    'Activer mon compte'         as title;


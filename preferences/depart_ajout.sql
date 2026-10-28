SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;


-- Formulaire
SELECT 'form' AS component,
    'Mes départs favoris' AS title,
    'pref' as id,
    ''AS validate,
    'teal'           as validate_color;

SELECT 'hidden' as type, 'username' AS name, (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')) as value;
select  'depart'   as name, 'Lieu' as label, 'code postal et lieu précis' as placeholder;
    
select 
    'button' as component;
select 
    '/preferences/depart_validation.sql' as link,
    'pref'            as form,
    'teal'          as color,
    'J''enregistre'    as title;


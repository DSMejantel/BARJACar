SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

---- Ligne d'identification de l'utilisateur et de son mode de connexion
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape;
select 
    '' as title,
    '/preferences/depart_ajout.sql' as link,
    'circle-plus' as icon,
    'teal' as outline;
    
select 'list' as component,
    'Mon départ préféré' as title,
    '' as empty_title,
    TRUE                   as compact;
select 
   depart as title,
  '/preferences/depart_delete.sql?id='||depart as delete_link    
      FROM pref_dep  WHERE user_id=$user_edit ORDER BY depart ASC;

 

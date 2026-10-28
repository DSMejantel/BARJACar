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
    '/preferences/arrivee_ajout.sql' as link,
    'circle-plus' as icon,
    'teal' as outline;
    
select 'list' as component,
    'Ma destination préférée' as title,
    '' as empty_title,
    TRUE                   as compact;
select 
   arrivee as title,
  '/preferences/arrivee_delete.sql?id='||arrivee as delete_link    
      FROM pref_arr WHERE user_id=$user_edit ORDER BY arrivee ASC;

 

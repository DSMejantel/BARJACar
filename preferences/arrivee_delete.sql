SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

---- Ligne d'identification de l'utilisateur et de son mode de connexion
SET user_edit = (SELECT login_session.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

DELETE FROM pref_arr
WHERE arrivee = $id and user_id=$user_edit;


select    'redirect'  as component,
     '/comptes/user.sql?tab=Mes préférences'  as link;







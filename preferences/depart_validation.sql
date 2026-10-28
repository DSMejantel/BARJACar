SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));

DELETE FROM pref_dep
WHERE user_id=:username;

INSERT into pref_dep(user_id, depart)
SELECT :username, :depart


select    'redirect'  as component,
     '/comptes/user.sql?tab=Mes préférences'  as link;







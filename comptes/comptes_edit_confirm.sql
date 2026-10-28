SELECT 'redirect' AS component,
        'signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

SELECT 'redirect' AS component,
        '/index.sql?restriction' AS link
        WHERE $group_id<'4';

    -- Mettre à jour le compte modifié dans la base
DELETE FROM login_session WHERE TRIM(username)=$id and :username is not null;

UPDATE user_info SET username=REPLACE(:username, ' ', ''), nom=:nom, prenom=:prenom, tel=:tel, courriel=:courriel, groupe=:groupe WHERE TRIM(username)=$id and :username is not null
 RETURNING
   'redirect' AS component,
   'comptes.sql' as link;


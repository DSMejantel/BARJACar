 SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
        

DELETE FROM arrets
WHERE trajet_id = $trajet_id;

DELETE FROM trajets
WHERE id = $trajet_id;



    
    select 'redirect' AS component,
    '/index.sql?tab=3&stab=1' AS link;
    


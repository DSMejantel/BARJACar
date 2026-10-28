
SELECT 'status_code' as component, 404 as status;

--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;






--  Bloc Principal 
SELECT 'hero' AS component,
    'Oups ! Ce chemin ne mène nulle part...' AS title,
    'La page que vous recherchez a été supprimée ou est temporairement indisponible. En langage informatique, c''est une erreur 404.' AS description,
    'map-off' AS icon;



SELECT 'Retourner à l’accueil de BARJACar' AS title,
    'Retrouvez les derniers trajets publiés.' AS description,
    'car' AS icon,
    '/' AS link;

SELECT 'Site de la Mairie de BARJAC' AS title,
    'Accéder au site officiel de la commune de Barjac-en-Lozère.' AS description,
    'building-community' AS icon,
    'https://barjac-en-lozere.fr' AS link,
    'btn-outline-secondary' AS class;

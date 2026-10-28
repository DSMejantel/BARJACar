--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

SET code=(SELECT (abs(random()) % 900000) + 100000)

-- Formulaire
SELECT 'form' AS component,
    'Je renseigne mon nom adresse de courriel' AS title,
'create_validation2.sql' AS action,
    'Je demande un nouveau code d''activation' AS validate,
    'green'           as validate_color;

SELECT 'mail' AS name, 'Adresse de courriel' as label, 6 as width, TRUE as required;
    select 'hidden' as type, 'code' as name, $code as value;



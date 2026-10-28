--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

SET code=(SELECT (abs(random()) % 900000) + 100000)


-- Formulaire
SELECT 'form' AS component,
    'Je renseigne mon nom d''utilisateur' AS title,
    'mdp' as id,
    --'create_validation.sql' AS action,
    --'Je demande un nouveau code d''activation' AS validate,
    ''AS validate,
    'green'           as validate_color;

SELECT 'username' AS name, 'Identifiant' as label, 4 as width;
    select 'hidden' as type, 'code' as name, $code as value;

select 
    'button' as component;
select 
    'create_validation.sql' as link,
    'mdp'            as form,
    'green'          as color,
    'Je demande un nouveau code d''activation'    as title;
select 
    'create_mdp2.sql' as link,
    'mdp'            as form,
    'green'          as color,
    'Je veux essayer avec mon adresse de courriel'    as title;

--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties;

SET courriel=(SELECT courriel FROM user_info WHERE courriel=:mail)
SET username=(SELECT username FROM user_info WHERE courriel=:mail)

set result = sqlpage.send_mail(json_object(
    'to', $courriel,
    'subject', 'Mot de passe oublié pour BARJACar',
    'body', 'Bonjour '||$username||' : Votre code de validation est : '||:code
))

select 'alert' as component,
    case when json_extract($result, '$.status') = 'accepted' then 'Opération validée' else 'Attention' end as title,
    case when json_extract($result, '$.status') = 'accepted' then 'success' else 'danger' end as color,
    case when json_extract($result, '$.status') = 'accepted' then 'Un code de validation a été envoyé à cette adresse : '||$courriel else 'Cette adresse n''a pas été trouvée dans notre base.' end as description;

select 'Retour' as title, '/comptes/mdp/create.sql'  as link WHERE json_extract($result, '$.status') <> 'accepted';


SELECT 'form' AS component,
    'Validation de mon compte utilisateur' AS title,
'create_verification.sql' AS action,
    'Vérification' AS validate,
    'green'           as validate_color
    WHERE $courriel<>'';

-- Formulaire
SELECT 'hidden' as type, 'username' AS name, $username as value WHERE $courriel<>'';
SELECT 'Code de validation :' AS label, 'validation' AS name, 'password' AS type, 'saisir le code reçu par courriel' as placeholder WHERE $courriel<>'';
select 'hidden' as type, 'code' as name, :code as value WHERE $courriel<>'';



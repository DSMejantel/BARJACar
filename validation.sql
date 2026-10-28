SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
SET group_id = (SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'));

--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, sqlpage.run_sql('shell.sql') AS properties where :message is Null;

SELECT 'alert' as component,
    '' as title,
    TRUE as dismissible,
    CASE WHEN (select validation FROM resa WHERE id=$id)=1 THEN 'Tu peux joindre un message à cette annulation. Il sera envoyé à ton passager dans le mail d''information.' ELSE 'Tu peux joindre un message à cette validation. Il sera envoyé à ton passager dans le mail de confirmation.' END as description_md,
    'mail' as icon,
    CASE WHEN (select validation FROM resa WHERE id=$id)=1 THEN 'orange' ELSE 'teal' END as color
    where :message is Null;

select 
    'form' as component,
    '' as validate,
    'valider' as id where :message is Null;
    
select 
    'message' as name,
    'Message pour votre passager :' as label,
    'par exemple : heure de rendez-vous sur le point de rencontre choisi...' as description,
    'text'    as type where :message is Null;
select 
    'button' as component where :message is Null;
select 
    '' as link,
    'valider'         as form,
    'teal'      as color,
    CASE WHEN (select validation FROM resa WHERE id=$id)=1 THEN 'Annuler cette réservation' ELSE 'Valider le passager' END as title where :message is Null;
select 
    'index.sql?tab=3&stab=1' as link,
    'valider'            as form,
    'secondary'          as outline,
    'Retour'         as title where :message is Null;

 UPDATE resa SET validation=(select validation FROM resa WHERE id=$id)*(-1) WHERE id=$id and :message is not Null;
 
 set result = sqlpage.send_mail(json_object(
    'to', (SELECT courriel FROM resa WHERE resa.id=$id) ,
    'subject', 'Mise à jour de votre réservation',
    'body_md', (CASE WHEN (SELECT validation FROM resa WHERE resa.id=$id)=1 THEN 'Bonjour, '|| char(10) || char(10) ||'**'||( SELECT trajets.user_id FROM trajets JOIN resa on trajets.id=resa.trajet_id WHERE resa.id=$id)||'** a validé votre demande de covoiturage par '||(SELECT covoit FROM aires JOIN resa on resa.aire=aires.id  WHERE resa.id=$id)||' pour ' ELSE 'Bonjour, '|| char(10) || char(10) ||'Votre réservation de covoiturage a été **annulée** pour ' END)||(SELECT arrivee FROM trajets JOIN resa on trajets.id=resa.trajet_id WHERE resa.id=$id)||' le **'||(SELECT strftime('%d/%m/%Y',jour)||'**' FROM trajets JOIN resa on trajets.id=resa.trajet_id WHERE resa.id=$id)|| char(10) || char(10) ||:message
));

INSERT INTO notifications (user_id, title, message)
SELECT 
    user_id,
    'Modification du statut de votre réservation',
    (CASE 
        WHEN validation = 1 THEN 'Votre demande de covoiturage a été confirmée pour ' 
        ELSE 'Votre réservation de covoiturage a été annulée pour ' 
    END)||(SELECT arrivee FROM trajets JOIN resa on trajets.id=resa.trajet_id WHERE resa.id=$id)||' le **'||(SELECT strftime('%d/%m/%Y',jour)||'**' FROM trajets JOIN resa on trajets.id=resa.trajet_id WHERE resa.id=$id)|| '. ' ||:message
FROM resa 
WHERE id = $id 
  AND sqlpage.request_method() = 'POST' -- Exécute l'INSERT uniquement lors de la soumission !
LIMIT 1;
 
 SELECT 'redirect' as component,
 'index.sql?tab=3' as link where :message is not Null;

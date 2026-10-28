-- 1. Contrôle d'accès
SELECT 'redirect' AS component,
       '/comptes/signin.sql?error' AS link
WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id = sqlpage.cookie('session'));

-- 2. Récupération des données AVANT la suppression
SET libere = (SELECT places FROM resa WHERE id = $delete_id);
SET passager = (SELECT user_id FROM resa WHERE id = $delete_id);

-- 3. Suppression de la réservation et mise à jour des places
DELETE FROM resa WHERE id = $delete_id;

UPDATE trajets 
SET reserves= reserves - coalesce($libere, 0)
WHERE id = $trajet_id;

-- 4. Envoi du courriel au conducteur
SET result = sqlpage.send_mail(json_object(
    'to', (SELECT courriel FROM user_info JOIN trajets ON user_info.username = trajets.user_id WHERE trajets.id = $trajet_id),
    'subject', 'Réservation annulée sur BARJACar',
    'body_md', 'Bonjour, ' || CHAR(10) || CHAR(10) || '**' || coalesce($passager, 'Un passager') || '** a annulé l''offre de covoiturage pour ' || (SELECT arrivee FROM trajets WHERE id = $trajet_id) || ' **le ' || (SELECT strftime('%d/%m/%Y', jour) FROM trajets WHERE id = $trajet_id) || '**.'
));

-- 5. Insertion de la notification pour le conducteur
INSERT INTO notifications (user_id, title, message)
SELECT 
    user_id,
    'Réservation annulée sur BARJACar',
    'Le passager '||coalesce($passager, 'Un passager') || ' a annulé la réservation pour ' || arrivee || ' le ' || strftime('%d/%m/%Y', jour) || '.'
FROM trajets 
WHERE id = $trajet_id;

-- 6. Redirection
SELECT 'redirect' AS component,
       '/index.sql?tab=3&stab=2' AS link;

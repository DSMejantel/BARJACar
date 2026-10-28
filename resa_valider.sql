-- 1. Contrôle d'accès : redirection si non connecté
SELECT 'redirect' AS component,
       '/comptes/signin.sql?error' AS link
WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id = sqlpage.cookie('session'));

-- 2. Récupération du pseudo de l'utilisateur connecté
SET current_user = (
    SELECT username 
    FROM login_session 
    WHERE id = sqlpage.cookie('session')
);

-- 3. Vérification des places disponibles
SELECT 'redirect' AS component,
       'index.sql?id=' || :id || '&tab=2&booking=0' AS link
WHERE (SELECT places - coalesce(reserves, 0) - CAST(:places AS INTEGER) FROM trajets WHERE id = :id) < 0;

-- 4. S'assurer que la réservation n'est traitée que lors d'un POST (soumission de formulaire)
-- Et que l'utilisateur est bien identifié
UPDATE trajets 
SET reserves = coalesce(reserves, 0) + CAST(:places AS INTEGER) 
WHERE id = :id 
  AND sqlpage.request_method() = 'POST'
  AND $current_user IS NOT NULL;

-- 5. Enregistrement de la réservation
INSERT INTO resa (user_id, trajet_id, places, aire, tel, courriel, validation, infos)
SELECT 
    $current_user, 
    :id, 
    CAST(:places AS INTEGER), 
    :aire, 
    :tel, 
    :courriel, 
    -1, 
    NULLIF(:infos, '')
WHERE sqlpage.request_method() = 'POST'
  AND $current_user IS NOT NULL;

-- 6. Envoi du mail au conducteur
SET result = sqlpage.send_mail(json_object(
    'to', (SELECT courriel FROM user_info JOIN trajets ON user_info.username = trajets.user_id WHERE trajets.id = :id),
    'subject', 'Réservation à confirmer sur BARJACar',
    'body_md', 'Bonjour,' || CHAR(10) || CHAR(10) || '**' || $current_user || '** souhaite profiter de l''offre de covoiturage pour **' || (SELECT arrivee FROM trajets WHERE id = :id) || '** le ' || (SELECT strftime('%d/%m/%Y', jour) FROM trajets WHERE id = :id) || '.' || CHAR(10) || CHAR(10) || 'Vous pouvez lui confirmer et l''avertir en allant sur **[BARJACar](https://covoiturage.barjac-en-lozere.fr)**.'
));

-- 7. Notification interne pour le conducteur (sécurisée contre les NULL)
INSERT INTO notifications (user_id, title, message)
SELECT 
    user_id, 
    'Réservation à confirmer sur BARJACar',
    $current_user || ' souhaite profiter de l''offre de covoiturage pour ' || arrivee || ' le ' || strftime('%d/%m/%Y', jour) || coalesce('.' || CHAR(10) || 'Précisions : ' || NULLIF(:infos, ''), '.')
FROM trajets 
WHERE id = :id 
  AND sqlpage.request_method() = 'POST'
  AND $current_user IS NOT NULL;

-- 8. Redirection de succès
SELECT 'redirect' AS component,
       'index.sql?id=' || :id || '&tab=2&booking=1' AS link;

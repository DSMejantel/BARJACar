-- 1. Récupération de l'utilisateur connecté
SET user_id = (
    SELECT username 
    FROM login_session 
    WHERE id = sqlpage.cookie('session')
);

-- 2. Format JSON exclusif (aucun composant redirect ou shell)
SELECT 'json' AS component;

-- 3. Suppression des souscriptions Push de l'utilisateur
DELETE FROM user_push_subscriptions 
WHERE user_id = $user_id;

-- 4. Retour JSON pour le JS
SELECT 
    CASE 
        WHEN $user_id IS NOT NULL THEN 'success' 
        ELSE 'error' 
    END AS status,
    CASE 
        WHEN $user_id IS NOT NULL THEN 'Désabonnement effectué avec succès' 
        ELSE 'Session expirée' 
    END AS message;

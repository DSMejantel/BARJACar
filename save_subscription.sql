-- 1. Récupération de l'utilisateur connecté dans une variable
SET user_id = (
    SELECT username 
    FROM login_session 
    WHERE id = sqlpage.cookie('session')
);

-- 2. Configuration du composant JSON
SELECT 'json' AS component;

-- 3. Validation de la session et exécution de l'action
INSERT INTO user_push_subscriptions (
    user_id,
    endpoint,
    p256dh,
    auth
)
SELECT 
    $user_id,
    :endpoint,
    :p256dh,
    :auth
WHERE $user_id IS NOT NULL -- S'assure que l'utilisateur est bien authentifié
ON CONFLICT(endpoint) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    p256dh = EXCLUDED.p256dh,
    auth = EXCLUDED.auth,
    created_at = CURRENT_TIMESTAMP;

-- 4. Réponse JSON conditionnelle
SELECT 
    CASE 
        WHEN $user_id IS NOT NULL THEN 'success' 
        ELSE 'error' 
    END AS status,
    CASE 
        WHEN $user_id IS NOT NULL THEN 'Abonnement aux notifications enregistré' 
        ELSE 'Session expirée ou utilisateur non connecté' 
    END AS message;

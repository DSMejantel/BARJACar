CREATE TABLE user_push_subscriptions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,            -- ID de l'utilisateur dans ton app
    endpoint TEXT NOT NULL UNIQUE,       -- URL unique fournie par le navigateur (Push Service)
    p256dh TEXT NOT NULL,                -- Clé publique du navigateur pour le chiffrement
    auth TEXT NOT NULL,                  -- Secret d'authentification
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    sent_at DATETIME DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES user_info(username) ON DELETE CASCADE
);



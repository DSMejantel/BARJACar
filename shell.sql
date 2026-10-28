SELECT 'shell' as component,
    'BARJACar' as title,
    '/' as link,
    --'car' as icon,
    '/img/barjacar_192.png' as image,
    '/css/theme_01.css' as css,
    'Covoiturage avec BARJACar — [Mentions légales](/mentions/mentions_legales.sql) — [Politique de confidentialité](/mentions/politique_confidentialite.sql)' as footer,
    '/favicon.ico' as favicon,
    'fr-FR' as language,
    'fluid' as layout,
    FALSE as norobot,
    'Plateforme de covoiturage solidaire et local de la commune de Barjac (48) et de la vallée du LOT.' as description,
    '/manifest.json' as manifest,
    json_array('/js/app.js', '/js/pwa-notifications.js', '/js/password.js') AS javascript,
     '/js/rich_text_editor.js' as javascript_module,
    -- Menu dynamique selon le profil utilisateur
    CASE 
        WHEN $group_id = 4 THEN json_array(
            json_object('link', '/index.sql', 'title', 'Tableau de bord', 'icon', 'clipboard-list'),
            json_object('title', 'Covoiturage', 'icon', 'car', 'submenu', json_array(
                json_object('link', '/trajet.sql', 'title', 'Proposer un trajet'),
                json_object('link', '/besoin.sql', 'title', 'Demander un trajet'),
                json_object('link', '/index.sql?tab=1', 'title', 'Carte des destinations'),
                json_object('link', '/index.sql?tab=3', 'title', 'Gérer mon covoiturage'),
                json_object('link', '/aires.sql', 'title', 'Aires de covoiturage')
            )),
            json_object('link', '/aide.sql', 'title', 'Aide', 'icon', 'help'),
            json_object('title', 'Comptes', 'icon', 'users-group', 'submenu', json_array(
                json_object('link', '/comptes/comptes.sql', 'title', 'Liste'),
                json_object('link', '/comptes/comptes_ajout.sql', 'title', 'Ajouter')
            )),
            json_object('title', 'Mon compte', 'icon', 'user', 'submenu', json_array(
                json_object('link', '/comptes/user.sql?tab=Mon profil', 'title', 'Mon Profil'),
                json_object('link', '/comptes/user.sql?tab=Mes préférences', 'title', 'Mes préférences'),
                json_object('link', '/comptes/user.sql?tab=Mes besoins', 'title', 'Mes besoins'),
                json_object('link', '/comptes/logout.sql', 'title', 'Se déconnecter')
            ))
        )

        WHEN $group_id = 1 THEN json_array(
            json_object('link', '/index.sql', 'title', 'Tableau de bord', 'icon', 'clipboard-list'),
            json_object('title', 'Covoiturage', 'icon', 'car', 'submenu', json_array(
                json_object('link', '/trajet.sql', 'title', 'Proposer un trajet'),
                json_object('link', '/besoin.sql', 'title', 'Demander un trajet'),
                json_object('link', '/index.sql?tab=1', 'title', 'Carte des destinations'),
                json_object('link', '/aires/demande.sql', 'title', 'Demander un nouveau point de covoiturage'),
                json_object('link', '/index.sql?tab=3', 'title', 'Gérer mon covoiturage')
            )),
            json_object('link', '/aide.sql', 'title', 'Aide', 'icon', 'help'),
            json_object('title', 'Mon compte', 'icon', 'user', 'submenu', json_array(
                json_object('link', '/comptes/user.sql?tab=Mon profil', 'title', 'Mon Profil'),
                json_object('link', '/comptes/user.sql?tab=Mes préférences', 'title', 'Mes préférences'),
                json_object('link', '/comptes/user.sql?tab=Mes besoins', 'title', 'Mes besoins'),
                json_object('link', '/comptes/user.sql?tab=Mes suggestions', 'title', 'Ma boîte à idées'),
                json_object('link', '/comptes/logout.sql', 'title', 'Se déconnecter')
            ))
        )

        ELSE json_array(
            json_object('link', '/aide.sql', 'title', 'Aide', 'icon', 'help'),
            json_object('title', 'Connexion', 'icon', 'lock', 'submenu', json_array(
                json_object('link', '/comptes/signin.sql', 'title', 'Se connecter'),
                json_object('link', '/comptes/create.sql', 'title', 'Créer un compte')
            ))
        )
    END AS menu_item;

--Menu
SET group_id = coalesce((SELECT user_info.groupe FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')),0);    

SELECT 'dynamic' AS component, 
       sqlpage.run_sql('shell.sql', json_object('group_id', $group_id)) AS properties;

-- Message si droits insuffisants sur une page
SELECT 'alert' as component,
    'Attention !' as title,
    'Vous ne possédez pas les droits suffisants pour accéder à cette page.' 
    as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $restriction IS NOT NULL;

SELECT 'alert' as component,
    'Attention !' as title,
    'Le code est invalide. Il faut reprendre la prodédure d''inscription'  as description_md,
    'alert-circle' as icon,
    'red' as color
WHERE $code_incorrect IS NOT NULL;


-- RGPD effacement données au delà de 30 jours
UPDATE trajets
SET user_id = NULL
WHERE jour <= date('now', '-30 days');

UPDATE resa
SET user_id = NULL
WHERE user_id IS NOT NULL
  AND trajet_id IN (
      SELECT id
      FROM trajets
      WHERE jour <= datetime('now', '-30 days')
  );
  
-- Effacement des demandes dont la date a expirée
DELETE FROM besoins WHERE jour < datetime('now', '-1 days');

-- Message : retour réservation
SELECT 'alert' as component,
    'Merci !' as title,
    'La demande a bien été prise en compte. Le conducteur a été averti par courriel.' 
    as description_md,
    TRUE as dismissible,
    'car' as icon,
    'green' as color
WHERE $booking=1;

SELECT 'alert' as component,
    'Attention !' as title,
    'Cette demande ne peut pas être prise en compte faute de places suffisamment disponibles.' 
    as description_md,
    TRUE as dismissible,
    'car' as icon,
    'red' as color
WHERE $booking=0;

----------------------------------------------
--- Bannière d'accueil (Non-connectés) ---
----------------------------------------------
SELECT 'hero' AS component,
    'BARJACar' AS title,
    'Le covoiturage solidaire et gratuit à Barjac.    
    Proposez vos trajets ou trouvez un conducteur en quelques clics.' AS description_md
WHERE $group_id = 0 AND $tab is Null;

------------------------------------------------------
--- Accès rapide Connexion / Inscription  ---
------------------------------------------------------


SELECT 
    'Créer un compte' AS title,
    'Inscrivez-vous en 1 minute pour proposer ou réserver des trajets.' AS description,
    'user-plus' AS icon,
    'teal' AS color,
    '/comptes/create.sql' AS link,
    'S''inscrire' AS button
    WHERE $group_id = 0 AND $tab is Null;

SELECT 
    'Déjà inscrit ?' AS title,
    'Accédez à votre espace pour gérer vos réservations et vos alertes.' AS description,
    'lock' AS icon,
    'orange' AS color,
    '/comptes/signin.sql' AS link,
    'Se connecter' AS button
    WHERE $group_id = 0 AND $tab is Null;
SELECT 
    'Comment ça marche ?' AS title,
    'Découvrez le fonctionnement du covoiturage solidaire à Barjac.' AS description,
    'help' AS icon,
    'orange' AS color,
    '/aide.sql' AS link,
    'En savoir plus' AS button
    WHERE $group_id = 0 AND $tab is Null;
SELECT 
    'Installer l''application' AS title,
    'Accédez à BARJACar en un clic depuis votre écran d''accueil Android ou iPhone.' AS description,
    'device-mobile-down' AS icon,
    'teal' AS color,
    '/application.sql' AS link,
    'Mode d''emploi' AS button
WHERE $group_id = 0 AND $tab is Null;


--Dashboard
-- Récupération du nombre de souscriptions pour la session active
SET is_subscribed = coalesce((
    SELECT COUNT(*) 
    FROM user_push_subscriptions 
    WHERE user_id = (
        SELECT username 
        FROM login_session 
        WHERE id = sqlpage.cookie('session')
    )
), 0);

-- Affichage du bouton au-dessus des onglets (si connecté ET non abonné)
SELECT 'button' AS component 
WHERE $group_id > 0 AND $is_subscribed = 0;

SELECT 'Activer les notifications' AS title,
       '#' AS link,
       'btn-pwa-push' AS id,
       'bell' AS icon,
       'orange' AS color
WHERE $group_id > 0 AND $is_subscribed = 0;

-- Compteur de notifications non lues pour l'utilisateur connecté
SET unread_notifs = coalesce((
    SELECT COUNT(*) 
    FROM notifications 
    WHERE user_id = (
        SELECT username 
        FROM login_session 
        WHERE id = sqlpage.cookie('session')
    ) AND coalesce(is_read, 0) = 0
), 0);

--Onglets
SET tab=coalesce($tab,'1');
select 'tab' as component, TRUE as center;
select  'Mes trajets' as title, 'car' as icon, 'index.sql?tab=3' as link, CASE WHEN $tab='3' THEN 'teal' ELSE 'secondary' END as color where $group_id>0;
select  'Calendrier' as title, 'calendar' as icon, 'index.sql?tab=2' as link, CASE WHEN $tab='2' THEN 'teal' ELSE 'secondary' END as color;
select  'Carte'  as title, 'map-search' as icon, 'index.sql?tab=1' as link, CASE WHEN $tab='1' THEN 'teal' ELSE 'secondary' END as color;
select  'Besoins' as title, 'world-question' as icon, 'index.sql?tab=4' as link, CASE WHEN $tab='4' THEN 'teal' ELSE 'secondary' END as color where $group_id>0;
select  'Aires' as title, 'bus-stop' as icon, 'index.sql?tab=5' as link, CASE WHEN $tab='5' THEN 'teal' ELSE 'secondary' END as color;
select  
    CASE 
        WHEN $unread_notifs > 0 THEN 'Notifs (' || $unread_notifs || ')' 
        ELSE 'Notifs' 
    END as title, 
    CASE 
        WHEN $unread_notifs > 0 THEN 'bell-ringing' 
        ELSE 'bell' 
    END as icon, 
    'index.sql?tab=6' as link, 
    CASE WHEN $tab='6' THEN 'orange' ELSE 'secondary' END as color 
where $group_id > 0;
select  '' as title, 'leaf' as icon, 'index.sql?tab=7' as link, CASE WHEN $tab='7' THEN 'teal' ELSE 'secondary' END as color;
--------------------------------
--- Carte pour non-connectés ---
--------------------------------
select 'map' as component,
  'Les trajets à venir' as title,
  '3.410306' as longitude,
  '44.502909'as latitude,
  11 as zoom WHERE $tab=1 and $group_id=0;
  
select arrivee as title,
  'car' as icon,
  CASE WHEN (SUM(places)-SUM(reserves))=0 THEN 'red' ELSE 'green' END as color,
  arr_Lat as latitude,
  arr_Lon as longitude,
CASE 
  WHEN (SUM(places) - SUM(reserves)) <= 0 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' : 0 plus de place disponible '
  WHEN (SUM(places) - SUM(reserves)) = 1 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour 1 place proposée '
  ELSE
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour ' || (SUM(places) - SUM(reserves)) || ' places proposées '
END || '[![](/icons/eye-search.svg)](/index.sql?tab=2&recherche=' || REPLACE(arrivee, ' ', '%20') || ' "je visualise les trajets")' AS description_md,
  '/index.sql?tab=2&recherche='||arrivee as link
      FROM trajets WHERE $tab=1 and datetime(date(jour))>datetime(date('now', '-1 day')) and $group_id=0 GROUP BY arr_Lat, arr_Lon;

-- 1. Déclaration du composant calendrier (Non-connectés)
-- code unifié


/*SELECT 
    'table'          as component,
    TRUE             as sort,
    TRUE             as search,
    'Date' as markdown,
    'Trajet' as markdown,
    'Pas de trajet proposé pour le moment' as empty_description,
    'Places' as icon,
    coalesce($recherche,'')  as initial_search_value,
    'Filtrer par destination' as search_placeholder
    WHERE $tab=2 and $group_id=0;
    
SELECT
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||CHAR(10)||CHAR(10)||strftime('%d',jour)||' '||(SELECT mois FROM calendrier WHERE position= strftime('%m',jour))||CHAR(10)||CHAR(10)||strftime('%Hh%M',heure) as Date,
    arrivee||CHAR(10)||CHAR(10)||'depuis '||depart as Trajet,
    --(places-reserves) as Places,
    CASE WHEN (places-reserves)>0 THEN 'teal' ELSE 'red'   END as _sqlpage_color,
    CASE WHEN (places-reserves)=3 THEN 'users-group'
    WHEN (places-reserves)=2 THEN 'users'
    WHEN (places-reserves)=1 THEN 'user' ELSE 'car-off' END  as Places
    FROM trajets WHERE $tab=2 and datetime(date(jour))>datetime(date('now', '-1 day')) and $group_id=0 ORDER BY jour;
*/    

----------------------------------------------
--- Tableau de bord utilisateurs connectés ---
----------------------------------------------
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=1 and $group_id>0;
select 
    'Je propose un trajet' as title,
    'trajet.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab=1 and $group_id>0;
select 
    'Préférences' as title,
    'map-star' as icon,
    '/comptes/user.sql?tab=Mes préférences'      as link,
    'teal'  as color WHERE $tab=1 and $group_id>0;

-- Cartes des destinations
select 'map' as component,
  'Les trajets à venir' as title,
  '3.410306' as longitude,
  '44.502909'as latitude,
  11 as zoom WHERE $tab=1 and $group_id>0;

select arrivee as title,
  'car'   as icon,
  CASE WHEN (SUM(places)-SUM(reserves))=0 THEN 'red' ELSE 'teal' END as color,
  arr_Lat as latitude,
  arr_Lon as longitude,
CASE 
  WHEN (SUM(places) - SUM(reserves)) <= 0 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' : 0 plus de place disponible '
  WHEN (SUM(places) - SUM(reserves)) = 1 THEN
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour 1 place proposée '
  ELSE
    COUNT(DISTINCT id) || CASE WHEN COUNT(DISTINCT id) > 1 THEN ' trajets' ELSE ' trajet' END 
    || ' pour ' || (SUM(places) - SUM(reserves)) || ' places proposées '
END || '[![](/icons/eye-search.svg)](/index.sql?tab=2&recherche=' || REPLACE(arrivee, ' ', '%20') || ' "je visualise les trajets")' AS description_md,
  '/index.sql?tab=2&recherche='||arrivee as link
      FROM trajets WHERE $tab=1 and datetime(date(jour))>datetime(date('now', '-1 day')) and $group_id>0  GROUP BY arr_Lat, arr_Lon;

--Liste
select 
    'toast'             as component,
    'help1' as id,
    'help1'  as trigger,
    'Aide'    as title,
    'Tu peux utiliser la barre de recherche pour trouver une destination. Clique sur ![](/icons/hand-click.svg) pour réserver' as description_md,
    'help'    as icon,
    'teal'             as color,
    0                   as duration,
    TRUE                as dismissible;
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=2 and $group_id>0;
select 
    'Je propose un trajet' as title,
    'trajet.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab=2 and $group_id>0;
select 
    'Préférences' as title,
    'map-star' as icon,
    '/comptes/user.sql?tab=Mes préférences'      as link,
    'teal' as color WHERE $tab=2 and $group_id>0;
select 
    'help' as icon,
    '#help1'      as link,
    'teal'                    as color;

-- Calendrier code unifié pour connectés et non-connectés
-- 1. Déclaration unique du composant calendrier
SELECT 
    'calendrier' AS component,
    CASE COALESCE(NULLIF($m, ''), strftime('%m', 'now'))
        WHEN '01' THEN 'Janvier' WHEN '1' THEN 'Janvier'
        WHEN '02' THEN 'Février' WHEN '2' THEN 'Février'
        WHEN '03' THEN 'Mars' WHEN '3' THEN 'Mars'
        WHEN '04' THEN 'Avril' WHEN '4' THEN 'Avril'
        WHEN '05' THEN 'Mai' WHEN '5' THEN 'Mai'
        WHEN '06' THEN 'Juin' WHEN '6' THEN 'Juin'
        WHEN '07' THEN 'Juillet' WHEN '7' THEN 'Juillet'
        WHEN '08' THEN 'Août' WHEN '8' THEN 'Août'
        WHEN '09' THEN 'Septembre' WHEN '9' THEN 'Septembre'
        WHEN '10' THEN 'Octobre' WHEN '11' THEN 'Novembre' WHEN '12' THEN 'Décembre'
    END || ' ' || COALESCE(NULLIF($y, ''), strftime('%Y', 'now')) AS title,
    COALESCE($recherche, '') AS initial_search_value,
    'Filtrer par destination' AS search_placeholder,
    COALESCE($tab, 2) AS tab_val,
    COALESCE($group_id, 0) AS group_val,
    COALESCE(NULLIF($m, ''), strftime('%m', 'now')) AS m_val,
    COALESCE(NULLIF($y, ''), strftime('%Y', 'now')) AS y_val,

    printf('?tab=%s&group_id=%s&recherche=%s&m=%s&y=%s', 
        COALESCE($tab,2), COALESCE($group_id,0), COALESCE($recherche,''),
        strftime('%m', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '-1 month')),
        strftime('%Y', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '-1 month'))
    ) AS prev_url,
    
    printf('?tab=%s&group_id=%s&recherche=%s&m=%s&y=%s', 
        COALESCE($tab,2), COALESCE($group_id,0), COALESCE($recherche,''),
        strftime('%m', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '+1 month')),
        strftime('%Y', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '+1 month'))
    ) AS next_url
WHERE $tab = 2;


-- 2. Table temporaire de la grille du mois
CREATE TEMP TABLE IF NOT EXISTS grille_mois (
    type TEXT, semaine_num INT, jour_num TEXT, jour_texte_mobile TEXT, jour_date TEXT, is_today INT, ligne_ord INT, col_ord INT
);
DELETE FROM grille_mois;

WITH RECURSIVE
params AS (SELECT COALESCE(NULLIF($y, ''), strftime('%Y', 'now')) AS annee, COALESCE(NULLIF($m, ''), strftime('%m', 'now')) AS mois),
dates_calc AS (SELECT printf('%04d-%02d-01', annee, mois) AS premier_jour, date(printf('%04d-%02d-01', annee, mois), '+1 month', '-1 day') AS dernier_jour FROM params),
jours_mois(jour_date) AS (SELECT premier_jour FROM dates_calc UNION ALL SELECT date(jour_date, '+1 day') FROM jours_mois, dates_calc WHERE jour_date < dernier_jour),
decalage(nb_cases_vides) AS (SELECT (CAST(strftime('%w', premier_jour) AS INT) + 6) % 7 FROM dates_calc),
cases_vides(n) AS (SELECT 1 FROM decalage WHERE nb_cases_vides > 0 UNION ALL SELECT n + 1 FROM cases_vides, decalage WHERE n < decalage.nb_cases_vides)
INSERT INTO grille_mois
SELECT 'semaine', (SELECT CAST(strftime('%W', premier_jour) AS INT) FROM dates_calc), NULL, NULL, NULL, 0, (SELECT CAST(strftime('%W', premier_jour) AS INT) FROM dates_calc), 0 FROM dates_calc
UNION ALL
SELECT 'vide', NULL, NULL, NULL, NULL, 0, (SELECT CAST(strftime('%W', premier_jour) AS INT) FROM dates_calc), n FROM cases_vides
UNION ALL
SELECT DISTINCT 'semaine', CAST(strftime('%W', j.jour_date) AS INT), NULL, NULL, NULL, 0, CAST(strftime('%W', j.jour_date) AS INT), 0 FROM jours_mois j JOIN dates_calc d ON j.jour_date > d.premier_jour WHERE (CAST(strftime('%w', j.jour_date) AS INT) + 6) % 7 = 0
UNION ALL
SELECT 'jour', NULL, strftime('%d', j.jour_date),
    (CASE strftime('%w', j.jour_date) WHEN '1' THEN 'Lundi' WHEN '2' THEN 'Mardi' WHEN '3' THEN 'Mercredi' WHEN '4' THEN 'Jeudi' WHEN '5' THEN 'Vendredi' WHEN '6' THEN 'Samedi' WHEN '0' THEN 'Dimanche' END || ' ' || strftime('%d', j.jour_date) || ' ' || CASE SUBSTR(j.jour_date, 6, 2) WHEN '01' THEN 'Janvier' WHEN '02' THEN 'Février' WHEN '03' THEN 'Mars' WHEN '04' THEN 'Avril' WHEN '05' THEN 'Mai' WHEN '06' THEN 'Juin' WHEN '07' THEN 'Juillet' WHEN '08' THEN 'Août' WHEN '09' THEN 'Septembre' WHEN '10' THEN 'Octobre' WHEN '11' THEN 'Novembre' WHEN '12' THEN 'Décembre' END),
    j.jour_date, CASE WHEN j.jour_date = date('now') THEN 1 ELSE 0 END, CAST(strftime('%W', j.jour_date) AS INT), (CAST(strftime('%w', j.jour_date) AS INT) + 6) % 7 + 1
FROM jours_mois j;


-- 3. Requête finale avec distinction stricte connectés / non-connectés
SELECT 
    g.type, g.semaine_num, g.jour_num, g.jour_texte_mobile, g.is_today, g.ligne_ord, g.col_ord,
    GROUP_CONCAT(
        CASE WHEN t.id IS NOT NULL THEN
            CASE 
                -- CAS 1 : CONNECTÉ ($group_id > 0) -> Avec lien cliquable et icône de clic (hand-click.svg)
                WHEN $group_id > 0 THEN
                    printf(
                        '<a href="%s" class="event-compact %s"><div class="event-dest">➔ %s</div><div class="event-dep"><img src="/icons/logout.svg" alt="départ" /> %s</div><div class="event-meta"><span>arrivée %s</span><span>%s <img src="/icons/hand-click.svg" alt="clic" /></span></div></a>',
                        CASE WHEN (t.places - t.reserves) > 0 THEN printf('resa.sql?id=%d', t.id) ELSE '#' END,
                        CASE WHEN (t.places - t.reserves) <= 0 THEN 'complet' ELSE '' END,
                        TRIM(t.arrivee),
                        TRIM(t.depart),
                        strftime('%Hh%M', t.heure),
                        CASE 
                            WHEN (t.places - t.reserves) > 2 THEN '<img src="/icons/users-group.svg" alt="3+"/>'
                            WHEN (t.places - t.reserves) = 2 THEN '<img src="/icons/users.svg" alt="2"/>'
                            WHEN (t.places - t.reserves) = 1 THEN '<img src="/icons/user.svg" alt="1"/>'
                            ELSE '<img src="/icons/car-off.svg" alt="complet"/>'
                        END
                    )
                -- CAS 2 : NON-CONNECTÉ ($group_id = 0 ou vide) -> STRICTEMENT STATIQUE, sans <a>, sans hand-click
                ELSE
                    printf(
                        '<div class="event-compact %s"><div class="event-dest">➔ %s</div><div class="event-dep"><img src="/icons/logout.svg" alt="départ" /> %s</div><div class="event-meta"><span>%s</span></div></div>',
                        CASE WHEN (t.places - t.reserves) <= 0 THEN 'complet' ELSE '' END,
                        TRIM(t.arrivee),
                        TRIM(t.depart),
                        strftime('%Hh%M', t.heure),
                        CASE 
                            WHEN (t.places - t.reserves) >= 3 THEN '<img src="/icons/users-group.svg" alt="3+"/>'
                            WHEN (t.places - t.reserves) = 2 THEN '<img src="/icons/users.svg" alt="2"/>'
                            WHEN (t.places - t.reserves) = 1 THEN '<img src="/icons/user.svg" alt="1"/>'
                            ELSE '<img src="/icons/car-off.svg" alt="complet"/>'
                        END
                    )
            END
        END,
        '' ORDER BY t.heure ASC
    ) AS liste_trajets
FROM grille_mois g
LEFT JOIN trajets t ON date(t.jour) = g.jour_date 
   AND date(t.jour) >= date('now') 
   AND $tab = 2 
   AND ($recherche IS NULL OR $recherche = '' OR lower(t.arrivee) LIKE '%' || lower($recherche) || '%' OR lower(t.depart) LIKE '%' || lower($recherche) || '%')
GROUP BY g.ligne_ord, g.col_ord
ORDER BY g.ligne_ord ASC, g.col_ord ASC;

/*
SELECT 
    'table'          as component,
    TRUE             as sort,
    TRUE             as search,
    TRUE    as freeze_headers,
    'Pas de trajet proposé pour le moment' as empty_description,
    'Date' as markdown,
    'Trajet' as markdown,
    'Résa' as markdown,
    'Conducteur' as markdown,
    coalesce($recherche,'')  as initial_search_value,
    'Filtrer par destination' as search_placeholder
    WHERE $tab=2 and $group_id>0;
    
SELECT
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||CHAR(10)||CHAR(10)||strftime('%d',jour)||' '||(SELECT mois FROM calendrier WHERE position= strftime('%m',jour))||CHAR(10)||CHAR(10)||strftime('%Hh%M',heure) as Date,
        CASE WHEN (places-reserves)>2 
    THEN '![3 places](/icons/users-group.svg)'
    WHEN (places-reserves)=2 
    THEN '![2 places](/icons/users.svg)'
    WHEN (places-reserves)=1 
    THEN '![1 place](/icons/user.svg)'
    ELSE '![complet](/icons/car-off.svg)' END  as Résa,
    CASE 
  WHEN (places - reserves) > 1 THEN 
    '[ ![](/icons/hand-click.svg)](resa.sql?id=' || id || ' "Je réserve (' || (places - reserves) || ' places disponibles)")'
  WHEN (places - reserves) = 1 THEN 
    '[ ![](/icons/hand-click.svg)](resa.sql?id=' || id || ' "Je réserve (1 place disponible)")'
  ELSE NULL 
END AS Résa,
    '**'||TRIM(arrivee)||'**'||CHAR(10)||CHAR(10)||'depuis '||depart||CHAR(10)||CHAR(10)||'avec '||user_id||CHAR(10) || CHAR(10)||'Infos : '||coalesce(infos,'Pas de précisions particulières') as Trajet,
    CASE WHEN (places-reserves)>0 THEN 'teal' ELSE 'red'   END as _sqlpage_color

    FROM trajets WHERE $tab=2 and datetime(date(jour))>datetime(date('now', '-1 day')) and $group_id>0 ORDER BY jour;

*/    

--- Les besoins

-- Message : validation proposition trajet
SELECT 'alert' as component,
    'C''est bon !' as title,
    'La demande de destination a bien été prise en compte.' 
    as description_md,
    TRUE as dismissible,
    'map-search' as icon,
    'green' as color
WHERE $tab=4 and $validation=2;

select 
    'toast'             as component,
    'help2' as id,
    'help2'  as trigger,
    'Aide'    as title,
    'Tu peux demander une destination pour une date précise. Si un conducteur propose un trajet qui correspond, tu recevras un courriel immédiatement.' as description_md,
    'help'    as icon,
    'teal'             as color,
    0                   as duration,
    TRUE                as dismissible;

select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=4 and $group_id>0;
select 
    'Je demande une destination' as title,
    'besoin.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab=4 and $group_id>0;
select 
    'Je gère mes demandes' as title,
    '/comptes/user.sql?tab=Mes besoins' as link,
    'map-search' as icon,
    'teal' as outline WHERE $tab=4 and $group_id>0;
select 
    'help' as icon,
    '#help2'      as link,
    'teal'                    as color;

select 'map' as component,
  'Les destinations demandées' as title,
  '3.410306' as longitude,
  '44.502909'as latitude,
  11 as zoom WHERE $tab=4 and $group_id>0;

select besoin as title,
  besoin_Lat as latitude,
  besoin_Lon as longitude,
      'map-search' as icon,
  '/index.sql?tab=2&recherche='||besoin as link,
    CASE WHEN count(distinct id)>1 THEN count(distinct id)||' demandes pour '||besoin ELSE count(distinct id)||' demande pour '||besoin END as description_md
      FROM besoins WHERE $tab=4 and $group_id>0 GROUP BY besoin;
      
select 'list' as component,
    'Demandes en cours' as title,
    '' as empty_title,
    'Pas de demandes en cours' as empty_description,
    TRUE as compact WHERE $tab=4 and $group_id>0;
select 
    besoin as title,
    'map-search' as icon,
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||' '||strftime('%d/%m/%Y',jour)||' à '||strftime('%Hh%M',heure) as description,
    CASE WHEN user_id = (SELECT username FROM login_session WHERE id = sqlpage.cookie('session')) THEN 'besoin_delete.sql?id='||id END as delete_link
      FROM besoins WHERE $tab=4 and $group_id>0; 
      
-- Cartes des Aires
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=5 and $group_id>0;
select 
    'Je demande un nouveau point de covoiturage' as title,
    '/aires/demande.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab=5 and $group_id>0;

select 'map' as component,
  'Les lieux de covoiturage' as title,
  '3.410306' as longitude,
  '44.502909'as latitude,
  11 as zoom WHERE $tab=5;

select covoit as title,
  covoit_Lat as latitude,
  covoit_Lon as longitude,
      'bus-stop' as icon
      FROM aires WHERE $tab=5;
      

-- Mes trajets
--Sous-Onglets
SET CONDUCT= (SELECT count(trajets.id) FROM trajets join login_session on login_session.username=trajets.user_id WHERE login_session.id = sqlpage.cookie('session')  and datetime(date(jour))>datetime(date('now', '-1 day')))
SET PASSAG = (SELECT count(resa.id) FROM resa join trajets on trajets.id=resa.trajet_id  join login_session on login_session.username=resa.user_id WHERE login_session.id = sqlpage.cookie('session') and datetime(date(jour))>datetime(date('now', '-1 day')) )
SET STAB_INTRO= (SELECT 1 WHERE $CONDUCT >= $PASSAG);
SET STAB_INTRO= (SELECT 2 WHERE $CONDUCT < $PASSAG);
SET stab=coalesce($stab,coalesce($STAB_INTRO,1));

select 'tab' as component, TRUE as center WHERE $tab=3;
select  'Je suis CONDUCTEUR'  as title, --'steering-wheel' as icon, 
'index.sql?tab=3&stab=1' as link, CASE WHEN $stab=1 THEN TRUE ELSE FALSE END as active, CASE WHEN $stab=1 THEN 'orange' ELSE 'secondary' END as color  WHERE $tab=3;
select  'Je suis PASSAGER' as title, --'bus-stop' as icon, 
'index.sql?tab=3&stab=2' as link, CASE WHEN $stab=2 THEN TRUE ELSE FALSE END as active, CASE WHEN $stab=2 THEN 'orange' ELSE 'secondary' END as color WHERE $tab=3;

-- conducteur
    
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=3 and $stab=1 and $group_id>0;
select 
    'Je propose un trajet' as title,
    'trajet.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab=3 and $stab=1 and $group_id>0;
select 
    'Préférences' as title,
    'map-star' as icon,
    '/comptes/user.sql?tab=Mes préférences'      as link,
    'teal' as color WHERE $tab=3 and $stab=1 and $group_id>0;

--Message
/*SELECT 'alert' as component,
    'Penses-y !' as title,
    TRUE as dismissible,
    'N''oublie pas de valider tes passagers pour confirmer le covoiturage. Un mail leur sera envoyé automatiquement.' 
    as description_md,
    'bus-stop' as icon,
    'green' as color
    FROM login_session join trajets on login_session.username=trajets.user_id  
    WHERE $tab=3 and $stab=1 and login_session.id = sqlpage.cookie('session') GROUP BY user_id ;
*/   
select 
    'toast'                   as component,
    'toast-auto'              as id,
    'Info Conducteur' as title,
    'N''oublie pas de valider tes passagers pour confirmer le covoiturage :'||CHAR(10)||CHAR(10)||'Change le statut de ![](/icons/toggle--1.svg) vers ![](/icons/toggle-1.svg) '||CHAR(10)||CHAR(10)||'Un mail leur sera envoyé automatiquement.' as description_md,
    'bulb'                   as icon,
    'orange'                   as color
    FROM login_session join trajets on login_session.username=trajets.user_id left join resa on trajets.id=resa.trajet_id
    WHERE $tab=3 and $stab=1 and login_session.id = sqlpage.cookie('session') and datetime(date(jour))>datetime(date('now')) GROUP BY trajets.user_id HAVING count(resa.trajet_id)>0;
    


select 
    'columns' as component WHERE $tab=3 and $stab=1;
select 
    arrivee as title,
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||CHAR(10)||CHAR(10)||strftime('%d',jour)||' '||(SELECT mois FROM calendrier WHERE position= strftime('%m',jour)) as value,
    strftime('%Hh%M',heure) as small_text,
    CASE WHEN reserves=1 THEN'user' WHEN reserves=2 THEN 'users' WHEN reserves=3 THEN 'users-group' ELSE '' END as icon,
    'teal' as icon_color,
    CASE WHEN reserves=0 THEN '[
    ![](/icons/clock-code.svg)
](trajet_clock.sql?id='||trajets.id||')'||' modification de l''heure'||CHAR(10)||CHAR(10) END as description_md,
    coalesce(group_concat(('![passager](/icons/user-'||resa.places||'-'||validation||'.svg)'||' '||resa.user_id||' - '||covoit|| ('[
    ![](/icons/toggle-'||validation||'.svg)
](validation.sql?id='||resa.id||')')||CHAR(10)||CHAR(10)||coalesce(resa.infos,'')||CHAR(10)||CHAR(10)||(resa.tel||' '||resa.courriel)), CHAR(10)||CHAR(10)),'Aucun passager') as description_md,
    'teal'               as value_color,
    CASE WHEN reserves=0 THEN '/trajet_delete.sql?trajet_id='||trajets.id    END as link,
    CASE WHEN reserves=0 THEN 'Supprimer' END  as button_text,
    CASE WHEN reserves=0 THEN 'orange'  END   as button_color
        FROM trajets LEFT JOIN resa on resa.trajet_id=trajets.id JOIN user_info on trajets.user_id=username LEFT JOIN aires on aires.id=resa.aire WHERE trajets.user_id=(SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session') and  $tab=3 and $stab=1) and datetime(date(jour))>datetime(date('now', '-1 day')) and  $tab=3  and $stab=1 GROUP BY trajets.id ORDER BY jour,heure ASC;
    
-- passager
select 
    'button' as component,
    'sm'     as size,
    'pill'   as shape WHERE $tab=3 and $stab=2 and $group_id>0;
select 
    'Je demande une destination' as title,
    'besoin.sql' as link,
    'circle-plus' as icon,
    'teal' as outline WHERE $tab=3 and $stab=2 and $group_id>0;

select 
    'columns' as component WHERE $tab=3 and $stab=2;
select 
    arrivee as title,
    strftime('%d/%m',jour) as value,
    strftime('%Hh%M',heure) as small_text,
    'bus-stop' as icon,
    'teal' as icon_color,
    json_object('icon','steering-wheel','color','teal','description',trajets.user_id) as item,
    json_object('icon','info-circle','color','teal','description',coalesce(trajets.infos,'pas d''infos')) as item,
        json_object('icon','phone','color','teal','description',coalesce(user_info.tel,'')) as item,
    json_object('icon','mail','color','teal','description',coalesce(user_info.courriel,'-')) as item,
CASE 
  WHEN validation = 1 THEN 
    '![validé](/icons/toggle-1.svg) Validé' || CHAR(10) || CHAR(10) || covoit
  ELSE 
    '![en attente](/icons/toggle--1.svg) En attente' || CHAR(10) || CHAR(10) || covoit
END AS description_md,
    'teal'               as value_color,
    '/resa_delete.sql?trajet_id='||trajets.id||'&delete_id='||resa.id                     as link,
    'Annuler'   as button_text,
    'orange'                  as button_color
    FROM trajets JOIN resa on resa.trajet_id=trajets.id JOIN user_info on trajets.user_id=username JOIN aires on aires.id=resa.aire WHERE resa.user_id=(SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session'))  and  $tab=3  and $stab=2 and datetime(date(jour))>datetime(date('now', '-1 day')) and  $tab=3  and $stab=2 ORDER BY jour,heure ASC;
         
--- Onglet 6 : Mes Notifications ---
-- A. Traitement : Marquer comme lu si un ID est passé en paramètre
UPDATE notifications 
SET is_read = 1 
WHERE id = $notif_id 
  AND user_id = (
      SELECT username 
      FROM login_session 
      WHERE id = sqlpage.cookie('session')
  );

-- B. Affichage du composant MODAL si une notification est sélectionnée
SELECT 'modal' AS component,
       'Message du '||(SELECT journee FROM semainier WHERE position= strftime('%w',created_at))||CHAR(10)||CHAR(10)||strftime('%d',created_at)||' '||(SELECT mois FROM calendrier WHERE position= strftime('%m',created_at))||' à '||strftime('%Hh%M',created_at) AS title,
       'Messagerie' as id, 
       'Fermer' as close
FROM notifications 
WHERE id = $notif_id 
  AND user_id = (
      SELECT username 
      FROM login_session 
      WHERE id = sqlpage.cookie('session')
  ) AND $tab=6 AND $group_id>0;


SELECT 
    '**'||title||'**'||CHAR(10)||CHAR(10)||message AS contents_md
FROM notifications 
WHERE id = $notif_id 
  AND user_id = (
      SELECT username 
      FROM login_session 
      WHERE id = sqlpage.cookie('session')
  ) AND $tab=6 AND $group_id>0;


-- C. Liste principale des notifications
SELECT 'list' AS component,
    'Mes notifications' AS title,
    'Aucune notification' AS empty_title,
    'Vous n''avez aucune notification pour le moment.' AS empty_description,
    TRUE AS compact 
WHERE $tab=6 AND $group_id>0;

SELECT 
    title,
    CASE 
        WHEN LENGTH(message) > 60 THEN SUBSTR(message, 1, 60) || '...' 
        ELSE message 
    END AS description,
    strftime('%d/%m/%Y à %Hh%M', created_at) AS timestamp,
    CASE 
        WHEN coalesce(is_read, 0) = 0 THEN TRUE 
        ELSE FALSE 
    END AS active,
    CASE 
        WHEN coalesce(is_read, 0) = 0 THEN 'bell-ringing' 
        ELSE 'bell-off' 
    END AS icon,
    CASE 
        WHEN coalesce(is_read, 0) = 0 THEN 'orange' 
        ELSE 'secondary' 
    END AS color,
    -- Lien qui recharge la page avec l'ID de la notification
    'index.sql?tab=6&notif_id=' || id ||'#Messagerie' AS link
FROM notifications 
WHERE user_id = (
    SELECT username 
    FROM login_session 
    WHERE id = sqlpage.cookie('session')
) AND $tab=6 AND $group_id>0
ORDER BY created_at DESC;

----
-- Info Valorisation environnementale
-- Mise à jour des trajets pour calcul CO2 épargné
UPDATE trajets 
SET 
    distance_km = ROUND(
        (6371 * ACOS(
            COS(dep_Lat * 0.0174532925) * COS(arr_Lat * 0.0174532925) * 
            COS((arr_Lon * 0.0174532925) - (dep_Lon * 0.0174532925)) + 
            SIN(dep_Lat * 0.0174532925) * SIN(arr_Lat * 0.0174532925)
        ) * 1.25), 
    1),
    co2_kg = ROUND(
        (
            (6371 * ACOS(
                COS(dep_Lat * 0.0174532925) * COS(arr_Lat * 0.0174532925) * 
                COS((arr_Lon * 0.0174532925) - (dep_Lon * 0.0174532925)) + 
                SIN(dep_Lat * 0.0174532925) * SIN(arr_Lat * 0.0174532925)
            ) * 1.25) 
            * (SELECT COALESCE(SUM(r.places), 0) FROM resa r WHERE r.trajet_id = trajets.id AND r.validation = 1)
            * 0.104
        ), 
    1)
WHERE distance_km IS NULL
  AND date(jour) <= date('now')
  AND EXISTS (
      SELECT 1 
      FROM resa r 
      WHERE r.trajet_id = trajets.id 
        AND r.validation = 1 and $tab=7
  );
  
select 
    'columns' as component
    where $tab=7;
select 
    'Impact Environnemental'  as title,
    ROUND(SUM(co2_kg), 1)||' kg'   as value,
    'de CO2 épargné'                      as small_text,
    'leaf-2'         as icon,
    'teal' AS icon_color,
     'orange' AS value_color,
    'Basé sur les covoiturages réalisés' as description,
    json_object('icon','map-route','color','teal','description',ROUND(SUM(distance_km), 1)||' km de trajets partagés') as item,
    json_object('icon','users','color','teal','description','avec '||SUM(reserves)||' passagers') as item,
    4 as size
    FROM trajets WHERE co2_kg IS NOT NULL and $tab=7;


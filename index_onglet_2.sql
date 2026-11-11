SELECT 
    'button' AS component,
    'sm'     AS size,
    'pill'   AS shape WHERE $group_id>0;
SELECT 
    'Je propose un trajet' AS title,
    'trajet.sql' AS link,
    'circle-plus' AS icon,
    'teal' AS outline WHERE $group_id>0;
SELECT 
    'Préférences' AS title,
    'map-star' AS icon,
    '/comptes/user.sql?tab=Mes préférences' AS link,
    'teal' AS color WHERE $group_id>0;
SELECT 
    'help' AS icon,
    '#help1' AS link,
    'teal' AS color
WHERE $group_id>0;

SELECT 
    'toast' AS component,
    'help1' AS id,
    'help1' AS trigger,
    'Aide' AS title,
    'Tu peux utiliser la barre de recherche pour trouver une destination. Clique sur ![](/icons/hand-click.svg) pour réserver' AS description_md,
    'help' AS icon,
    'teal' AS color,
    0 AS duration,
    TRUE AS dismissible
WHERE $group_id>0;

-- Calendrier code unifié pour connectés et non-connectés
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
    2 AS tab_val,
    COALESCE($group_id, 0) AS group_val,
    COALESCE(NULLIF($m, ''), strftime('%m', 'now')) AS m_val,
    COALESCE(NULLIF($y, ''), strftime('%Y', 'now')) AS y_val,

    printf('?tab=2&group_id=%s&recherche=%s&m=%s&y=%s', 
        COALESCE($group_id,0), COALESCE($recherche,''),
        strftime('%m', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '-1 month')),
        strftime('%Y', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '-1 month'))
    ) AS prev_url,
    
    printf('?tab=2&group_id=%s&recherche=%s&m=%s&y=%s', 
        COALESCE($group_id,0), COALESCE($recherche,''),
        strftime('%m', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '+1 month')),
        strftime('%Y', date(printf('%04d-%02d-01', COALESCE(NULLIF($y, ''), strftime('%Y', 'now')), COALESCE(NULLIF($m, ''), strftime('%m', 'now'))), '+1 month'))
    ) AS next_url;

-- Table temporaire de la grille du mois
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

-- Requête finale avec distinction connectés / non-connectés
SELECT 
    g.type, g.semaine_num, g.jour_num, g.jour_texte_mobile, g.is_today, g.ligne_ord, g.col_ord,
    GROUP_CONCAT(
        CASE WHEN t.id IS NOT NULL THEN
            CASE 
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
   AND ($recherche IS NULL OR $recherche = '' OR lower(t.arrivee) LIKE '%' || lower($recherche) || '%' OR lower(t.depart) LIKE '%' || lower($recherche) || '%')
GROUP BY g.ligne_ord, g.col_ord
ORDER BY g.ligne_ord ASC, g.col_ord ASC;
-- Sous-Onglets Conducteur / Passager
SET CONDUCT = (SELECT count(trajets.id) FROM trajets join login_session on login_session.username=trajets.user_id WHERE login_session.id = sqlpage.cookie('session') and datetime(date(jour))>datetime(date('now', '-1 day')));
SET PASSAG = (SELECT count(resa.id) FROM resa join trajets on trajets.id=resa.trajet_id join login_session on login_session.username=resa.user_id WHERE login_session.id = sqlpage.cookie('session') and datetime(date(jour))>datetime(date('now', '-1 day')));
SET STAB_INTRO = (SELECT 1 WHERE $CONDUCT >= $PASSAG);
SET STAB_INTRO = (SELECT 2 WHERE $CONDUCT < $PASSAG);
SET stab = coalesce($stab, coalesce($STAB_INTRO, 1));

SELECT 'tab' AS component, TRUE AS center;
SELECT 'Je suis CONDUCTEUR' AS title, 'index.sql?tab=3&stab=1' AS link, CASE WHEN $stab=1 THEN TRUE ELSE FALSE END AS active, CASE WHEN $stab=1 THEN 'orange' ELSE 'secondary' END AS color;
SELECT 'Je suis PASSAGER' AS title, 'index.sql?tab=3&stab=2' AS link, CASE WHEN $stab=2 THEN TRUE ELSE FALSE END AS active, CASE WHEN $stab=2 THEN 'orange' ELSE 'secondary' END AS color;

-- Conducteur ($stab = 1)
SELECT 
    'button' AS component,
    'sm'     AS size,
    'pill'   AS shape WHERE $stab=1 and $group_id>0;
SELECT 
    'Je propose un trajet' AS title,
    'trajet.sql' AS link,
    'circle-plus' AS icon,
    'teal' AS outline WHERE $stab=1 and $group_id>0;
SELECT 
    'Préférences' AS title,
    'map-star' AS icon,
    '/comptes/user.sql?tab=Mes préférences' AS link,
    'teal' AS color WHERE $stab=1 and $group_id>0;

SELECT 
    'toast' AS component,
    'toast-auto' AS id,
    'Info Conducteur' AS title,
    'N''oublie pas de valider tes passagers pour confirmer le covoiturage :'||CHAR(10)||CHAR(10)||'Change le statut de ![](/icons/toggle--1.svg) vers ![](/icons/toggle-1.svg) '||CHAR(10)||CHAR(10)||'Un mail leur sera envoyé automatiquement.' AS description_md,
    'bulb' AS icon,
    'orange' AS color
FROM login_session join trajets on login_session.username=trajets.user_id left join resa on trajets.id=resa.trajet_id
WHERE $stab=1 and login_session.id = sqlpage.cookie('session') and datetime(date(jour))>datetime(date('now')) GROUP BY trajets.user_id HAVING count(resa.trajet_id)>0;

SELECT 
    'columns' AS component WHERE $stab=1;
SELECT 
    arrivee AS title,
    (SELECT journee FROM semainier WHERE position= strftime('%w',jour))||CHAR(10)||CHAR(10)||strftime('%d',jour)||' '||(SELECT mois FROM calendrier WHERE position= strftime('%m',jour)) AS value,
    strftime('%Hh%M',heure) AS small_text,
    CASE WHEN reserves=1 THEN 'user' WHEN reserves=2 THEN 'users' WHEN reserves=3 THEN 'users-group' ELSE '' END AS icon,
    'teal' AS icon_color,
    CASE WHEN reserves=0 THEN '[![](/icons/clock-code.svg)](trajet_clock.sql?id='||trajets.id||')'||' modification de l''heure'||CHAR(10)||CHAR(10) END AS description_md,
    coalesce(group_concat(('![passager](/icons/user-'||resa.places||'-'||validation||'.svg)'||' '||resa.user_id||' - '||covoit|| ('[![](/icons/toggle-'||validation||'.svg)](validation.sql?id='||resa.id||')')||CHAR(10)||CHAR(10)||coalesce(resa.infos,'')||CHAR(10)||CHAR(10)||(resa.tel||' '||resa.courriel)), CHAR(10)||CHAR(10)),'Aucun passager') AS description_md,
    'teal' AS value_color,
    CASE WHEN reserves=0 THEN '/trajet_delete.sql?trajet_id='||trajets.id END AS link,
    CASE WHEN reserves=0 THEN 'Supprimer' END AS button_text,
    CASE WHEN reserves=0 THEN 'orange' END AS button_color
FROM trajets LEFT JOIN resa on resa.trajet_id=trajets.id JOIN user_info on trajets.user_id=username LEFT JOIN aires on aires.id=resa.aire 
WHERE trajets.user_id=(SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')) and $stab=1 and datetime(date(jour))>datetime(date('now', '-1 day')) GROUP BY trajets.id ORDER BY jour,heure ASC;

-- Passager ($stab = 2)
SELECT 
    'button' AS component,
    'sm'     AS size,
    'pill'   AS shape WHERE $stab=2 and $group_id>0;
SELECT 
    'Je demande une destination' AS title,
    'besoin.sql' AS link,
    'circle-plus' AS icon,
    'teal' AS outline WHERE $stab=2 and $group_id>0;

SELECT 
    'columns' AS component WHERE $stab=2;
SELECT 
    arrivee AS title,
    strftime('%d/%m',jour) AS value,
    strftime('%Hh%M',heure) AS small_text,
    'bus-stop' AS icon,
    'teal' AS icon_color,
    json_object('icon','steering-wheel','color','teal','description',trajets.user_id) AS item,
    json_object('icon','info-circle','color','teal','description',coalesce(trajets.infos,'pas d''infos')) AS item,
    json_object('icon','phone','color','teal','description',coalesce(user_info.tel,'')) AS item,
    json_object('icon','mail','color','teal','description',coalesce(user_info.courriel,'-')) AS item,
CASE 
  WHEN validation = 1 THEN '![validé](/icons/toggle-1.svg) Validé' || CHAR(10) || CHAR(10) || covoit
  ELSE '![en attente](/icons/toggle--1.svg) En attente' || CHAR(10) || CHAR(10) || covoit
END AS description_md,
    'teal' AS value_color,
    '/resa_delete.sql?trajet_id='||trajets.id||'&delete_id='||resa.id AS link,
    'Annuler' AS button_text,
    'orange' AS button_color
FROM trajets JOIN resa on resa.trajet_id=trajets.id JOIN user_info on trajets.user_id=username JOIN aires on aires.id=resa.aire 
WHERE resa.user_id=(SELECT user_info.username FROM login_session join user_info on user_info.username=login_session.username WHERE id = sqlpage.cookie('session')) and $stab=2 and datetime(date(jour))>datetime(date('now', '-1 day')) ORDER BY jour,heure ASC;
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
       'Messagerie' AS id, 
       'Fermer' AS close
FROM notifications 
WHERE id = $notif_id 
  AND user_id = (
      SELECT username 
      FROM login_session 
      WHERE id = sqlpage.cookie('session')
  ) AND $group_id>0;

SELECT 
    '**'||title||'**'||CHAR(10)||CHAR(10)||message AS contents_md
FROM notifications 
WHERE id = $notif_id 
  AND user_id = (
      SELECT username 
      FROM login_session 
      WHERE id = sqlpage.cookie('session')
  ) AND $group_id>0;

-- C. Liste principale des notifications
SELECT 'list' AS component,
    'Mes notifications' AS title,
    'Aucune notification' AS empty_title,
    'Vous n''avez aucune notification pour le moment.' AS empty_description,
    TRUE AS compact 
WHERE $group_id>0;

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
    'index.sql?tab=6&notif_id=' || id ||'#Messagerie' AS link
FROM notifications 
WHERE user_id = (
    SELECT username 
    FROM login_session 
    WHERE id = sqlpage.cookie('session')
) AND $group_id>0
ORDER BY created_at DESC;
SELECT 'redirect' AS component,
        '/comptes/signin.sql?error' AS link
 WHERE NOT EXISTS (SELECT 1 FROM login_session WHERE id=sqlpage.cookie('session'));
 
 -- Table temporaire
create temporary table if not exists alerte(besoin, user_id, courriel, bjour, bheure, precisions, pjour, pheure, arrivee);
delete from alerte; 
insert into alerte (besoin, user_id, courriel, bjour, bheure, precisions, pjour, pheure, arrivee)
SELECT 
  besoins.besoin as besoin, 
  besoins.user_id as user_id, 
  besoins.courriel as courriel, 
  besoins.jour as bjour,
  besoins.heure as bheure, 
  besoins.precisions as precisions,   
  :dep_date as pjour, 
  :heure as pheure,
  :user_search_A as arrivee
  FROM besoins WHERE :arr_Lon>(besoin_Lon-0.03) AND :arr_Lon<(besoin_Lon+0.03) AND :arr_Lat>(besoin_Lat-0.03) AND :arr_Lat<(besoin_Lat+0.03) AND besoins.jour=:dep_date AND pheure <= bheure 
  AND besoins.user_id != (SELECT user_info.username FROM login_session JOIN user_info ON user_info.username = login_session.username WHERE id = sqlpage.cookie('session'));


--Mailing des besoins
SELECT sqlpage.send_mail(json_object(
    'to', courriel,
    'subject', 'Alerte BARJACar',
    'body_md', 'Bonjour, '||'**'||user_id||'**'|| char(10) || char(10) ||' Un conducteur propose un trajet vers une de vos destinations demandées :  '|| char(10) || char(10) ||'**' || arrivee || '**, le ' || strftime('%d/%m/%Y',pjour) || ' pour une arrivée vers ' || pheure||'.  Vous pouvez consulter **[BARJACar](https://covoiturage.barjac-en-lozere.fr)** pour réserver votre place.'
)) FROM alerte WHERE courriel IS NOT NULL AND courriel != ''

INSERT INTO notifications (user_id, title, message)
SELECT 
user_id as user_id, 
'Proposition de trajet' as title, 
' Un conducteur propose un trajet vers une de vos destinations demandées :  '|| arrivee || ', le ' || strftime('%d/%m/%Y',pjour) || ' pour une arrivée vers ' || pheure||'.' as message
FROM alerte WHERE courriel IS NOT NULL AND courriel != '';

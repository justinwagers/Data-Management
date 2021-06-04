-- Justin Wagers jww3243

--Question 1
SELECT COUNT(cc.cc_id) AS number_creators, MAX(v.video_length) AS max_video_length, MIN(v.video_length) AS min_video_length, MAX(v.views) AS max_views
FROM video v RIGHT JOIN content_creators cc
    ON v.cc_id = cc.cc_id;

--Question 2
SELECT v.title, COUNT(c.comment_id) AS comment_count, MAX(c.time_date) AS last_comment_date
FROM video v FULL OUTER JOIN comments c
    ON v.video_id = c.video_id
GROUP BY v.title
ORDER BY MAX(c.time_date);

--Question 3
SELECT cc.city, TRUNC(AVG(v.likes)) AS average_likes
FROM video v FULL OUTER JOIN content_creators cc
    ON v.cc_id = cc.cc_id
WHERE v.likes >0
GROUP BY cc.city
ORDER BY AVG(v.likes) desc;
    
--Question 4
SELECT t.topic_id, t.topic_name, SUM(v.likes) AS total_likes, TRUNC(AVG(rtrim(v.video_size, 'MB'))) AS avg_video_size
FROM video v 
FULL OUTER JOIN video_topic_link vt
    ON v.video_id = vt.video_id
FULL OUTER JOIN topic t
    ON t.topic_id = vt.topic_id
WHERE t.topic_id >0
GROUP BY t.topic_id, t.topic_name;

--Question 4b (WINDOW)
SELECT t.topic_id,
t.topic_name,
AVG(rtrim(video_size, 'MB')) OVER (PARTITION BY topic_name) AS "avgs", 
SUM(v.likes) OVER (PARTITION BY t.topic_name) AS total_likes
FROM video v 
JOIN video_topic_link vt
        ON v.video_id = vt.video_id
JOIN topic t
        ON vt.topic_id = t.topic_id;

--Question 5
SELECT u.first_name, u.last_name , SUM((v.views-100)/5000) AS awards_earned
FROM video v JOIN content_creators cc
    ON v.cc_id = cc.cc_id
JOIN user_table u
    ON cc.user_id = u.user_id
WHERE (v.views-100)/5000 > 10
GROUP BY u.last_name,u.first_name
ORDER BY SUM((v.views-100)/5000), last_name;

-- Question 6
SELECT u.first_name, c.city_billing, c.state_billing, COUNT(c.card_id) AS number_cards
FROM creditcard c JOIN content_creators cc
    ON c.contentcreator_id = cc.cc_id
JOIN user_table u 
    ON u.user_id = cc.user_id
WHERE c.state_billing = 'NY' OR c.state_billing = 'TX'
GROUP BY 
    u.first_name, ROLLUP(c.city_billing, c.state_billing);
    
--The cube operator is different from rollup in that it creates a summary row at the top of the resulting table, 
--which could be useful for seeing summary statistics at the top of large result tables. 

--Question 7
SELECT cc.cc_id,cc.street_address, c.card_id, CASE WHEN c.street_billing = cc.street_address THEN 'Y' ELSE 'N' END AS matches_main_address
FROM creditcard c FULL OUTER JOIN content_creators cc
    ON c.contentcreator_id = cc.cc_id;
    
--Questin 8 
SELECT cc.cc_id, COUNT(v.video_id) AS number_of_videos, COUNT(DISTINCT(t.topic_id)) AS unique_topics
FROM video v FULL OUTER JOIN content_creators cc 
    ON v.cc_id = cc.cc_id
FULL OUTER JOIN video_topic_link vt
    ON v.video_id = vt.video_id
FULL OUTER JOIN topic t
    ON t.topic_id = vt.topic_id
WHERE cc.cc_id >0
GROUP BY cc.cc_id HAVING COUNT(DISTINCT(t.topic_id)) >=2;

--Question 8B (WINDOWS)

SELECT cc.cc_id, COUNT(v.video_id)  OVER (PARTITION BY cc.cc_id) as number_of_videos, COUNT(DISTINCT(t.topic_id)) OVER (PARTITION BY cc.cc_id) AS unique_topics
FROM video v FULL OUTER JOIN content_creators cc 
    ON v.cc_id = cc.cc_id
FULL OUTER JOIN video_topic_link vt
    ON v.video_id = vt.video_id
FULL OUTER JOIN topic t
    ON t.topic_id = vt.topic_id
WHERE cc.cc_id >0;

--Question 9 
SELECT topic_name
FROM topic 
WHERE topic_id IN(
    SELECT topic_id from video_topic_link)
ORDER BY topic_name DESC;

--Question 10
SELECT u.user_id, v.video_id, v.likes
FROM video v JOIN content_creators cc
    ON v.cc_id = cc.cc_id
JOIN user_table u
    ON cc.user_id = u.user_id
WHERE likes >(SELECT AVG(likes) FROM video)
ORDER BY v.likes;

--Question 11
SELECT u.first_name, u.last_name, u.email, u.cc_flag, u.birthdate
FROM user_table u
JOIN content_creators cc
    ON u.user_id = cc.user_id
WHERE cc.cc_id IN (
    SELECT cc.cc_id
    FROM video v RIGHT JOIN content_creators cc
        ON v.cc_id = cc.cc_id
    WHERE v.video_id IS NULL);

--Question 12
SELECT v.title, v.subtitle, v.video_size, v.views, 
(SELECT COUNT(*) FROM comments c WHERE c.video_id = v.video_id) as comment_count
FROM video v
WHERE video_id IN(
    SELECT video_id FROM comments
    GROUP BY video_id HAVING COUNT(*) >2);

--Question 13
SELECT u.user_id, u.first_name, u.last_name, NVL(vc.video_count, 0) as video_count
FROM user_table u
LEFT JOIN(SELECT COUNT(*) AS video_count, cc.user_id 
            FROM content_creators cc 
            JOIN video v 
            ON cc.cc_id = v.cc_id
            GROUP BY cc.user_id) vc ON vc.user_id = u.user_id
ORDER BY u.last_name;

--Question 14
SELECT cc.cc_id, cc.cc_username, TRUNC(SYSDATE - u.recent_upload) AS days_since_last_upload
FROM content_creators cc
JOIN(SELECT cc_id, MAX(upload_date) AS recent_upload FROM video GROUP BY cc_id) u ON cc.cc_id = u.cc_id;





    

    


    
    

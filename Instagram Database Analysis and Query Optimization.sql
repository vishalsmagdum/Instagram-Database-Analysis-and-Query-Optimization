-- Student Name- Vishal Subhash Magdum --
-- Student ID- S3452

-- 1. Create an ER diagram or draw a schema for the given database.

/*
Schema Description:

The ig_clone database consists of several tables to store different types of data related to 
Instagram Posts which includes users, photos, tags, comments and likes. 
Here's a description of each table and their respective columns:

'users' Table:
id: Unique identifier for each user (Primary Key)
username: User's username (Not Null, Unique)
created_at: Timestamp for user registration

'tags' Table:
id: Unique identifier for each tag (Primary Key)
tag_name: name of the tag (Unique)
created_at: Timestamp for tag creation

'photos' Table:
id: Unique identifier for each photo (Primary Key)
image_url: link of that particular photo (NN)
user_id: identifier for each user (Foreing Key referencing to 'users' table) (NN)
created_at: Timestamp for tag creation

'photo_tags' Table:
photo_id: identifier for each photo (Foreing Key referencing to 'photos' table) (NN)
tag_id: identifier for each tag (Foreing Key referencing to 'tags' table) (NN)

'likes' Table:
user_id: identifier for each user (Foreing Key referencing to 'users' table) (NN)
photo_id: identifier for each photo (Foreing Key referencing to 'photos' table) (NN)
created_at: Timestamp for when like was given

'follows' Table:
follower_id: identifieer for each follower (NN)
followee_id: identifieer for each followee (NN)
created_at: Timestamp for when entry was created

'comments' Table:
id: Unique identifier for each comment (Primary Key)
comment_text: description of a comment (NN)
photo_id: identifier for each photo (Foreing Key referencing to 'photos' table) (NN)
user_id: identifier for each user (Foreing Key referencing to 'users' table) (NN)
created_at: Timestamp for when particular comment was posted

The users, photos, tags, likes and comments entities are related 
to each other in the following ways:

A user can post multiple photos.
A photo can have multiple comments.
A comment can be made by a user.
A user can like multiple photos.
A single tag can be applied to multiple photos.

The primary key and foreign keys for each entity are underlined. 

*/


-- 2. We want to reward the user who has been around the longest, Find the 5 oldest users.

SELECT * FROM users 
ORDER BY created_at ASC
LIMIT 5;

SELECT *,  --  with Rank
RANK () OVER(ORDER BY created_at ASC) AS Oldest_User
FROM users
LIMIT 5;

-- 3. To target inactive users in an email ad campaign, find the users who have never posted a photo.

SELECT * FROM users WHERE id NOT IN 
(SELECT user_id FROM photos);

-- 4. Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?

SELECT username, count(l.photo_id) as Number_of_Likes 
FROM users u
JOIN photos p ON u.id=p.user_id
JOIN likes l ON p.user_id=l.user_id
GROUP BY username
ORDER BY Number_of_Likes DESC
LIMIT 1;

-- 5. The investors want to know how many times does the average user post.

SELECT user_id, count(id) AS Number_of_Posts
FROM photos
GROUP BY user_id
ORDER BY Number_of_Posts DESC;

CREATE VIEW POSTS AS
SELECT user_id,count(*) as no_of_posts FROM photos
GROUP BY user_id;

SELECT * FROM posts;

SELECT AVG(no_of_posts) FROM POSTS;


-- 6. A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.

SELECT tag_name, COUNT(tag_id) AS Number_of_Times_Used
FROM tags t
JOIN photo_tags p ON t.id=p.tag_id
GROUP BY tag_name
ORDER BY Number_of_Times_Used DESC
LIMIT 5;

-- 7. To find out if there are bots, find users who have liked every single photo on the site.

SELECT distinct * FROM likes WHERE user_id  
NOT IN
(SELECT user_id FROM photos
group by user_id);

SELECT l.user_id, u.username
FROM likes l
JOIN users u ON l.user_id=u.id
GROUP BY l.user_id
HAVING COUNT(DISTINCT photo_id) = (SELECT COUNT(*) FROM photos);


-- 8. Find the users who have created instagramid in may and select top 5 newest joinees from it?

SELECT *,    -- with Rank
RANK() OVER (ORDER BY created_at DESC) AS Newest_Instagram_Member_Rank
FROM users
WHERE MONTHNAME(created_at)= 'May'
ORDER BY created_at DESC
LIMIT 5;

SELECT *
FROM users
WHERE MONTHNAME(created_at)= 'May'
ORDER BY created_at DESC
LIMIT 5;

-- 9. Can you help me find the users whose name starts with c and ends with any number and have posted the photos as well as liked the photos?

SELECT u.id, username FROM users u 
JOIN photos p ON u.id=p.user_id
JOIN likes l ON p.user_id=l.user_id
WHERE username REGEXP '^c.*[0-9]$'
GROUP BY u.id, username;

WITH photos_likes AS  -- with CTE
(
SELECT photos.id,likes.user_id FROM photos
INNER JOIN likes ON photos.user_id=likes.user_id
) 
SELECT photos_likes.id,photos_likes.user_id,users.username FROM users 
INNER JOIN photos_likes ON users.id=photos_likes.user_id
WHERE users.username REGEXP '^C' AND users.username REGEXP '[0-9]$'
GROUP BY photos_likes.id;

-- 10. Demonstrate the top 30 usernames to the company who have posted photos in the range of 3 to 5.

SELECT user_id, username, COUNT(p.id) AS Number_of_Photos_Posted
FROM users u 
JOIN photos p ON u.id=p.user_id
GROUP BY user_id
HAVING Number_of_Photos_Posted BETWEEN 3 AND 5
ORDER BY Number_of_Photos_Posted DESC
LIMIT 30;

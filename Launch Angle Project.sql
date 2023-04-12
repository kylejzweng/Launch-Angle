CREATE DATABASE launch_angle_project;
USE launch_angle_project;

-- Imported .csv file from Baseball Savant. It's pretty obvious that to be an offensive force in MLB you need to hit the ball hard. 

SELECT
	last_name, 
	first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg 
FROM 
	stats
ORDER BY 
	exit_velocity_avg DESC, xwoba
LIMIT 20;

-- The players that hit the ball the hardest also tend to have the highest xWOBA, a great indicator of offensive success. This also clearly passes the eye test. Stanton, Judge, Tatis Jr., and Alvarez are some of the best hitters in the league. These are all well established stars and that's because they pair their exceptional average exit velocity with ideal average launch angles. These launch angles are something we'll be taking a closer look at as it's often overlooked when trying to determine who can be a real offensive force in the league.

-- First query is to find the average xWOBA per distinct average launch angle (expected weighted on base average) for each launch angle.

SELECT
	launch_angle_avg, 
    AVG(xwoba)
FROM 
	stats
GROUP BY 
	launch_angle_avg
ORDER BY 
	AVG(xwoba) DESC;

-- While we can see that the highest xWOBAs tend to come with a launch angle in the 20s, this table isn't too informative. Let's create buckets for the launch angles in incriments of 5 to determine if there's any more obvious correlation between launch angle and xWOBA.

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT 
	AVG(xwoba),
	CASE
		WHEN launch_angle_avg <= 0 THEN '0 and below'
		WHEN launch_angle_avg <= 5 THEN '0.001 - 5'
		WHEN launch_angle_avg <= 10 THEN '5.001 - 10'
		WHEN launch_angle_avg <= 15 THEN '10.001 - 15'
		WHEN launch_angle_avg <= 20 THEN '15.001 - 20'
		WHEN launch_angle_avg <= 25 THEN '20.001 - 25'
		ELSE '25.001 - 30'
		END as 'launch_angle'
FROM 
	stats
GROUP BY 
	CASE 
	WHEN launch_angle_avg <= 0 THEN '0 and below'
    WHEN launch_angle_avg <= 5 THEN '0.001 - 5'
    WHEN launch_angle_avg <= 10 THEN '5.001 - 10'
    WHEN launch_angle_avg <= 15 THEN '10.001 - 15'
    WHEN launch_angle_avg <= 20 THEN '15.001 - 20'
    WHEN launch_angle_avg <= 25 THEN '20.001 - 25'
    ELSE '25.001 - 30'
    END
ORDER BY 
	launch_angle_avg;

-- Much better. Now it's clear to see that as a player's average launch angle increases so does their xWOBA. Note, there are limitations to this. As launch angles continue to increase you're simply going to pop the ball straight up instead of hitting it into the outfield. 

-- Let's take a look at some players with launch angles greater than 20 degrees.

SELECT 
	last_name, 
	first_name, 
	year, 
	launch_angle_avg, 
    xwoba
FROM 
	stats
WHERE 
	launch_angle_avg >= 20
ORDER BY 
	xwoba DESC
LIMIT 25;

-- Not bad when a list is populated with Trout, Gallo, and Jose Ramirez when trying to find the best hitters.

-- What about on the other end of the spectrum?

SELECT 
	last_name, 
    first_name, 
    year, 
    launch_angle_avg, 
    xwoba
FROM 
	stats
WHERE 
	launch_angle_avg <= 5
ORDER BY 
	xwoba
LIMIT 25;

-- Not so great. Dee Strange-Gordon was frequently shuffled between the majors and AAA, Orlando Arcia has had trouble sticking in the pros, and to be quite frank, I've never heard of Andrew Romine.

-- Maybe more important than these names too is that the range of xWOBAs with a launch angle greater than 20 ranges from .460 to .216 while the range of xWOBAs with a launch angle less than 5 ranges from .416 to .228. The ranges are nearly identical so it's important to remember that launch angle alone will not drive offensive performance, but as we saw earlier, as launch angle increases so does xWOBA.

-- Let's go back to to looking at our players who hit the ball really hard and their exit veloicty and launch angle averaged over the years of data we have (2015-2022).

SELECT 
	last_name, 
    first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg
FROM 
	stats
ORDER BY 
	exit_velocity_avg DESC, xwoba
LIMIT 50;
                        
-- Even though we have the stars of the MLB here, we also have some suprising names like David Bote and Keon Broxton coming in the top 35 average exit velocities. What gives?

SELECT 
	last_name,
    first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg, 
    xwoba
FROM 
	stats
WHERE 
	last_name = 'Broxton' 
ORDER BY 
	exit_velocity_avg DESC;

-- Despite Bote and Broxton all hitting the ball incredibly hard in 2018 and 2016 respectively they had fairly mediocre xWOBA. What gives? Take a look at the launch angles. Bote's average launch angle of 3.7 degrees is absolutely admismal, and Broxton's 9.6 is far from optimal. Premium exit velocities like Bote's of 93.5 mph cannot make up for poor launch angles, and as a result, offensive performance (xWOBA) suffers.

-- Let's take a look at what Bote could have accomplished with the same average exit velocity but a steeper average launch angle.

SELECT 
	AVG(xwoba)
FROM 
	stats
WHERE 
	(exit_velocity_avg BETWEEN 93 AND 94) AND 
	(launch_angle_avg >= 14.6 AND launch_angle_avg <=19.6);

SELECT 
	last_name,
	first_name,
    year,
	exit_velocity_avg,
    launch_angle_avg,
	xwoba
FROM 
	stats
WHERE 
	(exit_velocity_avg BETWEEN 93 AND 94) AND 
	(launch_angle_avg >= 14.6 AND launch_angle_avg <=19.6)
ORDER BY 
	xwoba DESC;

-- It's clear that Bote's average exit velocity of 93.5 mph is no small feat. He's hitting the ball as hard as Freeman, Harper, Ozun, Seager, and Betts. These are all household names due to their unquestionable offensive abilities. Yet Bote isn't producing nearly as much offensively becaue his average launch angle lags behind these players by as much as 14 degrees sometimes. Hit the ball as hard as you want, but if you don't elevate it, it'll rarely get you extra base hits and never go over the fence.

-- Bote is a prime candidate for someone who would benefit from a  re-tooled swing to add extra lift. Let's see if we can find other players with above average exit velocities but below average launch angles that would benefit from a similiar change.

-- First we'll need to find what an above average exit velocity is.

SELECT 
	AVG(exit_velocity_avg)
FROM 
	stats
ORDER BY
	year DESC;

-- Exit velocity remains pretty stable year over year, so let's call an average exit velocity of 89 above average. Now let's find the average launch angle in MLB.

SELECT 
	AVG(launch_angle_avg)
FROM 
	stats
ORDER BY 
	year DESC;

-- Launch angels have consistently risen throughout the MLB as players have realized its importance. For ease, let's say a player with an average launch angle of 11 is below average.

-- Perfect, now we have our criteria for a potential breakout: a player with above average exit velocity (89 mph or higher) but a less than ideal launch angle (11 or lower)

SELECT
	last_name, 
    first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg
FROM 
	stats
WHERE 
	launch_angle_avg < 12 AND exit_velocity_avg > 89
ORDER BY 
	launch_angle_avg, exit_velocity_avg DESC
LIMIT 30;

-- The list for the most part is pretty uninspiring in terms of offensive weapons, but that's the point! These guys hit the ball hard, but into the ground too often. #11 on this list is Eric Hosmer, the poster child for someone who hits the ball hard but kills a lot of worms in the process. Similarly, at #3 we have the 2015, pre-MVP version of Christian Yelich. Let's take a look at his career trajectory after this year.

SELECT 
	last_name, 
    first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg, 
    xwoba
FROM 
	stats
WHERE 
	last_name = 'Yelich'
ORDER BY 
	year;

-- His launch angle increases from 0.1 to 2.7 and then up to 4.6, 5, and then peaking at 11.3 in 2019. His xWOBA follows a similiar trend, peaking in 2019 at .429 all the while his average exit velocity remained relatively stable. By looking at this data in 2015 we could've forcasted a breakout. His premium exit velocity paired with an rise in launch angle were huge reaons why he won the NL MVP in 2018 and came runner-up in 2019. His launch angle has since come down, and he has been a consistent disapopintment since. Let's keep looking for these 'breakout candidates'. 

SELECT 
	last_name, 
	first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg
FROM 
	stats
WHERE 
	(launch_angle_avg < 12 AND exit_velocity_avg > 89) 
    AND (year = 2020)
ORDER BY 
	exit_velocity_avg DESC
LIMIT 20;
 
 -- Vlad Guerrero Jr. pops out as well. His average exit velocity is right up there with Fernando Tatis, Yelich, and Kyle Schwarber but his average launch angle is nearly half of theirs. Unlock that power Vladdy!
 
SELECT 
	last_name, 
    first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg, 
    xwoba
FROM 
	stats
WHERE 
	last_name = 'Guerrero Jr.'
ORDER BY 
	year;

-- And he did! Well at least for 2021 when he challenged Shohei Ohtain for AL MVP. And then it fell back again in 2022 wherein his xWOBA crashed as well. 

-- As we can see, hitting the ball hard is not enought to be a dangerous offensive threat. You have to hit the ball hard AND have an ideal launch angle. By looking at these two statistics in tandem we can see who might benefit from a swing change and unlock more of their potential.

-- Let's see if we can pick out any of these types of hitters from the 2022 season to look ahead.

SELECT
	last_name, 
    first_name, 
    year, 
    exit_velocity_avg, 
    launch_angle_avg
FROM 
	stats
WHERE 
	(launch_angle_avg < 10 AND exit_velocity_avg > 85) 
    AND (year = 2022)
ORDER BY 
	exit_velocity_avg DESC;

-- As we talked about early, Vladdy Jr. shows up and we know he would really benefit from gains to his launch angle. Yandy Diaz also shows up here and unfortunately he always does as a player who has always hit the ball hard but can't elevate. Yelich appears again too! Young prospects abound too like Ke'Bryan Hayes, Andrew Vaughn, Riley Greene, and Christian Pache. Could these players, with a little re-tooling in an already potent swing, be the next stars of the MLB?








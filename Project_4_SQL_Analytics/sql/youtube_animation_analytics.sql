/*
=========================================================
Project 4: YouTube Animation SQL Analytics

Author: Ose Esangbedo

Database: company_db
Table: youtube_videos

Project Objective:
Analyze YouTube animation videos to identify trends in
video performance, audience engagement, category success,
and channel performance using SQL.

Key Business Questions:

1. Which animation categories receive the highest views?

2. Which categories have the strongest audience engagement?

3. Which videos outperform expectations within their category?

4. Which channels consistently perform well?

5. Which videos rank highest within each animation category?


SQL Concepts Demonstrated:

- SELECT Statements
- Filtering (WHERE)
- Sorting (ORDER BY)
- Aggregate Functions
- GROUP BY
- HAVING
- CASE Statements
- Subqueries
- Derived Tables
- JOINs
- Window Functions
- ROW_NUMBER()
- RANK()

=========================================================
*/


/*
=========================================================
SECTION 1: DATASET EXPLORATION

Purpose:
Understand the size, structure, and distribution of the
YouTube animation dataset before performing analysis.

=========================================================
*/


/*
Business Question:
How many videos are included in the dataset?
*/

SELECT 
    COUNT(*) AS total_videos
FROM youtube_videos;



/*
Business Question:
How many unique animation categories are represented?
*/

SELECT 
    COUNT(DISTINCT search_query) AS total_categories
FROM youtube_videos;



/*
Business Question:
How many unique YouTube channels are represented?
*/

SELECT 
    COUNT(DISTINCT channel) AS total_channels
FROM youtube_videos;



/*
Business Question:
How are videos distributed across animation categories?
*/

SELECT
    search_query,
    COUNT(*) AS total_videos
FROM youtube_videos
GROUP BY search_query
ORDER BY total_videos DESC;


/*
=========================================================
SECTION 2: CATEGORY PERFORMANCE ANALYSIS

Purpose:
Compare animation categories based on views, engagement,
and consistency of performance.

=========================================================
*/


/*
Business Question:
Which animation categories receive the highest average
number of views?
*/

SELECT
    search_query,
    COUNT(*) AS total_videos,
    ROUND(AVG(views), 2) AS average_views
FROM youtube_videos
GROUP BY search_query
ORDER BY average_views DESC;



/*
Business Question:
Which animation categories have the strongest average
audience engagement?

Engagement Metric:
Like Rate = Likes / Views

This measures audience interaction relative to reach.
*/

SELECT
    search_query,
    COUNT(*) AS total_videos,
    ROUND(AVG(likes / views), 4) AS average_like_rate
FROM youtube_videos
GROUP BY search_query
ORDER BY average_like_rate DESC;



/*
Business Question:
Which animation categories contain the highest percentage
of highly engaged videos?

High Engagement Definition:
Like Rate >= 5%

*/

SELECT
    search_query,
    COUNT(*) AS total_videos,

    SUM(
        CASE
            WHEN (likes / views) >= 0.05 THEN 1
            ELSE 0
        END
    ) AS high_engagement_videos,

    ROUND(
        SUM(
            CASE
                WHEN (likes / views) >= 0.05 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS high_engagement_percentage

FROM youtube_videos
GROUP BY search_query
ORDER BY high_engagement_percentage DESC;



/*
Business Question:
Which categories have the most videos outperforming
their own category average?

This identifies categories where videos frequently exceed
normal expectations for that category.

*/

SELECT
    search_query,
    COUNT(*) AS videos_above_category_average

FROM
(
    SELECT
        title,
        search_query,
        views,

        AVG(views) OVER(
            PARTITION BY search_query
        ) AS category_average

    FROM youtube_videos

) AS category_performance

WHERE views > category_average

GROUP BY search_query
ORDER BY videos_above_category_average DESC;


/*
=========================================================
SECTION 3: VIDEO PERFORMANCE ANALYSIS

Purpose:
Identify top-performing individual videos and compare
performance against overall and category-level benchmarks.

=========================================================
*/


/*
Business Question:
Which videos have the highest total view counts?
*/

SELECT
    title,
    channel,
    search_query,
    views
FROM youtube_videos
ORDER BY views DESC
LIMIT 10;



/*
Business Question:
Which videos perform above the average view count
of the entire dataset?
*/

SELECT
    title,
    channel,
    search_query,
    views

FROM youtube_videos

WHERE views >
(
    SELECT AVG(views)
    FROM youtube_videos
)

ORDER BY views DESC;



/*
Business Question:
Which videos outperform the average views of their
own animation category?

This compares each video against similar content instead
of the entire dataset.
*/

SELECT
    title,
    channel,
    search_query,
    views,
    category_average

FROM
(
    SELECT
        title,
        channel,
        search_query,
        views,

        AVG(views) OVER(
            PARTITION BY search_query
        ) AS category_average

    FROM youtube_videos

) AS category_comparison

WHERE views > category_average

ORDER BY search_query, views DESC;



/*
Business Question:
What are the top 3 performing videos within each
animation category?

ROW_NUMBER() creates a ranking that resets for each
category.

*/

SELECT
    title,
    channel,
    search_query,
    views,
    category_rank

FROM
(
    SELECT
        title,
        channel,
        search_query,
        views,

        ROW_NUMBER() OVER(
            PARTITION BY search_query
            ORDER BY views DESC
        ) AS category_rank

    FROM youtube_videos

) AS ranked_videos

WHERE category_rank <= 3

ORDER BY search_query, category_rank;


/*
=========================================================
SECTION 4: CHANNEL PERFORMANCE ANALYSIS

Purpose:
Evaluate creator performance by analyzing upload volume,
average views, and consistency across multiple videos.

=========================================================
*/


/*
Business Question:
Which channels have uploaded the most videos in this
dataset?

This identifies creators with multiple appearances.
*/

SELECT
    channel,
    COUNT(*) AS total_videos

FROM youtube_videos

GROUP BY channel

ORDER BY total_videos DESC;



/*
Business Question:
Which channels have multiple videos and what is their
average view performance?

This focuses on creators with repeated representation
in the dataset.

*/

SELECT
    channel,
    COUNT(*) AS total_videos,
    ROUND(AVG(views), 2) AS average_views

FROM youtube_videos

GROUP BY channel

HAVING COUNT(*) > 1

ORDER BY average_views DESC;



/*
Business Question:
Which channels have the highest average views while
appearing multiple times in the dataset?

This highlights consistently strong creators rather than
single viral videos.

*/

SELECT
    channel,
    COUNT(*) AS total_videos,
    ROUND(AVG(views), 2) AS average_views

FROM youtube_videos

GROUP BY channel

HAVING COUNT(*) >= 2

ORDER BY average_views DESC;



/*
Business Question:
Which channels have the highest number of videos that
rank above the overall dataset average?

This identifies creators with repeated high-performing
content.

*/

SELECT
    channel,
    COUNT(*) AS above_average_videos

FROM
(
    SELECT
        channel,
        views,

        AVG(views) OVER() AS overall_average

    FROM youtube_videos

) AS channel_performance

WHERE views > overall_average

GROUP BY channel

ORDER BY above_average_videos DESC;


/*
=========================================================
SECTION 5: ADVANCED SQL ANALYSIS

Purpose:
Apply advanced SQL techniques including ranking and
window functions to identify top-performing videos.

=========================================================
*/


/*
Business Question:
How do video rankings compare when using ROW_NUMBER()
versus RANK()?

ROW_NUMBER() assigns every row a unique position.

RANK() allows tied values to share the same position.

*/

SELECT
    title,
    channel,
    search_query,
    views,

    ROW_NUMBER() OVER(
        PARTITION BY search_query
        ORDER BY views DESC
    ) AS row_number_rank,

    RANK() OVER(
        PARTITION BY search_query
        ORDER BY views DESC
    ) AS rank_position

FROM youtube_videos

ORDER BY search_query, views DESC;



/*
Business Question:
What are the top 3 videos in each animation category
using ranking?

*/

SELECT
    title,
    channel,
    search_query,
    views,
    category_rank

FROM
(
    SELECT
        title,
        channel,
        search_query,
        views,

        RANK() OVER(
            PARTITION BY search_query
            ORDER BY views DESC
        ) AS category_rank

    FROM youtube_videos

) AS ranked_categories

WHERE category_rank <= 3

ORDER BY search_query, category_rank;


/*
=========================================================
PROJECT SUMMARY

Key Findings:

1. Video performance varied significantly across
animation categories.

2. Categories with the highest average views were not
always the categories with the strongest engagement.

3. Engagement rate provided additional insight beyond
total views by measuring audience interaction.

4. Some videos significantly outperformed the average
performance of their own category.

5. Certain channels demonstrated consistent performance
through multiple high-performing videos.

6. Window functions allowed comparisons between videos,
categories, and overall dataset benchmarks.

=========================================================

Final Skills Demonstrated:

✓ Data Exploration
✓ Data Aggregation
✓ Category Analysis
✓ Engagement Analysis
✓ Performance Benchmarking
✓ Channel Analysis
✓ Subqueries
✓ Derived Tables
✓ Window Functions
✓ Ranking Analysis

=========================================================
*/


/*
=========================================================
ANALYTICAL TAKEAWAYS

Key Insights Discovered:

1. Animation categories showed significant differences in
average view performance.

2. Animated music videos and cartoon-focused content
generated some of the highest total view counts,
demonstrating strong audience reach.

3. Indie animation and 2D animation categories showed
strong audience engagement rates, suggesting that
smaller creator-driven content can generate meaningful
viewer interaction.

4. Several videos significantly outperformed their
category averages, indicating that individual content
quality and audience appeal can create results beyond
category expectations.

5. Some channels demonstrated consistent performance by
appearing multiple times among above-average videos.

6. Comparing videos against category benchmarks provided
a more accurate evaluation than relying only on total
views.

=========================================================

END OF PROJECT

=========================================================
*/
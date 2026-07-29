import mysql.connector
import csv

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Hero#0Pass",
    database="youtube_animation_analytics"
)

cursor = connection.cursor()

csv_file_path = r"C:\Prog\Python\TutorialApp\data\youtube_animation_data_expanded.csv"

with open(csv_file_path, mode="r", encoding="utf-8") as file:
    csv_reader = csv.DictReader(file)

    insert_query = """
    INSERT INTO youtube_videos (
        video_id,
        search_query,
        title,
        channel,
        published_at,
        views,
        likes,
        comments,
        publish_year,
        publish_month,
        title_length,
        engagement_total,
        engagement_ratio
    )
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    for row in csv_reader:
        cursor.execute(
            insert_query,
            (
                row["video_id"],
                row["search_query"],
                row["title"],
                row["channel"],
                row["published_at"],
                int(row["views"]),
                int(row["likes"]),
                int(row["comments"]),
                int(row["publish_year"]),
                int(row["publish_month"]),
                int(row["title_length"]),
                int(row["engagement_total"]),
                float(row["engagement_ratio"])
            )
        )

connection.commit()

print("Data imported successfully!")

connection.close()

from googleapiclient.discovery import build
import pandas as pd

API_KEY = "AIzaSyAaDkxCETkv6yDMA_60wUPWMNBEWs7Q85Y"

youtube = build('youtube', 'v3', developerKey=API_KEY)


def get_videos(query, max_results=25):
    request = youtube.search().list(
        q=query,
        part="snippet",
        type="video",
        maxResults=max_results
    )
    response = request.execute()

    video_ids = [item['id']['videoId'] for item in response['items']]

    stats_request = youtube.videos().list(
        part="snippet,statistics",
        id=",".join(video_ids)
    )
    stats_response = stats_request.execute()

    data = []

    for item in stats_response['items']:
        data.append({
            'video_id': item['id'],
            'search_query': query,
            'title': item['snippet']['title'],
            'channel': item['snippet']['channelTitle'],
            'published_at': item['snippet']['publishedAt'],
            'views': int(item['statistics'].get('viewCount', 0)),
            'likes': int(item['statistics'].get('likeCount', 0)),
            'comments': int(item['statistics'].get('commentCount', 0))
        })

    return pd.DataFrame(data)


queries = [
    "animation short film",
    "animated short",
    "indie animation",
    "cartoon short film",
    "2d animation short",
    "animated music video"
]

all_dfs = []

for query in queries:
    print(f"Collecting data for: {query}")
    temp_df = get_videos(query, 25)
    all_dfs.append(temp_df)

df = pd.concat(all_dfs, ignore_index=True)

df = df.drop_duplicates(subset='video_id')

df['published_at'] = pd.to_datetime(df['published_at'])
df['publish_year'] = df['published_at'].dt.year
df['publish_month'] = df['published_at'].dt.month
df['title_length'] = df['title'].str.len()
df['engagement_total'] = df['likes'] + df['comments']

df['engagement_ratio'] = (
    df['engagement_total'] / df['views'].replace(0, pd.NA)
).fillna(0.0).astype(float)

print("\nDataset shape after removing duplicates:")
print(df.shape)

print("\nFirst 5 rows:")
print(df.head())

df.to_csv("youtube_animation_data_expanded.csv", index=False)
print("\nSaved expanded dataset as youtube_animation_data_expanded.csv")

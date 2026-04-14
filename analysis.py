import matplotlib.pyplot as plt
import pandas as pd

df = pd.read_csv("data/youtube_animation_data_expanded.csv")

print("\nTop 10 videos by views:")
print(df[['title', 'channel', 'views']].sort_values(
    by='views', ascending=False).head(10))

print("\nTop 10 videos by engagement:")
print(df[['title', 'channel', 'engagement_total']].sort_values(
    by='engagement_total', ascending=False).head(10))

print("\nTop 10 videos by engagement ratio:")
print(df[['title', 'channel', 'engagement_ratio']].sort_values(
    by='engagement_ratio', ascending=False).head(10))

print("\nAverage views by year:")
print(df.groupby('publish_year')['views'].mean().sort_index())

print("\nMedian views by year:")
print(df.groupby('publish_year')['views'].median().sort_index())

print("\nAverage engagement ratio by year:")
print(df.groupby('publish_year')['engagement_ratio'].mean().sort_index())

print("\nAverage views by month:")
print(df.groupby('publish_month')['views'].mean().sort_index())

print("\nAverage views by search query:")
print(df.groupby('search_query')['views'].mean().sort_values(ascending=False))

print("\nAverage engagement ratio by search query:")
print(df.groupby('search_query')[
      'engagement_ratio'].mean().sort_values(ascending=False))

# Top 10 by views chart
top_views = df.sort_values(by='views', ascending=False).head(10)

plt.figure()
plt.barh(top_views['title'], top_views['views'])
plt.xlabel("Views")
plt.title("Top 10 Animation Videos by Views")
plt.gca().invert_yaxis()
plt.tight_layout()
plt.savefig("visuals/top_views.png")
plt.close()

# Engagement ratio distribution chart
plt.figure()
plt.hist(df['engagement_ratio'], bins=10)
plt.title("Distribution of Engagement Ratio")
plt.xlabel("Engagement Ratio")
plt.ylabel("Count")
plt.tight_layout()
plt.savefig("visuals/engagement_distribution.png")
plt.close()

# Average views by search query chart
query_views = df.groupby('search_query')['views'].mean().sort_values()

plt.figure()
plt.barh(query_views.index, query_views.values)
plt.title("Average Views by Content Type")
plt.xlabel("Average Views")
plt.tight_layout()
plt.savefig("visuals/views_by_type.png")
plt.close()

print("\nSaved charts to the visuals folder.")

import pandas as pd
import re
from collections import defaultdict
import matplotlib.pyplot as plt

df = pd.read_csv("data/youtube_animation_data_expanded.csv")

# clean titles
df['clean_title'] = df['title'].str.lower()
df['clean_title'] = df['clean_title'].apply(lambda x: re.sub(r'[^a-z0-9\s]', '', x))

# split titles into words
df['words'] = df['clean_title'].apply(lambda x: x.split())

# stopwords
stopwords = {
    'the', 'a', 'to', 'by', 'for', 'is', 'and', 'of', 'in', 'on', 'with'
}

# collect views per word
word_views = defaultdict(list)

for _, row in df.iterrows():
    words = set(row['words'])
    for word in words:
        if word not in stopwords:
            word_views[word].append(row['views'])

# calculate average views per word
avg_word_views = []

for word, views in word_views.items():
    if len(views) >= 5:
        avg_word_views.append((word, sum(views) / len(views)))

# sort
avg_word_views = sorted(avg_word_views, key=lambda x: x[1], reverse=True)

# take top 10
top_words = avg_word_views[:10]

words = [w for w, _ in top_words]
views = [v for _, v in top_words]

# create chart
plt.figure()
plt.barh(words, views)
plt.title("Top Words by Average Views")
plt.xlabel("Average Views")
plt.gca().invert_yaxis()
plt.tight_layout()

# save chart
plt.savefig("visuals/title_word_performance.png")
plt.close()

print("\nSaved chart: visuals/title_word_performance.png")

from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

ROOT = Path(__file__).resolve().parent
DATA = ROOT.parent / "data" / "heart_disease_dataset.csv"
ASSETS = ROOT / "assets"
ASSETS.mkdir(exist_ok=True)

sns.set_theme(style="whitegrid", palette="deep")
df = pd.read_csv(DATA).drop_duplicates().reset_index(drop=True)
numeric_features = ["age", "trestbps", "chol", "thalach", "oldpeak"]
categorical_features = ["sex", "cp", "fbs", "restecg", "exang", "slope", "ca", "thal"]

fig, axes = plt.subplots(2, 3, figsize=(12, 7))
for axis, feature in zip(axes.flat, numeric_features):
    sns.histplot(data=df, x=feature, kde=True, ax=axis, color="#1f77b4")
    axis.set_title(feature)
axes.flat[-1].axis("off")
fig.suptitle("Distribusi fitur numerik", fontsize=14, fontweight="bold")
fig.tight_layout()
fig.savefig(ASSETS / "distributions.png", dpi=180, bbox_inches="tight")
plt.close(fig)

fig, axes = plt.subplots(1, len(numeric_features), figsize=(15, 4))
for axis, feature in zip(axes, numeric_features):
    sns.boxplot(data=df, x="target", y=feature, ax=axis, color="#80b1d3")
    axis.set_title(feature)
fig.suptitle("Fitur numerik berdasarkan target", fontsize=14, fontweight="bold")
fig.tight_layout()
fig.savefig(ASSETS / "boxplots.png", dpi=180, bbox_inches="tight")
plt.close(fig)

corr = df[["age", "trestbps", "chol", "thalach", "oldpeak", "target"]].corr()
fig, axis = plt.subplots(figsize=(8, 6))
sns.heatmap(corr, annot=True, fmt=".2f", cmap="coolwarm", vmin=-1, vmax=1, square=True, ax=axis)
axis.set_title("Matriks korelasi Pearson")
fig.tight_layout()
fig.savefig(ASSETS / "correlation.png", dpi=180, bbox_inches="tight")
plt.close(fig)

fig, axes = plt.subplots(2, 4, figsize=(14, 7))
for axis, feature in zip(axes.flat, categorical_features):
    sns.countplot(data=df, x=feature, hue="target", ax=axis)
    axis.set_title(feature)
    axis.legend(title="target", fontsize=8)
fig.suptitle("Fitur kategorikal berdasarkan target", fontsize=14, fontweight="bold")
fig.tight_layout()
fig.savefig(ASSETS / "categorical.png", dpi=180, bbox_inches="tight")
plt.close(fig)

print(f"Generated figures from {len(df)} unique rows in {DATA}")

"""Reproduce the preprocessing pipeline from prak2_final.ipynb and save the report figures."""
import math
import os
from pathlib import Path

import kagglehub
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from dotenv import load_dotenv
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"
ASSETS.mkdir(exist_ok=True)

load_dotenv()
sns.set_theme(style="whitegrid")


def save(fig, name):
    fig.tight_layout()
    fig.savefig(ASSETS / name, dpi=180, bbox_inches="tight")
    plt.close(fig)


path = kagglehub.competition_download("house-prices-advanced-regression-techniques")
df = pd.read_csv(os.path.join(path, "train.csv"))

# ── 2. missing values ─────────────────────────────────────────────────────────
missing_pct = df.isna().mean() * 100
missing_pct = missing_pct[missing_pct > 0].sort_values(ascending=False)

fig, ax = plt.subplots(figsize=(10, 4.5))
colors = ["#d62728" if p > 50 else "steelblue" for p in missing_pct]
missing_pct.plot.bar(ax=ax, color=colors)
ax.axhline(50, color="red", linestyle="--", label="batas 50%")
ax.set_ylabel("% missing")
ax.set_title("Persentase nilai hilang per atribut")
ax.legend()
save(fig, "missing.png")

df_clean = df.drop(columns=missing_pct[missing_pct > 50].index.tolist() + ["Id"])
none_cols = ["FireplaceQu", "GarageType", "GarageFinish", "GarageQual", "GarageCond",
             "BsmtQual", "BsmtCond", "BsmtExposure", "BsmtFinType1", "BsmtFinType2"]
df_clean[none_cols] = df_clean[none_cols].fillna("None")
df_clean["GarageYrBlt"] = df_clean["GarageYrBlt"].fillna(df_clean["YearBuilt"])
df_clean["MasVnrArea"] = df_clean["MasVnrArea"].fillna(0)
df_clean["LotFrontage"] = (
    df_clean.groupby("Neighborhood")["LotFrontage"]
    .transform(lambda s: s.fillna(s.median()))
    .fillna(df_clean["LotFrontage"].median())
)
df_clean["Electrical"] = df_clean["Electrical"].fillna(df_clean["Electrical"].mode()[0])

# ── 3. outliers ───────────────────────────────────────────────────────────────
df_clean["MSSubClass"] = df_clean["MSSubClass"].astype(str)
num_cols = df_clean.select_dtypes("number").columns.drop("SalePrice").tolist()

ncols = 6
nrows = math.ceil(len(num_cols) / ncols)
fig, axes = plt.subplots(nrows, ncols, figsize=(18, nrows * 2.3))
for ax, col in zip(axes.flat, num_cols):
    sns.boxplot(x=df_clean[col], ax=ax, color="lightsteelblue", fliersize=2)
    ax.set_title(col, fontsize=10)
    ax.set_xlabel("")
for ax in axes.flat[len(num_cols):]:
    ax.set_visible(False)
fig.suptitle("Boxplot atribut numerik", fontsize=14, fontweight="bold")
save(fig, "boxplots.png")

anomali = (df_clean["GrLivArea"] > 4000) & (df_clean["SalePrice"] < 300000)
fig, ax = plt.subplots(figsize=(8, 4.5))
ax.scatter(df_clean["GrLivArea"], df_clean["SalePrice"], s=10, alpha=0.5, label="normal")
ax.scatter(df_clean.loc[anomali, "GrLivArea"], df_clean.loc[anomali, "SalePrice"],
           s=60, color="red", label="anomali (dihapus)")
ax.set_xlabel("GrLivArea (sqft)")
ax.set_ylabel("SalePrice")
ax.set_title("GrLivArea vs SalePrice")
ax.legend()
save(fig, "anomaly.png")
df_clean = df_clean[~anomali].reset_index(drop=True)

year_cols = ["YearBuilt", "YearRemodAdd", "GarageYrBlt", "YrSold", "MoSold"]
q1 = df_clean[num_cols].quantile(0.25)
q3 = df_clean[num_cols].quantile(0.75)
iqr = q3 - q1
cap_cols = [c for c in num_cols
            if c not in year_cols and df_clean[c].nunique() > 25 and iqr[c] > 0]
before = df_clean[cap_cols].copy()
for c in cap_cols:
    df_clean[c] = df_clean[c].clip(lower=q1[c] - 1.5 * iqr[c], upper=q3[c] + 1.5 * iqr[c])

fig, axes = plt.subplots(2, len(cap_cols), figsize=(1.7 * len(cap_cols), 5.5))
for i, c in enumerate(cap_cols):
    sns.boxplot(y=before[c], ax=axes[0, i], color="salmon", fliersize=2)
    sns.boxplot(y=df_clean[c], ax=axes[1, i], color="mediumseagreen", fliersize=2)
    axes[0, i].set_title(c, fontsize=9)
    for row in (0, 1):
        axes[row, i].set_ylabel("")
        axes[row, i].tick_params(labelsize=7)
axes[0, 0].set_ylabel("sebelum")
axes[1, 0].set_ylabel("sesudah")
save(fig, "capping.png")

# ── 4. transformation ─────────────────────────────────────────────────────────
y = df_clean["SalePrice"]
X = df_clean.drop(columns="SalePrice")
cat_cols = [c for c in X.columns if c not in num_cols]
X_num = pd.DataFrame(StandardScaler().fit_transform(X[num_cols]), columns=num_cols, index=X.index)
X_cat = pd.get_dummies(X[cat_cols], dtype=int)
X_final = pd.concat([X_num, X_cat], axis=1)

# ── 5. dimensionality reduction ───────────────────────────────────────────────
corr = X_num.corr()
fig, ax = plt.subplots(figsize=(11, 9.5))
sns.heatmap(corr, cmap="RdBu_r", center=0, vmin=-1, vmax=1, square=True,
            linewidths=0.3, cbar_kws={"shrink": 0.7}, ax=ax)
ax.set_title("Matriks korelasi atribut numerik")
save(fig, "correlation.png")

upper_tri = corr.where(np.triu(np.ones(corr.shape, dtype=bool), k=1))
pairs = upper_tri.stack()
pairs = pairs[pairs.abs() > 0.8].sort_values(key=abs, ascending=False)
target_corr = X_num.corrwith(y).abs()
to_drop = []
for (a, b), r in pairs.items():
    if a in to_drop or b in to_drop:
        continue
    to_drop.append(a if target_corr[a] < target_corr[b] else b)
X_reduced = X_final.drop(columns=to_drop)

cum_var = np.cumsum(PCA().fit(X_reduced).explained_variance_ratio_)
n_95 = int(np.argmax(cum_var >= 0.95) + 1)
fig, ax = plt.subplots(figsize=(9, 4.2))
ax.plot(range(1, len(cum_var) + 1), cum_var, marker=".", markersize=3)
ax.axhline(0.95, color="red", linestyle="--", label="95% varians")
ax.axvline(n_95, color="gray", linestyle=":", label=f"{n_95} komponen")
ax.set_xlabel("Jumlah komponen")
ax.set_ylabel("Kumulatif explained variance")
ax.set_title("Kumulatif explained variance PCA")
ax.legend()
save(fig, "pca_variance.png")

pca = PCA(n_components=0.95)
X_pca = pca.fit_transform(X_reduced)
fig, ax = plt.subplots(figsize=(8, 5.5))
sc = ax.scatter(X_pca[:, 0], X_pca[:, 1], c=y, cmap="viridis", s=10, alpha=0.7)
fig.colorbar(sc, label="SalePrice")
ax.set_xlabel(f"PC1 ({pca.explained_variance_ratio_[0]:.1%})")
ax.set_ylabel(f"PC2 ({pca.explained_variance_ratio_[1]:.1%})")
ax.set_title("Data pada ruang PC1 vs PC2")
save(fig, "pca_scatter.png")

print("cap_cols:", cap_cols)
print("pairs:\n", pairs.round(3))
print("target_corr:\n", target_corr[[c for p in pairs.index for c in p]].round(3))
print("dropped:", to_drop)
print("shapes:", X_final.shape, X_reduced.shape, X_pca.shape)
print("var ratio top5:", pca.explained_variance_ratio_[:5].round(4), "cum:", pca.explained_variance_ratio_.sum().round(4))
print("top PC1 loadings:\n", pd.Series(pca.components_[0], index=X_reduced.columns).abs().sort_values(ascending=False).head(8).round(3))
print("capping bounds:\n", pd.DataFrame({"upper": (q3 + 1.5 * iqr)[cap_cols], "max_before": before.max()}).round(1))

// ── Page & text setup ────────────────────────────────────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.8cm, right: 2.8cm),
  numbering: "1",
  footer: context [
    #set text(size: 8.5pt, fill: luma(120))
    #h(1fr) Muhammad Irzam Hafis Fabiansyah · 5054251024 · Data Mining · #counter(page).display("1")
  ],
)
#set text(font: "Libertinus Serif", size: 10.5pt, lang: "id")
#set par(justify: true, leading: 0.72em, spacing: 1.2em)
#set figure.caption(position: bottom, separator: [. ])
#set figure(gap: 0.8em)

// ── Heading style ─────────────────────────────────────────────────────────────
#set heading(numbering: "1.")
#show heading.where(level: 1): it => {
  v(1.1em)
  text(weight: "bold", size: 11pt, it)
  v(0.15em)
  line(length: 100%, stroke: 0.4pt + luma(160))
  v(0.4em)
}
#show heading.where(level: 2): it => {
  v(0.7em)
  text(weight: "bold", size: 10.5pt, it)
  v(0.3em)
}

// ── Table defaults ────────────────────────────────────────────────────────────
#set table(stroke: 0.4pt + luma(160), inset: (x: 6pt, y: 5pt))
#show table.cell.where(y: 0): set text(weight: "bold")
#show table.cell.where(y: 0): set table.cell(fill: luma(235))

// ── Utility: shaded block ─────────────────────────────────────────────────────
#let shaded(body) = block(
  fill: luma(245),
  stroke: (left: 2pt + luma(180)),
  inset: (left: 10pt, right: 8pt, top: 6pt, bottom: 6pt),
  radius: 2pt,
  width: 100%,
  body,
)

// ── START BODY ────────────────────────────────────────────────────────────────

#align(center)[
  #set par(justify: false)
  #v(0.4em)
  #text(size: 16pt, weight: "bold")[Preprocessing Data Harga Rumah: \ Pembersihan, Penanganan Outlier, Transformasi, dan Reduksi Dimensi]
  #v(0.9em)
  #line(length: 60%, stroke: 0.5pt)
  #v(0.6em)
  #text(size: 10pt)[Muhammad Irzam Hafis Fabiansyah · 5054251024 · Praktikum 2 Mata Kuliah Data Mining]
  #v(0.4em)
]

#v(0.8em)
#shaded[
  #text(weight: "bold")[Abstrak — ]Kualitas model prediktif sangat bergantung pada kualitas data masukan. Laporan ini mendokumentasikan tahapan _preprocessing_ terhadap dataset _House Prices_ dari Kaggle yang terdiri atas 1.460 baris dan 81 kolom. Lima kolom dengan nilai hilang di atas 50% dihapus, dan sisa nilai hilang diisi sesuai makna kolomnya berdasarkan dokumentasi dataset. Deteksi outlier dengan boxplot dan aturan IQR menunjukkan bahwa 60% baris memiliki setidaknya satu outlier, sehingga penghapusan massal tidak layak; sebagai gantinya dua baris anomali dihapus dan 12 atribut kontinu disesuaikan dengan _capping_. Atribut numerik distandarisasi dengan z-score dan atribut kategoris di-_encode_ dengan one-hot encoding sehingga diperoleh 294 fitur. Analisis korelasi menghapus empat atribut redundan ($|r| > 0","8$), lalu PCA mereduksi 290 fitur menjadi 77 komponen utama yang mempertahankan 95% varians.

  #v(0.4em)
  #text(weight: "bold")[Kata kunci:] preprocessing, nilai hilang, outlier, standarisasi, one-hot encoding, PCA
]

= Pendahuluan

Data dunia nyata jarang siap dipakai langsung untuk pemodelan. Nilai hilang, pencilan, skala atribut yang berbeda jauh, serta atribut kategoris berbentuk teks perlu ditangani terlebih dahulu @han2011datamining. Selain itu, jumlah atribut yang besar (terlebih setelah _encoding_) dapat membuat model lambat dan rentan _overfitting_, sehingga reduksi dimensi sering diperlukan.

Dataset yang digunakan adalah `train.csv` dari kompetisi _House Prices – Advanced Regression Techniques_ @kaggle2016house, yang berasal dari data penjualan rumah di Ames, Iowa @decock2011ames. Setiap baris mewakili satu rumah dengan 79 atribut penjelas (luas, kualitas, tahun dibangun, lokasi, dan sebagainya) serta target `SalePrice`.

= Metodologi

Seluruh proses dikerjakan dengan Python (Pandas, Matplotlib, Seaborn, scikit-learn) pada notebook `prak2_final.ipynb`.

+ *Import data.* `train.csv` diunduh dengan `kagglehub`, dibaca dengan Pandas, lalu diperiksa dengan `.head()`, `.shape`, dan `.info()`.
+ *Pembersihan data.* Jumlah nilai hilang dihitung per atribut; atribut dengan proporsi hilang $> 50%$ dihapus, dan sisanya diisi berdasarkan makna kolom.
+ *Deteksi dan penanganan outlier.* Boxplot dan aturan IQR ($< Q_1 - 1","5 dot "IQR"$ atau $> Q_3 + 1","5 dot "IQR"$) dipakai untuk mendeteksi outlier, kemudian ditangani dengan penghapusan selektif dan _capping_.
+ *Transformasi.* Atribut numerik distandarisasi ($z = (x - mu) \/ sigma$) dan atribut kategoris di-_encode_ dengan one-hot encoding.
+ *Reduksi dimensi.* Pasangan atribut dengan korelasi Pearson $|r| > 0","8$ dicari dan salah satunya dibuang; kemudian PCA diterapkan dengan jumlah komponen yang menjaga 95% varians.

= Hasil dan Pembahasan

== Struktur Data

Dataset terdiri atas 1.460 baris dan 81 kolom: 43 kolom bertipe teks, 35 bertipe `int64`, dan 3 bertipe `float64`. Kolom `Id` hanya berfungsi sebagai penanda baris sehingga dibuang, dan `SalePrice` dipisahkan sebagai target. Tidak ditemukan baris duplikat. Keluaran `.info()` menunjukkan beberapa kolom memiliki jumlah _non-null_ jauh di bawah 1.460, yang menandakan adanya nilai hilang.

== Pembersihan Data

Sebanyak 19 atribut memiliki nilai hilang (@fig-missing). Lima di antaranya melewati batas 50% sehingga dihapus: `PoolQC` (99,5%), `MiscFeature` (96,3%), `Alley` (93,8%), `Fence` (80,8%), dan `MasVnrType` (59,7%). Menurut dokumentasi dataset, nilai kosong pada kolom-kolom ini sebenarnya berarti "tidak memiliki" (misalnya tidak ada kolam renang), namun karena hampir seluruh rumah tidak memilikinya, informasi yang dibawa sangat sedikit.

#figure(
  image("assets/missing.png", width: 100%),
  caption: [Persentase nilai hilang per atribut; merah menandai atribut yang dihapus],
) <fig-missing>

Sisa nilai hilang ditangani sesuai makna kolomnya, bukan dengan satu strategi seragam, seperti dirangkum pada @tab-impute. Setelah langkah ini tidak ada lagi nilai hilang, dan data berukuran 1.460 baris × 75 kolom.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, left, left),
    [Atribut], [Arti nilai kosong], [Penanganan],
    [`FireplaceQu`, `Garage*`, `Bsmt*` (kategoris)], [rumah tidak memiliki perapian/garasi/basement], [diisi kategori `"None"`],
    [`GarageYrBlt`], [tidak ada garasi], [diisi `YearBuilt` (nilai 0 akan menjadi outlier ekstrem)],
    [`MasVnrArea`], [tidak ada _veneer_], [diisi 0],
    [`LotFrontage` (17,7%)], [tidak tercatat], [median per `Neighborhood`],
    [`Electrical` (1 baris)], [tidak tercatat], [diisi modus],
  ),
  caption: [Strategi penanganan sisa nilai hilang],
) <tab-impute>

== Deteksi dan Penanganan Outlier

Sebelum deteksi, `MSSubClass` diubah menjadi atribut kategoris karena nilainya (20, 60, 120, …) merupakan kode tipe rumah, bukan besaran. Boxplot untuk 35 atribut numerik ditampilkan pada @fig-boxplots.

#figure(
  image("assets/boxplots.png", width: 100%),
  caption: [Boxplot seluruh atribut numerik],
) <fig-boxplots>

Dengan aturan IQR, 870 dari 1.460 baris (60%) memiliki minimal satu outlier. Menghapus semua baris tersebut akan membuang lebih dari separuh data, sehingga tidak layak. Selain itu, sebagian besar "outlier" merupakan nilai yang valid:

- Sembilan atribut memiliki IQR = 0 (`PoolArea`, `MiscVal`, `ScreenPorch`, `EnclosedPorch`, dll.) karena mayoritas nilainya 0; setiap rumah yang memiliki fitur tersebut otomatis tergolong outlier.
- Atribut diskret/ordinal seperti `OverallCond`, `BedroomAbvGr`, dan `KitchenAbvGr` ditandai outlier padahal nilainya wajar.

Oleh karena itu, penanganan dilakukan dalam tiga bentuk:

+ *Dihapus:* dua rumah dengan `GrLivArea` $> 4.000$ sqft tetapi `SalePrice` $< 300.000$ (@fig-anomaly). Rumah ini jauh menyimpang dari tren luas–harga dan merupakan penjualan parsial; pembuat dataset sendiri menyarankan menghapus rumah di atas 4.000 sqft @decock2011ames.
+ *Disesuaikan (_capping_):* 12 atribut kontinu (`LotFrontage`, `LotArea`, `MasVnrArea`, `BsmtFinSF1`, `BsmtUnfSF`, `TotalBsmtSF`, `1stFlrSF`, `2ndFlrSF`, `GrLivArea`, `GarageArea`, `WoodDeckSF`, `OpenPorchSF`) dipotong ke batas IQR. Data tidak hilang, tetapi nilai ekstrem seperti `LotArea` 215.245 (dipotong ke $approx$ 17.683) tidak lagi mendominasi standarisasi dan PCA (@fig-capping).
+ *Dibiarkan:* atribut tahun, atribut diskret/ordinal, dan atribut ber-IQR 0, karena _capping_ justru akan merusak informasinya (misalnya `PoolArea` akan menjadi 0 seluruhnya).

#figure(
  image("assets/anomaly.png", width: 78%),
  caption: [Hubungan `GrLivArea` dan `SalePrice`; titik merah adalah dua baris yang dihapus],
) <fig-anomaly>

#figure(
  image("assets/capping.png", width: 100%),
  caption: [Boxplot atribut kontinu sebelum (atas) dan sesudah (bawah) _capping_],
) <fig-capping>

Setelah tahap ini data berukuran 1.458 baris × 75 kolom.

== Transformasi Data

*Standarisasi.* Ke-35 atribut numerik ditransformasi dengan z-score sehingga masing-masing memiliki rerata 0 dan simpangan baku 1. Standarisasi dipilih dibanding normalisasi min-max karena (1) PCA bekerja berdasarkan varians sehingga seluruh atribut harus berada pada skala yang sama, dan (2) min-max sangat bergantung pada nilai minimum dan maksimum sehingga lebih sensitif terhadap sisa nilai ekstrem. Target `SalePrice` tidak ikut ditransformasi.

*One-hot encoding.* Sebanyak 39 atribut kategoris diubah menjadi kolom biner 0/1 per kategori. Hasilnya 259 kolom _dummy_, sehingga total fitur menjadi 294 (35 numerik + 259 _dummy_). Lonjakan dimensi ini menjadi alasan utama perlunya reduksi dimensi.

== Reduksi Dimensi

=== Analisis Korelasi

Korelasi Pearson dihitung pada atribut numerik (@fig-corr). Dari setiap pasangan dengan $|r| > 0","8$, atribut yang korelasinya terhadap `SalePrice` lebih lemah dibuang (@tab-corr).

#figure(
  image("assets/correlation.png", width: 88%),
  caption: [Matriks korelasi Pearson atribut numerik setelah standarisasi],
) <fig-corr>

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, left, center, center, left),
    [Atribut 1], [Atribut 2], [$r$], [$|r|$ terhadap `SalePrice`], [Dibuang],
    [`GarageCars`], [`GarageArea`], [0,894], [0,641 / 0,633], [`GarageArea`],
    [`YearBuilt`], [`GarageYrBlt`], [0,845], [0,524 / 0,509], [`GarageYrBlt`],
    [`GrLivArea`], [`TotRmsAbvGrd`], [0,834], [0,712 / 0,538], [`TotRmsAbvGrd`],
    [`TotalBsmtSF`], [`1stFlrSF`], [0,805], [0,640 / 0,624], [`1stFlrSF`],
  ),
  caption: [Pasangan atribut berkorelasi tinggi dan atribut yang dibuang],
) <tab-corr>

Keempat pasangan tersebut masuk akal secara domain: garasi yang lebih luas menampung lebih banyak mobil; garasi umumnya dibangun bersamaan dengan rumah (apalagi nilai kosong `GarageYrBlt` diisi `YearBuilt`); luas lantai yang lebih besar berarti lebih banyak ruangan; dan basement biasanya berada tepat di bawah lantai pertama dengan luas yang mirip. Setelah langkah ini fitur berkurang dari 294 menjadi 290.

=== Principal Component Analysis

PCA @jolliffe2016pca diterapkan pada seluruh 290 fitur. Kurva kumulatif _explained variance_ (@fig-pca-var) menunjukkan bahwa 77 komponen utama sudah cukup untuk menjelaskan 95% varians data, atau berkurang sekitar 73% dari jumlah fitur sebelumnya.

#figure(
  image("assets/pca_variance.png", width: 88%),
  caption: [Kumulatif _explained variance_ terhadap jumlah komponen],
) <fig-pca-var>

Komponen pertama (PC1) menjelaskan 15,5% varians, diikuti PC2 (7,2%) dan PC3 (6,0%). Atribut dengan _loading_ terbesar pada PC1 adalah `OverallQual` (0,313), `GarageCars` (0,277), `YearBuilt` (0,276), `GrLivArea` (0,271), dan `FullBath` (0,262), sehingga PC1 dapat dimaknai sebagai "ukuran, kualitas, dan kebaruan rumah". Hal ini terlihat pada @fig-pca-scatter, di mana warna harga rumah bergradasi mengikuti sumbu PC1.

#figure(
  image("assets/pca_scatter.png", width: 80%),
  caption: [Proyeksi data pada PC1 dan PC2, diwarnai berdasarkan `SalePrice`],
) <fig-pca-scatter>

Perlu dicatat bahwa kolom _dummy_ 0/1 memiliki varians yang jauh lebih kecil dibanding atribut numerik terstandarisasi (varians 1), sehingga komponen-komponen awal PCA lebih banyak ditentukan oleh atribut numerik.

= Kesimpulan

Tahapan _preprocessing_ mengubah dataset _House Prices_ dari 1.460 × 81 menjadi matriks 1.458 × 77 yang bersih, berskala seragam, dan jauh lebih ringkas (@tab-summary).

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, center),
    [Tahap], [Perlakuan], [Ukuran data],
    [Import], [membaca `train.csv`], [1.460 × 81],
    [Pembersihan], [hapus 5 atribut > 50% hilang dan `Id`; imputasi sesuai makna kolom], [1.460 × 75],
    [Outlier], [hapus 2 baris anomali; _capping_ IQR pada 12 atribut kontinu], [1.458 × 75],
    [Transformasi], [standarisasi z-score; one-hot encoding (target dipisah)], [1.458 × 294],
    [Korelasi], [buang 4 atribut dengan $|r| > 0","8$], [1.458 × 290],
    [PCA], [95% varians dipertahankan], [1.458 × 77],
  ),
  caption: [Ringkasan perubahan data pada setiap tahap],
) <tab-summary>

Keputusan penting pada proses ini adalah tidak menangani seluruh nilai hilang dan outlier dengan cara yang sama: makna tiap kolom menentukan apakah nilai kosong berarti "tidak ada" atau "tidak tercatat", dan apakah sebuah outlier merupakan kesalahan atau variasi yang wajar. Data hasil PCA beserta target `SalePrice` siap digunakan untuk tahap pemodelan regresi.

= Referensi

#bibliography("references.bib", style: "ieee", full: true, title: none)

// ── Page & text setup ────────────────────────────────────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.8cm, right: 2.8cm),
  numbering: "1",
  footer: context [
    #set text(size: 8.5pt, fill: luma(120))
    #h(1fr) Kelompok 10 · Mata Kuliah Data Mining · #counter(page).display("1")
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

// ── START BODY
─────────────────────────────────────────────────────

#align(center)[
  #v(0.4em)
  #text(size: 16pt, weight: "bold")[Analisis Eksploratif Dataset Penyakit Jantung]
  #v(0.9em)
  #line(length: 60%, stroke: 0.5pt)
  #v(0.6em)
  #text(size: 10pt)[Kelompok 10 · Mata Kuliah Data Mining]
  #v(0.4em)
]

#v(0.8em)
#shaded[
  #text(weight: "bold")[Abstrak — ]Penyakit jantung adalah salah satu masalah kesehatan yang memerlukan identifikasi faktor risiko secara sistematis. Dokumen ini menyajikan Exploratory Data Analysis (EDA) terhadap dataset klinis penyakit jantung yang terdiri atas 1.025 baris dan 14 fitur. Analisis mencakup pemeriksaan struktur data, nilai hilang, duplikasi, statistik deskriptif, distribusi fitur, korelasi Pearson, perbandingan fitur numerik berdasarkan target, dan distribusi fitur kategorikal. Dataset tidak memiliki nilai hilang, tetapi mengandung 723 baris duplikat sehingga analisis lanjutan dilakukan pada 302 observasi unik. Pada data bersih, kelas target relatif seimbang: 138 observasi tanpa indikasi penyakit dan 164 dengan indikasi penyakit. Korelasi positif terkuat terhadap target ditemukan pada `cp` ($r = 0,43$) dan `thalach` ($r = 0,42$), sedangkan korelasi negatif terkuat ditemukan pada `exang` ($r = -0,44$), `oldpeak` ($r = -0,43$), dan `ca` ($r = -0,41$). Seluruh temuan bersifat eksploratif dan tidak dapat diartikan sebagai hubungan sebab-akibat maupun diagnosis klinis.

  #v(0.4em)
  #text(weight: "bold")[Kata kunci:] penyakit jantung, analisis data eksploratif, korelasi Pearson, statistik deskriptif, visualisasi data
]

= Latar Belakang

Penyakit jantung dipengaruhi oleh banyak faktor demografis, fisiologis, dan klinis. Dataset yang terstruktur membantu mengidentifikasi pola awal pada pasien, memahami hubungan antarfitur, dan menentukan variabel yang relevan untuk analisis lanjutan. Eksplorasi data sebelum pemodelan sangat penting agar masalah seperti duplikasi, ketidakseimbangan kelas, rentang nilai ekstrem, dan korelasi antarvariabel dapat terdeteksi lebih awal.

Pendekatan EDA merangkum karakteristik data melalui tabel statistik dan visualisasi. Dalam analisis ini, perhatian diberikan pada usia (`age`), tekanan darah istirahat (`trestbps`), kolesterol (`chol`), detak jantung maksimum (`thalach`), depresi segmen ST (`oldpeak`), serta fitur kategorikal seperti tipe nyeri dada (`cp`), angina akibat olahraga (`exang`), dan hasil pemeriksaan lainnya. Tujuan utamanya adalah menghasilkan gambaran menyeluruh mengenai kualitas data dan pola yang berkaitan dengan variabel target.

= Metodologi

Tahapan analisis yang dilakukan adalah sebagai berikut.

+ *Pengumpulan data.* Dataset `heart_disease_dataset.csv` dibaca menggunakan Pandas dari folder data proyek.
+ *Pembersihan data.* Struktur data, nilai hilang, dan duplikasi diperiksa. Baris duplikat dihapus sebelum statistik dan visualisasi lanjutan dihitung.
+ *Analisis deskriptif.* Ukuran data, statistik numerik, frekuensi nilai, dan proporsi target dihitung.
+ *Visualisasi EDA.* Distribusi fitur, matriks korelasi, boxplot berdasarkan target, dan countplot fitur kategorikal dibuat menggunakan Matplotlib dan Seaborn.
+ *Interpretasi.* Temuan dirangkum dengan catatan bahwa korelasi tidak membuktikan hubungan sebab-akibat.

= Hasil dan Pembahasan

== Struktur dan Kualitas Data

Dataset awal terdiri atas 1.025 baris dan 14 kolom. Dataset diperoleh dari dosen mata kuliah sebagai bahan praktikum. Seluruh kolom tidak memiliki nilai hilang. Pemeriksaan duplikasi menemukan 723 baris duplikat sehingga jumlah observasi unik menjadi 302. Penghapusan duplikasi dilakukan agar satu observasi tidak diberi bobot berulang pada statistik dan visualisasi.

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    [Pemeriksaan], [Sebelum pembersihan], [Setelah pembersihan],
    [Jumlah baris], [1.025], [302],
    [Jumlah kolom], [14], [14],
    [Baris duplikat], [723], [0],
    [Nilai hilang], [0], [0],
  ),
  caption: [Ringkasan kualitas dataset],
)

Distribusi target pada data bersih adalah 138 observasi untuk `target = 0` (tidak ada indikasi penyakit) dan 164 observasi untuk `target = 1` (ada indikasi penyakit). Selisih yang kecil ini menunjukkan bahwa kelas target tidak mengalami ketimpangan yang ekstrem pada tahap eksplorasi.

== Statistik Deskriptif

Tabel berikut merangkum statistik fitur numerik utama setelah duplikasi dihapus. Rata-rata usia pasien adalah 54,42 tahun dan detak jantung maksimum rata-rata 149,57 denyut per menit. Nilai `oldpeak` memiliki rentang 0,0 hingga 6,2 dengan standar deviasi yang cukup besar relatif terhadap mediannya (0,80), mengindikasikan adanya pencilan ke arah atas.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center, center),
    [Statistik], [`age`], [`trestbps`], [`chol`], [`thalach`], [`oldpeak`],
    [Rerata], [54,42], [131,60], [246,50], [149,57], [1,04],
    [Median], [55,50], [130,00], [240,50], [152,50], [0,80],
    [Minimum], [29,00], [94,00], [126,00], [71,00], [0,00],
    [Maksimum], [77,00], [200,00], [564,00], [202,00], [6,20],
  ),
  caption: [Statistik deskriptif fitur numerik pada 302 observasi unik],
)

== Distribusi dan Perbandingan Fitur

Visualisasi distribusi membantu mengidentifikasi bentuk sebaran data dan kemungkinan pencilan. Fitur numerik memiliki rentang yang sangat berbeda, sedangkan sebagian fitur kategorikal dikodekan sebagai bilangan bulat diskrit. Kode tersebut diperlakukan sebagai kategori dalam countplot, bukan sebagai nilai kontinu.

#figure(
  image("assets/distributions.png", width: 100%),
  caption: [Distribusi fitur numerik pada data bersih],
)

Berdasarkan boxplot, kelompok `target = 0` memiliki nilai tengah usia, tekanan darah, kolesterol, dan `oldpeak` yang lebih tinggi dibandingkan kelompok `target = 1`. Sebaliknya, `thalach` rata-rata lebih tinggi pada kelompok `target = 1`. Perbedaan distribusi ini memberikan indikasi awal yang berguna untuk analisis prediktif, tetapi belum cukup untuk menarik kesimpulan diagnostik.

#figure(
  image("assets/boxplots.png", width: 100%),
  caption: [Perbandingan fitur numerik berdasarkan target],
)

== Korelasi Antarfitur

Korelasi Pearson digunakan untuk merangkum hubungan linear antarvariabel numerik. Tabel berikut menyajikan nilai korelasi setiap fitur terhadap target, diurutkan dari yang terkuat.

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, center, left),
    [Fitur], [Korelasi terhadap target], [Arah dan kekuatan],
    [`exang`], [-0,436], [Negatif, sedang],
    [`cp`], [0,432], [Positif, sedang],
    [`oldpeak`], [-0,429], [Negatif, sedang],
    [`thalach`], [0,420], [Positif, sedang],
    [`ca`], [-0,409], [Negatif, sedang],
    [`slope`], [0,344], [Positif, lemah–sedang],
    [`thal`], [-0,343], [Negatif, lemah–sedang],
    [`chol`], [-0,081], [Sangat lemah],
    [`fbs`], [-0,027], [Sangat lemah],
  ),
  caption: [Korelasi Pearson fitur terhadap target, diurutkan berdasarkan nilai absolut],
)

#figure(
  image("assets/correlation.png", width: 84%),
  caption: [Matriks korelasi fitur numerik],
)

Korelasi antarfitur independen yang paling menonjol terdapat pada pasangan `slope`–`oldpeak` ($r approx -0{,}58$), yang menunjukkan bahwa kedua fitur tersebut sebagian berbagi informasi yang sama. Fitur `chol` dan `fbs` memiliki korelasi yang sangat lemah terhadap target sehingga kontribusinya tidak dapat dinilai dari koefisien Pearson saja; pengujian nonparametrik atau pemodelan lebih lanjut diperlukan untuk mengevaluasi relevansinya.

== Distribusi Fitur Kategorikal

Countplot fitur kategorikal memperlihatkan komposisi target pada setiap kategori. Beberapa kategori menunjukkan dominasi yang jelas terhadap salah satu kelas target, terutama pada `cp`, `exang`, `ca`, dan `thal`. Pola ini dapat menjadi titik awal untuk analisis lanjutan, namun interpretasinya perlu memperhatikan jumlah sampel pada setiap kategori agar tidak overfit terhadap pola kecil.

#figure(
  image("assets/categorical.png", width: 100%),
  caption: [Distribusi fitur kategorikal berdasarkan target],
)

= Kesimpulan

EDA terhadap dataset penyakit jantung menunjukkan bahwa data awal terdiri atas 1.025 baris dan 14 fitur, tanpa nilai hilang, tetapi mengandung 723 duplikasi. Setelah pembersihan, analisis dilakukan pada 302 observasi unik dengan distribusi target yang relatif seimbang. Di antara seluruh fitur, `exang`, `cp`, `oldpeak`, `thalach`, dan `ca` memiliki korelasi linear paling kuat terhadap target.

Visualisasi boxplot juga menunjukkan perbedaan distribusi yang konsisten pada `thalach` dan `oldpeak` antarkelas target. Temuan ini dapat digunakan sebagai pijakan untuk tahap berikutnya seperti pengujian hipotesis statistik, seleksi fitur, atau pemodelan klasifikasi dengan validasi silang. Mengingat dataset bersifat observasional dan fitur dikodekan secara kategorikal, hasil EDA ini tidak boleh diartikan sebagai diagnosis klinis maupun bukti hubungan sebab-akibat.

= Referensi

#bibliography("references.bib", style: "ieee", full: true, title: none)

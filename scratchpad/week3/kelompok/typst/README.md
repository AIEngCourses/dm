# Laporan EDA dalam Typst

Folder ini berisi naskah Typst berdasarkan notebook `EDA_Datmin_Kelompok_10.ipynb` dan gaya struktur dari `Contoh Makalah EDA.pdf`.

## Isi

- `main.typ`: naskah utama laporan.
- `references.bib`: referensi dataset dan EDA.
- `generate_figures.py`: membuat grafik dari CSV yang dipakai notebook.
- `assets/`: grafik hasil generator.

## Membuat grafik

Dari folder ini jalankan:

```sh
uv run python generate_figures.py
```

Skrip membaca `../data/heart_disease_dataset.csv`, menghapus duplikasi, lalu menulis empat grafik ke folder `assets/`.

## Build Typst

Pasang Typst terlebih dahulu jika belum tersedia, lalu jalankan dari folder ini:

```sh
typst compile main.typ
```

Hasil PDF akan dibuat sebagai `main.pdf`. Bila instalasi Typst tidak menggunakan font Libertinus Serif, ganti nilai `font` pada `main.typ` dengan font serif yang tersedia di sistem.

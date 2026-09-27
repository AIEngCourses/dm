# Laporan Praktikum 2 dalam Typst

Naskah Typst berdasarkan notebook `../prak2_final.ipynb` (preprocessing dataset House Prices).

## Isi

- `main.typ`: naskah utama laporan.
- `references.bib`: referensi dataset dan metode.
- `generate_figures.py`: menjalankan ulang pipeline notebook dan menyimpan grafik.
- `assets/`: grafik hasil generator.

## Membuat grafik

Dari folder ini jalankan:

```sh
uv run python generate_figures.py
```

Skrip mengunduh `train.csv` lewat `kagglehub` (butuh kredensial Kaggle di `.env`, atau memakai cache yang sudah ada), lalu menulis grafik ke `assets/` dan mencetak angka-angka yang dikutip di laporan.

## Build Typst

```sh
typst compile main.typ
```

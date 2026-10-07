# JAGAIN

Aplikasi lokal-first untuk mencatat aset penting, mengingat tanggung jawab perawatannya, dan menyimpan riwayat tindakan.

## Persyaratan

- Flutter stable (proyek dibuat dengan Flutter 3.47.6 dan Dart 3.13.5)
- Android Studio, Android SDK, dan JDK yang didukung Flutter untuk build Android
- macOS dengan Xcode untuk build, signing, dan rilis iOS

## Menjalankan di Android

```powershell
flutter doctor
flutter pub get
flutter devices
flutter run
```

Membuat APK release:

```powershell
flutter build apk --release
```

APK akan berada di `build/app/outputs/flutter-apk/app-release.apk`.

## Menjalankan di iOS

Folder proyek iOS sudah disiapkan. Build iOS memerlukan Mac dengan Xcode dan CocoaPods:

```sh
flutter doctor
flutter pub get
cd ios && pod install && cd ..
flutter run -d ios
```

Atur signing Team dan provisioning profile di Xcode sebelum instalasi perangkat atau rilis App Store.

## Identitas aplikasi

- Nama aplikasi: JAGAIN
- Android application ID / iOS bundle ID: `id.jagain.jagain`
- Versi awal: `1.0.0+1`
- Bahasa antarmuka: Indonesia
- Font: Poppins (judul), Inter (teks dan detail UI)
- Warna inti: `#14B8A6`, `#0F766E`, `#3B82F6`, `#111827`, `#ECFDF5`, `#E0F2FE`

Dependensi dasar mencakup Riverpod, Drift/SQLite, penyimpanan path lokal, notifikasi lokal, dan `intl`. Model domain aset, kategori, kejadian, dan pengingat tersedia di `lib/features/`.

## Status fondasi

Navigasi dan layar awal sudah disiapkan: Beranda, Aset, Pengingat, Aktivitas, dan Pengaturan. Alur penyimpanan SQLite, CRUD aset/pengingat, penjadwalan notifikasi, onboarding, backup terenkripsi, serta ikon final bermerek masih perlu diimplementasikan. Data belum disimpan persisten pada tahap fondasi ini.

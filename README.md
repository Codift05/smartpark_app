# SmartPark App

SmartPark App adalah aplikasi mobile yang dibangun menggunakan Flutter (Dart) untuk mensimulasikan dan menampilkan informasi terkait kepadatan lahan parkir, statistik harian, dan navigasi ke halaman peta serta slot parkir. Proyek ini ditujukan sebagai basis pengembangan aplikasi lintas platform (Android/iOS) dengan dukungan pengembangan di Web dan Desktop.

## Ringkasan
- Target utama: Aplikasi mobile (Android/iOS) berbasis Flutter
- Bahasa pemrograman: Dart
- Framework UI: Flutter (Material Design)
- Platform pengembangan tambahan: Web (Chrome), Desktop (Windows/Linux/macOS)
- Arsitektur sederhana dan terstruktur: `models`, `services`, `pages`, `ui`

## Fitur Utama
- Prediksi kepadatan parkir (simulasi) dan indikator status (rendah/sedang/tinggi)
- Statistik harian: tingkat penggunaan, estimasi kunjungan, dan waktu puncak
- Navigasi bawah (bottom navigation) ke halaman: Home, Map, Stats
- Halaman Peta (mock) dan halaman Slot (mock) untuk eksplorasi UI

## Teknologi yang Digunakan
- Flutter 3.x dan Dart
- Material Design components
- Widget testing dasar (`test/widget_test.dart`)
- PWA/Web assets melalui folder `web/` (favicon, icons, `manifest.json`)

## Struktur Direktori
```
lib/
  main.dart                // entry point aplikasi
  models/                  // model data (mis. prediction, slot)
  services/                // layanan/mock data (mis. mock_parking_service)
  pages/                   // halaman UI (home, map, slots, stats)
  ui/                      // style/theme utilitas
web/                       // aset untuk Flutter Web (index.html, manifest)
android/, ios/, windows/, linux/, macos/ // artefak platform
```

## Arsitektur & Pola
- State sederhana di dalam widget (tanpa state management eksternal)
- Pemisahan tanggung jawab: model → layanan → halaman → style
- Debug banner dinonaktifkan di `MaterialApp` (lihat `lib/main.dart`) agar tampilan lebih bersih

## Menjalankan Proyek
1. Pastikan Flutter SDK sudah terpasang dan `flutter doctor` bersih.
2. Instal dependencies:
   ```
   flutter pub get
   ```
3. Jalankan di perangkat yang diinginkan:
   - Android: ```flutter run -d android```
   - iOS (macOS): ```flutter run -d ios```
   - Web (Chrome): ```flutter run -d chrome```
   - Windows/Linux/macOS: ```flutter run -d windows|linux|macos```

## Build Release
- Android (APK/AAB):
  ```
  flutter build apk
  flutter build appbundle
  ```
- iOS (butuh Xcode/macOS):
  ```
  flutter build ios
  ```
- Web:
  ```
  flutter build web
  ```

## Kualitas Kode
- Analisis statis: ```flutter analyze```
- Format kode: ```dart format .```
- Tes: ```flutter test```

## Kontribusi
Kontribusi sangat diterima. Buat branch fitur, lakukan perubahan terfokus, sertakan deskripsi yang jelas pada PR, dan pastikan lint serta test berjalan.

## Kontributor
<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Codift05">
        <img src="https://github.com/Codift05.png" width="100px;" alt=""/>
        <br />
        <sub><b>Codift05</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/FlxSlm">
        <img src="https://github.com/FlxSlm.png" width="100px;" alt=""/>
        <br />
        <sub><b>FlxSlm</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/edwardsajaaa">
        <img src="https://github.com/edwardsajaaa.png" width="100px;" alt=""/>
        <br />
        <sub><b>edwardsajaaa</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/Patricklumowa">
        <img src="https://github.com/Patricklumowa.png" width="100px;" alt=""/>
        <br />
        <sub><b>Patricklumowa</b></sub>
      </a>
    </td>
  </tr>
</table>

## Catatan
- Proyek ini difokuskan sebagai contoh/starting point aplikasi parkir dengan data simulasi.
- Penyesuaian data nyata, integrasi API, dan state management lanjutan dapat ditambahkan sesuai kebutuhan.

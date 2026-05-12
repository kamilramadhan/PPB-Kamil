# HimpunApp AI

HimpunApp AI adalah aplikasi Flutter untuk manajemen organisasi himpunan yang dipadukan dengan fitur AI lokal. Aplikasi ini mendukung autentikasi Firebase, manajemen anggota/divisi/agenda, notifikasi, face detection untuk absensi pintar, dan OCR untuk ekstraksi teks dari gambar.

## Fitur Utama

- Autentikasi login dan registrasi berbasis Firebase.
- Dashboard organisasi dengan navigasi ke anggota, divisi, agenda, dan profil.
- Smart attendance berbasis deteksi wajah.
- OCR scanner untuk membaca teks dari kamera atau galeri.
- Model YOLO on-device untuk deteksi objek secara lokal.
- Notifikasi lokal untuk pengingat dan alur kerja aplikasi.
- Dukungan Firestore untuk penyimpanan data cloud.

## Teknologi

- Flutter
- Firebase Auth
- Cloud Firestore
- Provider
- Google ML Kit Text Recognition
- Google ML Kit Face Detection
- Ultralytics YOLO
- Flutter Local Notifications

## Preview Fitur

Gambar preview fitur disimpan di folder [image/README](image/README).

| Login | Dashboard | Face Detection | OCR Scanner |
| --- | --- | --- | --- |
| ![Login](image/README/login-preview.svg) | ![Dashboard](image/README/dashboard-preview.svg) | ![Face Detection](image/README/face-detection-preview.svg) | ![OCR Scanner](image/README/ocr-preview.svg) |

## Struktur Aplikasi

- `lib/features/auth` untuk login dan registrasi.
- `lib/features/dashboard` untuk navigasi utama.
- `lib/features/member` untuk data anggota.
- `lib/features/division` untuk data divisi.
- `lib/features/agenda` untuk agenda kegiatan.
- `lib/features/smart_attendance` untuk absensi wajah.
- `lib/features/ocr_scanner` untuk ekstraksi teks.
- `lib/features/yolo_detection` untuk deteksi objek YOLO.

## Menjalankan Aplikasi

1. Jalankan `flutter pub get`.
2. Pastikan konfigurasi Firebase pada `lib/firebase_options.dart` dan `android/app/google-services.json` sudah sesuai.
3. Jalankan aplikasi dengan `flutter run` pada device yang didukung.

## Asset AI

Model YOLO lokal disimpan di `assets/models/yolo11n_int8.tflite` dan sudah didaftarkan di `pubspec.yaml`.

<img width="739" height="1600" alt="WhatsApp Image 2026-05-12 at 21 02 08" src="https://github.com/user-attachments/assets/6fd39229-b229-45e5-869f-2cb2b8f62333" />
<img width="739" height="1600" alt="WhatsApp Image 2026-05-12 at 21 02 08 (1)" src="https://github.com/user-attachments/assets/0486e392-3394-4838-9b4f-69427b919a9d" />
<img width="739" height="1600" alt="WhatsApp Image 2026-05-12 at 21 02 08 (2)" src="https://github.com/user-attachments/assets/4b30a8b8-6d51-4069-8b8f-374a42af76d2" />
<img width="739" height="1600" alt="WhatsApp Image 2026-05-12 at 21 02 08 (3)" src="https://github.com/user-attachments/assets/4d66c592-5bbc-4e8c-9ebd-8c8e5b9d8e78" />
<img width="739" height="1600" alt="WhatsApp Image 2026-05-12 at 21 02 07" src="https://github.com/user-attachments/assets/3668ef20-2354-4a6d-b335-7d087087efad" />


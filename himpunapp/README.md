# HimpunApp

HimpunApp adalah aplikasi manajemen organisasi mahasiswa berbasis web yang dibangun menggunakan framework Flutter. Proyek ini dikembangkan untuk memenuhi tugas akhir "Mini Project", dengan fokus pada integrasi basis data komputasi awan (cloud database), sistem autentikasi, serta pemanfaatan perangkat keras pengguna.

## Video Demonstrasi

Demonstrasi lengkap mengenai fungsionalitas aplikasi ini dapat dilihat pada tautan berikut:
https://youtu.be/wkrlICExuVg

## Fitur Utama

Aplikasi ini mengimplementasikan lima kriteria persyaratan utama:

1. **CRUD dengan Basis Data**
   Implementasi penuh untuk operasi Create, Read, Update, dan Delete menggunakan Firebase Firestore. Aplikasi ini mengelola berbagai entitas relasional termasuk data Anggota, Divisi, dan Agenda kegiatan.

2. **Autentikasi Firebase**
   Sistem login dan registrasi pengguna yang aman menggunakan layanan Firebase Authentication.

3. **Penyimpanan Data di Firebase**
   Penyimpanan data yang persisten menggunakan Cloud Firestore. Sistem ini menyimpan teks dan gambar foto profil yang diubah ke dalam format Base64 sebelum disimpan ke dalam basis data guna efisiensi penyimpanan.

4. **Sistem Notifikasi**
   Implementasi pusat notifikasi di dalam aplikasi (in-app) dan notifikasi tingkat sistem operasi (browser push notifications). Notifikasi dipicu secara otomatis ketika terdapat aktivitas tertentu, seperti penambahan anggota atau pembaruan agenda.

5. **Pemanfaatan Perangkat Keras (Kamera)**
   Integrasi dengan kamera perangkat keras menggunakan teknologi WebRTC. Pengguna dapat mengambil foto secara langsung melalui peramban (browser) web mereka untuk memperbarui foto profil atau menambahkan foto anggota baru.



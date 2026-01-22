# 📖 Quran Journey (Quran Tracker)

Aplikasi **Flutter** untuk membaca Al-Qur’an dengan tampilan **Mushaf Madinah**, audio murattal, dan navigasi halaman seperti mushaf cetak.

---

## ✨ Fitur Utama

- 📄 Mushaf Madinah (604 halaman)
- 🕌 Header surah & Bismillah otomatis
- 🎧 Audio murattal (play, pause, next, previous)
- 🔍 Loncat ke halaman
- 📖 PageView RTL (kanan ke kiri)
- 🎨 Tema Mushaf (paper brown style)

---

## 🛠️ Teknologi

- Flutter
- Dart
- API: https://api.quran.com
- Font: Uthmani Hafs

---

## 📦 Requirements

- Flutter >= 3.x
- Dart >= 3.x
- Android Studio / VS Code
- Android Emulator / iOS Simulator / Device fisik

## 🩺 Flutter Doctor

Pastikan environment Flutter sudah siap:
```bash
flutter doctor
```

---

## 🚀 Cara Menjalankan Project

### 1. Clone Repository
```bash
git clone https://github.com/wisnufebriramadhan/quran-journey.git
cd quran-journey
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Jalankan Aplikasi
```bash
flutter run
```

**Pilih device tertentu:**
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## 📂 Struktur Folder
```
lib/
├── core/
│   └── models/
│       ├── quran_verse.dart
│       └── surah_data.dart
├── features/
│   └── mushaf/
│       ├── data/
│       │   └── quran_page_service.dart
│       └── presentation/
│           └── mushaf_page_view.dart
└── main.dart
```

---

## 📄 Sumber Data Al-Qur'an

Data ayat & halaman menggunakan:
- API: `https://api.quran.com/api/v4`
- Disesuaikan dengan **Mushaf Madinah** dan teks **Uthmani**

---

## ⚠️ Catatan Penting

Folder berikut **tidak boleh di-commit**:
```
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
```

Pastikan `.gitignore` sudah benar.

---

## 📜 License

[Apache License 2.0](LICENSE)

---

## 🤝 Kontribusi

Pull request sangat diterima!  
Untuk perubahan besar, silakan buka issue terlebih dahulu.

---

## 📧 Kontak

**Wisnu Febri Ramadhan**  
GitHub: [@wisnufebriramadhan](https://github.com/wisnufebriramadhan)


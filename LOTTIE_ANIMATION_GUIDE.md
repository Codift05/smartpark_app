# 🎨 Lottie Animation Guide - Seperti Gojek/Grab

## 🌟 Apa itu Lottie?

**Lottie** adalah library animasi yang digunakan oleh aplikasi besar seperti:
- ✅ **Gojek** - Animasi motor, mobil, loading
- ✅ **Grab** - Animasi kendaraan, success, error
- ✅ **Shopee** - Animasi keranjang, checkout
- ✅ **Tokopedia** - Animasi produk, promo
- ✅ **Instagram** - Animasi heart, like

**Keunggulan:**
- 🚀 Ukuran file kecil (JSON, bukan video/GIF)
- ⚡ Performance tinggi
- 🎯 Resolusi sempurna di semua ukuran layar
- 🔄 Bisa loop, pause, reverse
- 🎨 Warna bisa diubah programmatically

---

## 📥 Cara Dapat Animasi Lottie

### 1. Download dari LottieFiles.com ⭐ (PALING MUDAH)

#### Step by Step:
1. **Buka** https://lottiefiles.com
2. **Login** (gratis!)
3. **Search** animasi yang kamu mau:
   - "parking" - Animasi parkir
   - "car" - Animasi mobil
   - "success" - Animasi berhasil
   - "loading" - Animasi loading
   - "location" - Animasi map/lokasi
   - "payment" - Animasi pembayaran
   - "check" - Animasi checklist

4. **Klik** animasi yang kamu suka
5. **Download** - Pilih format **JSON** (bukan MP4/GIF!)
6. **Save** ke folder `lib/animations/` di project kamu

#### Rekomendasi Animasi untuk SmartPark:
- 🚗 **Car Parking**: https://lottiefiles.com/search?q=parking&category=animations
- ✅ **Success**: https://lottiefiles.com/search?q=success&category=animations
- 🔄 **Loading**: https://lottiefiles.com/search?q=loading&category=animations
- 📍 **Location**: https://lottiefiles.com/search?q=location&category=animations
- 💳 **Payment**: https://lottiefiles.com/search?q=payment&category=animations

---

### 2. Pakai dari URL (Langsung dari Internet)

**Kelebihan:**
- Tidak perlu download
- Tidak makan storage app
- Bisa ganti animasi tanpa update app

**Kekurangan:**
- Perlu koneksi internet
- Loading agak lama pertama kali

**Cara pakai:**
```dart
Lottie.network(
  'https://lottie.host/XXXXX/XXXXX.json',
  width: 200,
  height: 200,
)
```

#### Cara dapat URL:
1. Buka animasi di LottieFiles.com
2. Klik "Share"
3. Copy "Lottie Animation URL"
4. Pakai URL itu di `Lottie.network()`

---

### 3. Buat Sendiri (Advanced)

**Tools yang dibutuhkan:**
1. **Adobe After Effects** (berbayar)
2. **Plugin Bodymovin** (gratis)

**Langkah:**
1. Buat animasi di After Effects
2. Install plugin Bodymovin
3. Export animasi sebagai JSON
4. Taruh di `lib/animations/`

**Alternatif (No Coding):**
- **Canva Pro** - Ada template animasi
- **Haiku Animator** - Drag & drop
- **Rive** - Interactive animations

---

## 💻 Cara Pakai Lottie di Flutter

### Setup (Sudah Done!)

1. **Package sudah terinstall:**
   ```yaml
   dependencies:
     lottie: ^3.1.3
   ```

2. **Import:**
   ```dart
   import 'package:lottie/lottie.dart';
   ```

---

### 3 Cara Pakai Lottie:

#### A. Dari Asset (File Lokal)

**1. Taruh file di folder:**
```
lib/animations/car_parking.json
lib/animations/success.json
lib/animations/loading.json
```

**2. Daftar di `pubspec.yaml`:**
```yaml
flutter:
  assets:
    - lib/img/
    - lib/animations/
```

**3. Pakai di code:**
```dart
Lottie.asset(
  'lib/animations/car_parking.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
)
```

---

#### B. Dari Network (URL)

```dart
Lottie.network(
  'https://lottie.host/xxxxx/xxxxx.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
  // Fallback jika gagal load
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error, size: 200);
  },
)
```

---

#### C. Dari Memory (String JSON)

```dart
final String jsonString = '''
{
  "v": "5.5.7",
  "fr": 60,
  "ip": 0,
  ...
}
''';

Lottie.memory(
  jsonString.codeUnits,
  width: 200,
  height: 200,
)
```

---

## 🎯 Contoh Penggunaan di SmartPark

### 1. Loading Animation

```dart
// Di loading screen
Lottie.network(
  'https://lottie.host/4f00e0e6-2b8c-4c74-bb44-d2efbc3a0e43/pMPq5iA2pv.json',
  width: 150,
  height: 150,
  errorBuilder: (context, error, stackTrace) {
    return CircularProgressIndicator();
  },
)
```

### 2. Success Dialog (Booking Berhasil)

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.network(
          'https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json',
          width: 100,
          height: 100,
          repeat: false, // Play sekali aja
        ),
        Text('Booking Berhasil!'),
      ],
    ),
  ),
);
```

### 3. Empty State (Tidak Ada Data)

```dart
Center(
  child: Column(
    children: [
      Lottie.asset(
        'lib/animations/empty_state.json',
        width: 200,
        height: 200,
      ),
      Text('Belum ada riwayat'),
    ],
  ),
)
```

### 4. Animasi Loop (Background)

```dart
Stack(
  children: [
    Positioned.fill(
      child: Lottie.asset(
        'lib/animations/background.json',
        fit: BoxFit.cover,
        repeat: true, // Loop terus
      ),
    ),
    // Your content here
  ],
)
```

---

## ⚙️ Kontrol Animasi

### Controller untuk Kontrol Penuh

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          'lib/animations/car.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
          },
        ),
        
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _controller.forward(),
              child: Text('Play'),
            ),
            ElevatedButton(
              onPressed: () => _controller.stop(),
              child: Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reverse(),
              child: Text('Reverse'),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## 🎨 Customization

### 1. Ubah Kecepatan

```dart
Lottie.asset(
  'lib/animations/car.json',
  animate: true,
  repeat: true,
  // 2x lebih cepat
  options: LottieOptions(
    enableMergePaths: true,
  ),
)
```

### 2. Play Sekali (No Loop)

```dart
Lottie.network(
  'https://...',
  repeat: false,
  animate: true,
)
```

### 3. Custom Size

```dart
Lottie.asset(
  'lib/animations/success.json',
  width: 300,
  height: 300,
  fit: BoxFit.contain, // atau cover, fill
)
```

### 4. Alignment

```dart
Lottie.asset(
  'lib/animations/car.json',
  alignment: Alignment.topLeft,
)
```

---

## 📱 Aplikasi Sudah Pakai Lottie

### Di SmartPark App:

1. **ModernSlotsPage** - Booking success dialog
   ```dart
   Lottie.network(
     'https://lottie.host/...',
     repeat: false,
   )
   ```

2. **Loading Animation** - Startup style loader
   - Bisa diganti dengan Lottie!

3. **Empty States** - Coming soon
   - History kosong
   - Slot tidak ada

---

## 💡 Tips & Best Practices

### 1. Fallback Wajib!

Selalu sediakan fallback jika animasi gagal load:

```dart
Lottie.network(
  'https://...',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error); // Fallback
  },
)
```

### 2. Pilih Ukuran yang Pas

- Small icons: 50-100px
- Cards: 100-150px
- Fullscreen: 200-300px
- Background: Full width/height

### 3. Loop dengan Bijak

- **Loop:** Loading, background animations
- **No Loop:** Success, error, onboarding

### 4. Optimize Performance

```dart
// Matikan jika tidak visible
if (isVisible)
  Lottie.asset('lib/animations/car.json')
else
  SizedBox.shrink()
```

### 5. Preload untuk Speed

```dart
@override
void initState() {
  super.initState();
  // Preload animasi
  precacheLottieAsset('lib/animations/car.json');
}
```

---

## 🔍 Troubleshooting

### Animasi Tidak Muncul?

1. **Check file path:**
   ```
   ✅ lib/animations/car.json
   ❌ animations/car.json
   ```

2. **Check pubspec.yaml:**
   ```yaml
   flutter:
     assets:
       - lib/animations/
   ```

3. **Run `flutter pub get`**

### Animasi Patah-patah?

- Reduce animation complexity
- Check device performance
- Use `AnimationController` untuk kontrol

### File Terlalu Besar?

- Optimize di LottieFiles.com
- Compress JSON
- Gunakan Lottie Network

---

## 📚 Resources

### Websites:
- **LottieFiles**: https://lottiefiles.com
- **Flutter Lottie Package**: https://pub.dev/packages/lottie
- **Rive**: https://rive.app (Alternative)

### Inspirasi Animasi:
- Gojek: Loading driver, success booking
- Grab: Car animation, payment success
- Shopee: Cart, checkout, delivery
- Instagram: Like, comment, story

### Tools:
- **After Effects** - Professional
- **Haiku Animator** - Beginner friendly
- **Rive** - Interactive animations

---

## ✅ Quick Checklist

Setup Lottie:
- [ ] Package `lottie` sudah terinstall
- [ ] Folder `lib/animations/` sudah dibuat
- [ ] File JSON sudah di-download
- [ ] `pubspec.yaml` sudah update
- [ ] `flutter pub get` sudah dijalankan

Implementasi:
- [ ] Import `package:lottie/lottie.dart`
- [ ] Pakai `Lottie.asset()` atau `Lottie.network()`
- [ ] Set width & height
- [ ] Tambahkan errorBuilder
- [ ] Test di emulator

---

## 🎉 Kesimpulan

Animasi Gojek/Grab menggunakan **Lottie**!

**3 Cara dapat animasi:**
1. ⭐ **Download** dari LottieFiles.com (RECOMMENDED)
2. 🌐 **URL** - Langsung dari internet
3. 🎨 **Buat sendiri** - Adobe After Effects

**Cara pakai di Flutter:**
```dart
// Dari file
Lottie.asset('lib/animations/car.json')

// Dari URL
Lottie.network('https://...')
```

**Sudah diterapkan di:**
- ✅ ModernSlotsPage - Booking dialog
- ✅ Modern loading animation
- ✅ Ready untuk lebih banyak!

**Happy Animating! 🎨✨**

# 🎨 Tutorial: Modern Loading Animation dengan Lottie

## 📚 Daftar Isi
1. [Pengenalan](#pengenalan)
2. [Pilihan Loading Animation](#pilihan-loading-animation)
3. [Cara Menggunakan](#cara-menggunakan)
4. [Download Animasi Lottie](#download-animasi-lottie)
5. [Contoh Implementasi](#contoh-implementasi)

---

## 🌟 Pengenalan

Aplikasi ini sudah dilengkapi dengan **4 jenis loading animation modern**:

1. ✅ **Built-in Modern** - Tidak perlu file eksternal
2. 🚗 **Parking Car** - Animasi custom untuk tema parkir
3. 🌐 **Lottie Network** - Memuat dari internet (perlu koneksi)
4. 📁 **Lottie Asset** - File .json lokal (perlu download)

---

## 🎯 Pilihan Loading Animation

### 1. Built-in Modern (RECOMMENDED ⭐)
```dart
const ModernLoadingAnimation(
  type: LoadingType.builtIn,
  size: 200,
  customMessage: 'Memuat data...',
)
```
**Kelebihan:**
- ✅ Tidak perlu file eksternal
- ✅ Ringan dan cepat
- ✅ Desain modern dengan gradient effect
- ✅ Tema sesuai dengan color palette app

### 2. Parking Car Animation
```dart
const ModernLoadingAnimation(
  type: LoadingType.parkingCar,
  size: 200,
  customMessage: 'Mencari slot parkir...',
)
```
**Kelebihan:**
- ✅ Custom untuk tema parkir
- ✅ Tidak perlu koneksi internet
- ✅ Animasi mobil yang smooth

### 3. Lottie dari Internet
```dart
const ModernLoadingAnimation(
  type: LoadingType.lottieNetwork,
  size: 200,
  customMessage: 'Loading...',
)
```
**Kelebihan:**
- ✅ Tidak perlu download file
- ✅ Bisa ganti URL kapan saja
- ❌ Perlu koneksi internet
- ❌ Loading pertama agak lama

### 4. Lottie dari Asset
```dart
const ModernLoadingAnimation(
  type: LoadingType.lottieAsset,
  size: 200,
  customMessage: 'Loading...',
)
```
**Kelebihan:**
- ✅ Offline, tidak perlu internet
- ✅ Animasi custom sesuai keinginan
- ❌ Perlu download dan setup file .json

---

## 📥 Download Animasi Lottie

### Website Gratis untuk Download:
1. **LottieFiles.com** (Terbaik!)
   - URL: https://lottiefiles.com
   - Search: "parking", "loading", "car"
   - Download format: JSON

2. **IconScout Lottie**
   - URL: https://iconscout.com/lottie-animations

### Rekomendasi Animasi Parking:
- 🚗 Car Parking: https://lottiefiles.com/animations/car-parking
- 🅿️ Parking Icon: https://lottiefiles.com/animations/parking
- 🔄 Loading Car: https://lottiefiles.com/animations/loading-car

### Cara Setup Lottie Asset:
1. Download file `.json` dari LottieFiles
2. Buat folder: `lib/animations/`
3. Copy file ke: `lib/animations/loading.json`
4. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - lib/img/
       - lib/animations/
   ```
5. Run: `flutter pub get`

---

## 💻 Cara Menggunakan

### A. Di StreamBuilder / FutureBuilder

**SEBELUM:**
```dart
StreamBuilder<List<ParkingSlot>>(
  stream: service.slotsStream,
  builder: (context, snap) {
    if (!snap.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    // ... rest of code
  },
)
```

**SESUDAH (Modern!):**
```dart
import '../ui/loading_animation.dart';

StreamBuilder<List<ParkingSlot>>(
  stream: service.slotsStream,
  builder: (context, snap) {
    if (!snap.hasData) {
      return const ModernLoadingAnimation(
        type: LoadingType.builtIn,
        size: 200,
        customMessage: 'Memuat data parkir...',
      );
    }
    // ... rest of code
  },
)
```

---

### B. Loading Overlay (Full Screen)

Untuk loading yang menutupi seluruh layar:

```dart
import '../ui/loading_animation.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulasi API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      loadingType: LoadingType.builtIn,
      message: 'Memuat data...',
      child: Scaffold(
        // Your normal page content here
        body: Center(
          child: ElevatedButton(
            onPressed: _loadData,
            child: const Text('Load Data'),
          ),
        ),
      ),
    );
  }
}
```

---

### C. Shimmer Effect

Untuk skeleton loading:

```dart
import '../ui/loading_animation.dart';

ShimmerLoading(
  isLoading: isLoadingData,
  child: Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

---

## 🎬 Contoh Implementasi

### 1. Login Page dengan Loading
```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      // Login process
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      loadingType: LoadingType.parkingCar,
      message: 'Logging in...',
      child: Scaffold(
        // Your login form here
      ),
    );
  }
}
```

### 2. Slot List dengan Loading
```dart
StreamBuilder<List<ParkingSlot>>(
  stream: service.slotsStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const ModernLoadingAnimation(
        type: LoadingType.parkingCar,
        size: 150,
        customMessage: 'Mencari slot tersedia...',
      );
    }
    
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    
    final slots = snapshot.data ?? [];
    return ListView.builder(
      itemCount: slots.length,
      itemBuilder: (context, index) {
        return SlotCard(slot: slots[index]);
      },
    );
  },
)
```

### 3. Payment dengan Loading
```dart
class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    try {
      await PaymentService.processPayment(amount: 5000);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isProcessing,
      loadingType: LoadingType.lottieNetwork,
      message: 'Memproses pembayaran...',
      child: Scaffold(
        // Your payment form
      ),
    );
  }
}
```

---

## 🎨 Customization

### Mengubah Ukuran
```dart
ModernLoadingAnimation(
  type: LoadingType.builtIn,
  size: 300, // Lebih besar
  customMessage: 'Loading...',
)
```

### Mengubah Pesan
```dart
ModernLoadingAnimation(
  type: LoadingType.parkingCar,
  size: 200,
  customMessage: 'Mohon tunggu sebentar...', // Custom message
)
```

### Tanpa Pesan
```dart
ModernLoadingAnimation(
  type: LoadingType.builtIn,
  size: 150,
  // Tidak ada customMessage
)
```

---

## 🚀 Testing

Untuk melihat semua animasi sekaligus, akses halaman demo:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const LoadingDemoPage(),
  ),
);
```

Atau tambahkan di main.dart untuk testing:

```dart
import 'pages/loading_demo_page.dart';

// Dalam build method:
MaterialApp(
  initialRoute: '/demo', // Untuk testing
  routes: {
    '/': (context) => const HomePage(),
    '/demo': (context) => const LoadingDemoPage(),
  },
)
```

---

## ✅ Checklist Implementation

- [x] Install package `lottie`
- [x] Buat file `lib/ui/loading_animation.dart`
- [x] Import di halaman yang perlu loading
- [x] Ganti `CircularProgressIndicator` dengan `ModernLoadingAnimation`
- [ ] (Opsional) Download animasi Lottie dari LottieFiles
- [ ] (Opsional) Setup folder `lib/animations/`
- [ ] Test di emulator/device

---

## 🎯 Rekomendasi

**Untuk Production:**
1. Gunakan `LoadingType.builtIn` - paling reliable
2. Gunakan `LoadingType.parkingCar` - untuk page parkir
3. Hindari `LoadingType.lottieNetwork` di koneksi lambat

**Untuk Testing:**
1. Akses `LoadingDemoPage` untuk lihat semua animasi
2. Pilih yang paling sesuai dengan desain app

---

## 📞 Support

Jika ada pertanyaan atau error:
1. Cek apakah sudah `flutter pub get`
2. Restart VS Code
3. Run `flutter clean` lalu `flutter pub get`
4. Pastikan import sudah benar

---

**Happy Coding! 🎉**

# INTEGRASI BACKEND DAN FRONTEND APLIKASI SMARTPARK

## 1. ARSITEKTUR SISTEM

Aplikasi SmartPark menggunakan arsitektur **Client-Server** dengan pendekatan **serverless** melalui Firebase sebagai Backend-as-a-Service (BaaS).

### Komponen Utama:
- **Frontend**: Flutter (Dart) - Cross-platform mobile app
- **Backend**: Firebase (Cloud Firestore, Authentication, Storage)
- **External API**: Google Gemini AI API untuk chatbot

---

## 2. TEKNOLOGI BACKEND

### 2.1 Firebase Authentication

Mengelola autentikasi pengguna dengan email/password.

**Implementasi di Frontend:**
```dart
// Login
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Register
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Logout
await FirebaseAuth.instance.signOut();
```

**Flow:**
1. User input email & password di UI
2. Flutter mengirim request ke Firebase Auth
3. Firebase memvalidasi credentials
4. Firebase mengembalikan User ID Token
5. Token disimpan di local storage untuk session management

---

### 2.2 Cloud Firestore (NoSQL Database)

**Collections Structure:**
```
smartpark/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── name: string
│       ├── avatar_path: string
│       ├── balance: number
│       └── created_at: timestamp
│
├── slots/
│   └── {slotId}/
│       ├── slot_number: string
│       ├── is_available: boolean
│       ├── zone: string
│       ├── floor: number
│       └── updated_at: timestamp
│
├── payment_history/
│   └── {paymentId}/
│       ├── user_id: string
│       ├── amount: number
│       ├── type: string (topup/payment)
│       ├── status: string
│       └── timestamp: timestamp
│
└── predictions/
    └── {predictionId}/
        ├── hour: number
        ├── occupancy: number
        ├── status: string
        └── timestamp: timestamp
```

**Indexed Query** (dari `firestore.indexes.json`):
```json
{
  "collectionGroup": "payment_history",
  "fields": [
    { "fieldPath": "user_id", "order": "ASCENDING" },
    { "fieldPath": "timestamp", "order": "DESCENDING" }
  ]
}
```
Index ini mempercepat query riwayat pembayaran per user berdasarkan waktu terbaru.

---

**Implementasi di Frontend:**

#### A. Read Data (Real-time Listener)
```dart
// Stream real-time data
FirebaseFirestore.instance
  .collection('slots')
  .snapshots()
  .listen((snapshot) {
    List<Slot> slots = snapshot.docs
      .map((doc) => Slot.fromFirestore(doc))
      .toList();
    // Update UI
  });
```

#### B. Write Data
```dart
// Tambah data
await FirebaseFirestore.instance
  .collection('payment_history')
  .add({
    'user_id': userId,
    'amount': 50000,
    'type': 'topup',
    'status': 'completed',
    'timestamp': FieldValue.serverTimestamp(),
  });
```

#### C. Update Data
```dart
// Update slot status
await FirebaseFirestore.instance
  .collection('slots')
  .doc(slotId)
  .update({
    'is_available': false,
    'updated_at': FieldValue.serverTimestamp(),
  });
```

#### D. Complex Query
```dart
// Query dengan filter dan sorting
QuerySnapshot snapshot = await FirebaseFirestore.instance
  .collection('payment_history')
  .where('user_id', isEqualTo: userId)
  .orderBy('timestamp', descending: true)
  .limit(20)
  .get();
```

---

### 2.3 Firebase Storage

Menyimpan file seperti foto profil pengguna.

**Upload Flow:**
```dart
// 1. Pick image dari gallery
final XFile? image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 512,
  maxHeight: 512,
  imageQuality: 85,
);

// 2. Upload ke Firebase Storage
File file = File(image!.path);
String fileName = 'avatars/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

TaskSnapshot uploadTask = await FirebaseStorage.instance
  .ref(fileName)
  .putFile(file);

// 3. Get download URL
String downloadUrl = await uploadTask.ref.getDownloadURL();

// 4. Save URL to Firestore
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'avatar_path': downloadUrl});
```

---

### 2.4 Google Gemini AI API

**Integrasi Chatbot:**
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: 'YOUR_API_KEY',
  systemInstruction: Content.system(
    'Kamu adalah asisten SmartPark yang membantu pengguna...'
  ),
);

// Send message
final response = await model.generateContent([
  Content.text(userMessage),
]);

String botReply = response.text ?? 'Maaf, saya tidak mengerti.';
```

**API Request Flow:**
1. User ketik pesan di chat UI
2. Flutter kirim HTTP POST ke Gemini API
3. API memproses dengan AI model
4. Response dikembalikan dalam format JSON
5. Flutter parse response dan tampilkan di chat bubble

---

## 3. STATE MANAGEMENT

**Provider Pattern untuk Reactive UI:**

```dart
// Theme Provider
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveToPreferences(_isDarkMode);
    notifyListeners(); // Update UI
  }
}

// Di main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: MyApp(),
);

// Di Widget
final themeProvider = Provider.of<ThemeProvider>(context);
bool isDark = themeProvider.isDarkMode;
```

---

## 4. DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────┐
│              FLUTTER FRONTEND                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   UI     │  │ Provider │  │ Services │      │
│  │ (Widgets)│◄─┤  (State) │◄─┤ (Logic)  │      │
│  └──────────┘  └──────────┘  └────┬─────┘      │
└─────────────────────────────────────┼───────────┘
                                      │
                         HTTP/WebSocket Requests
                                      │
┌─────────────────────────────────────▼───────────┐
│              FIREBASE BACKEND                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   Auth   │  │Firestore │  │ Storage  │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└──────────────────────────────────────────────────┘
                                      │
                         External API Call
                                      │
┌─────────────────────────────────────▼───────────┐
│           GOOGLE GEMINI AI API                   │
└──────────────────────────────────────────────────┘
```

---

## 5. CONTOH KASUS LENGKAP: BOOKING SLOT PARKIR

**Flow End-to-End:**

1. **User Action** - Tap slot di UI
2. **Frontend Validation** - Check apakah slot available
3. **Check Balance** - Query Firestore untuk saldo user
   ```dart
   DocumentSnapshot userDoc = await FirebaseFirestore.instance
     .collection('users')
     .doc(userId)
     .get();
   double balance = userDoc['balance'];
   ```
4. **Deduct Balance** - Update saldo di Firestore
   ```dart
   await FirebaseFirestore.instance
     .collection('users')
     .doc(userId)
     .update({'balance': FieldValue.increment(-tarif)});
   ```
5. **Update Slot Status** - Ubah slot jadi terisi
   ```dart
   await FirebaseFirestore.instance
     .collection('slots')
     .doc(slotId)
     .update({'is_available': false});
   ```
6. **Record Payment** - Simpan transaksi
   ```dart
   await FirebaseFirestore.instance
     .collection('payment_history')
     .add({
       'user_id': userId,
       'amount': -tarif,
       'type': 'payment',
       'description': 'Booking Slot $slotNumber',
       'timestamp': FieldValue.serverTimestamp(),
     });
   ```
7. **UI Update** - Real-time listener otomatis update UI
8. **Show Confirmation** - SnackBar sukses

**Transaction Safety:**
Firestore mendukung **atomic operations** untuk mencegah race condition:
```dart
await FirebaseFirestore.instance.runTransaction((transaction) async {
  // Read
  DocumentSnapshot slotDoc = await transaction.get(slotRef);
  
  // Validate
  if (!slotDoc['is_available']) {
    throw Exception('Slot sudah terisi');
  }
  
  // Write (atomic)
  transaction.update(slotRef, {'is_available': false});
  transaction.update(userRef, {'balance': FieldValue.increment(-tarif)});
  transaction.set(paymentRef, paymentData);
});
```

---

## 6. KEAMANAN

**Firebase Security Rules:**
```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }
    
    // Payment history: read own, write with validation
    match /payment_history/{paymentId} {
      allow read: if request.auth != null 
                  && resource.data.user_id == request.auth.uid;
      allow create: if request.auth != null 
                    && request.resource.data.user_id == request.auth.uid;
    }
    
    // Slots: read all, write only by admin
    match /slots/{slotId} {
      allow read: if request.auth != null;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

**API Key Security:**
- Gemini API key disimpan di environment variable (tidak di-commit ke Git)
- Request hanya dari authenticated users
- Rate limiting di backend

---

## 7. PERFORMA & OPTIMASI

### 1. Caching dengan SharedPreferences:
```dart
// Save theme preference locally
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('isDarkMode', isDarkMode);
```

### 2. Pagination untuk Large Dataset:
```dart
// Load data per batch
QuerySnapshot firstBatch = await FirebaseFirestore.instance
  .collection('payment_history')
  .orderBy('timestamp', descending: true)
  .limit(20)
  .get();

// Load next batch
DocumentSnapshot lastDoc = firstBatch.docs.last;
QuerySnapshot nextBatch = await FirebaseFirestore.instance
  .collection('payment_history')
  .orderBy('timestamp', descending: true)
  .startAfterDocument(lastDoc)
  .limit(20)
  .get();
```

### 3. Image Optimization:
```dart
// Compress image before upload
final XFile? image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 512,  // Resize
  maxHeight: 512,
  imageQuality: 85,  // Compress
);
```

---

## 8. ERROR HANDLING

```dart
try {
  await FirebaseFirestore.instance
    .collection('slots')
    .doc(slotId)
    .update({'is_available': false});
    
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Booking berhasil!')),
  );
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Handle permission error
  } else if (e.code == 'unavailable') {
    // Handle network error
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.message}')),
  );
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

---

## 9. TESTING & MONITORING

**Unit Testing:**
```dart
// Test service layer
test('Payment service should deduct balance', () async {
  final service = PaymentService();
  await service.topUp('user123', 50000);
  
  double balance = await service.getBalance('user123');
  expect(balance, 50000);
});
```

**Firebase Analytics:**
```dart
// Track user events
await FirebaseAnalytics.instance.logEvent(
  name: 'slot_booking',
  parameters: {
    'slot_id': slotId,
    'amount': tarif,
  },
);
```

---

## 10. STRUKTUR KODE APLIKASI

### Services Layer (lib/services/)

**user_service.dart** - Mengelola data user
```dart
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  // Update balance
  Future<void> updateBalance(double amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore.collection('users').doc(userId).update({
      'balance': FieldValue.increment(amount),
    });
  }
}
```

**payment_service.dart** - Mengelola transaksi
```dart
class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get payment history
  Stream<List<Payment>> getPaymentHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('payment_history')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromFirestore(doc))
            .toList());
  }

  // Add payment record
  Future<void> addPayment({
    required double amount,
    required String type,
    String? description,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    await _firestore.collection('payment_history').add({
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'status': 'completed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

**mock_parking_service.dart** - Mock data untuk slot parkir
```dart
class MockParkingService {
  // Generate mock slots
  static List<Slot> generateMockSlots() {
    return List.generate(20, (index) {
      return Slot(
        id: 'slot_${index + 1}',
        slotNumber: 'A${(index + 1).toString().padLeft(2, '0')}',
        isAvailable: (index % 3 != 0), // 2/3 slots available
        zone: index < 10 ? 'Zone A' : 'Zone B',
        floor: (index ~/ 5) + 1,
      );
    });
  }

  // Get predictions
  static List<Prediction> generatePredictions() {
    return List.generate(24, (hour) {
      return Prediction(
        hour: hour,
        occupancy: _calculateOccupancy(hour),
        status: _getStatus(hour),
      );
    });
  }

  static double _calculateOccupancy(int hour) {
    // Peak hours: 8-10, 17-19
    if ((hour >= 8 && hour <= 10) || (hour >= 17 && hour <= 19)) {
      return 0.8 + (0.15 * (hour % 2));
    }
    return 0.3 + (0.1 * (hour % 5));
  }

  static String _getStatus(int hour) {
    double occupancy = _calculateOccupancy(hour);
    if (occupancy < 0.5) return 'Rendah';
    if (occupancy < 0.8) return 'Sedang';
    return 'Tinggi';
  }
}
```

---

### Models Layer (lib/models/)

**slot.dart**
```dart
class Slot {
  final String id;
  final String slotNumber;
  final bool isAvailable;
  final String zone;
  final int floor;
  final DateTime? updatedAt;

  Slot({
    required this.id,
    required this.slotNumber,
    required this.isAvailable,
    required this.zone,
    required this.floor,
    this.updatedAt,
  });

  // Convert Firestore document to Slot
  factory Slot.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Slot(
      id: doc.id,
      slotNumber: data['slot_number'] ?? '',
      isAvailable: data['is_available'] ?? false,
      zone: data['zone'] ?? '',
      floor: data['floor'] ?? 1,
      updatedAt: data['updated_at']?.toDate(),
    );
  }

  // Convert Slot to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'slot_number': slotNumber,
      'is_available': isAvailable,
      'zone': zone,
      'floor': floor,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
```

**payment.dart**
```dart
class Payment {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'topup' or 'payment'
  final String status;
  final String? description;
  final DateTime timestamp;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.timestamp,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      userId: data['user_id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? '',
      status: data['status'] ?? '',
      description: data['description'],
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
    );
  }
}
```

**prediction.dart**
```dart
class Prediction {
  final int hour;
  final double occupancy;
  final String status;

  Prediction({
    required this.hour,
    required this.occupancy,
    required this.status,
  });

  factory Prediction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Prediction(
      hour: data['hour'] ?? 0,
      occupancy: (data['occupancy'] ?? 0).toDouble(),
      status: data['status'] ?? '',
    );
  }
}
```

---

## 11. CONTOH IMPLEMENTASI DI UI

### Home Page dengan Bottom Navigation
```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    const SlotsPage(),
    const StatsPage(),
    const AssistantPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Slot'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
```

### Slots Page dengan Real-time Data
```dart
class SlotsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('slots')
          .orderBy('slot_number')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final slots = snapshot.data?.docs
            .map((doc) => Slot.fromFirestore(doc))
            .toList() ?? [];

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return SlotCard(
              slot: slot,
              onTap: () => _handleSlotTap(context, slot),
            );
          },
        );
      },
    );
  }

  void _handleSlotTap(BuildContext context, Slot slot) async {
    if (!slot.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot ${slot.slotNumber} sudah terisi')),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Slot ${slot.slotNumber}'),
        content: Text('Tarif: Rp 5.000/jam\nApakah Anda yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Book'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _bookSlot(context, slot);
    }
  }

  Future<void> _bookSlot(BuildContext context, Slot slot) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Update slot status
        final slotRef = FirebaseFirestore.instance
            .collection('slots')
            .doc(slot.id);
        transaction.update(slotRef, {'is_available': false});

        // Deduct balance
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);
        transaction.update(userRef, {
          'balance': FieldValue.increment(-5000),
        });

        // Add payment record
        final paymentRef = FirebaseFirestore.instance
            .collection('payment_history')
            .doc();
        transaction.set(paymentRef, {
          'user_id': userId,
          'amount': -5000,
          'type': 'payment',
          'description': 'Booking Slot ${slot.slotNumber}',
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Profile Page dengan Logout
```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final balance = userData?['balance'] ?? 0.0;
        final name = userData?['name'] ?? 'User';
        final email = userData?['email'] ?? '';

        return ListView(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF1A3D64),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(email, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // Balance Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A3D64), Color(0xFF1D546C)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Anda',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Rp ${balance.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showTopUpDialog(context),
                    child: Text('Top Up'),
                  ),
                ],
              ),
            ),

            // Menu Items
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat Transaksi'),
              onTap: () {
                Navigator.pushNamed(context, '/payment-history');
              },
            ),

            // Logout Button
            Container(
              margin: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEF5350),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Keluar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context) async {
    final amounts = [10000, 25000, 50000, 100000];
    
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Nominal Top Up'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: amounts.map((amount) {
            return ListTile(
              title: Text('Rp ${amount.toString()}'),
              onTap: () => Navigator.pop(context, amount),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      await _topUp(context, selected.toDouble());
    }
  }

  Future<void> _topUp(BuildContext context, double amount) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Update balance
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'balance': FieldValue.increment(amount)});

      // Add payment record
      await FirebaseFirestore.instance
          .collection('payment_history')
          .add({
        'user_id': userId,
        'amount': amount,
        'type': 'topup',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top up berhasil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top up gagal: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar'),
        content: Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
```

---

## 12. KESIMPULAN

### Keuntungan Integrasi Firebase:
1. ✅ **Real-time sync** - Perubahan data langsung ter-update di semua client
2. ✅ **Serverless** - Tidak perlu maintain server sendiri
3. ✅ **Scalable** - Auto-scaling sesuai traffic
4. ✅ **Secure** - Built-in security rules
5. ✅ **Cost-effective** - Pay as you go, free tier untuk development
6. ✅ **Fast development** - SDK lengkap, dokumentasi baik
7. ✅ **Authentication built-in** - Email/password, Google, Facebook, etc.
8. ✅ **Offline support** - Data cached locally

### Tantangan:
1. ❌ **Vendor lock-in** - Terikat ke Firebase, sulit migrasi
2. ❌ **Biaya** - Bisa mahal untuk traffic tinggi
3. ❌ **Kompleksitas query** - Lebih terbatas dibanding SQL
4. ❌ **Debugging** - Kurang control dibanding self-hosted
5. ❌ **Data structure** - NoSQL memerlukan denormalisasi

### Cocok untuk:
- ✅ MVP dan prototyping cepat
- ✅ Aplikasi dengan real-time requirements
- ✅ Tim kecil tanpa DevOps expertise
- ✅ Aplikasi mobile-first
- ✅ Startup dengan budget terbatas

### Tidak cocok untuk:
- ❌ Aplikasi dengan query kompleks
- ❌ Data highly relational
- ❌ Compliance ketat (data harus on-premise)
- ❌ Aplikasi dengan traffic sangat tinggi (cost)

---

## 13. REFERENSI

**Dokumentasi Official:**
- Flutter: https://flutter.dev/docs
- Firebase: https://firebase.google.com/docs
- Firestore: https://firebase.google.com/docs/firestore
- Firebase Auth: https://firebase.google.com/docs/auth
- Google Gemini API: https://ai.google.dev/

**Packages yang Digunakan:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  google_fonts: ^6.1.0
  provider: ^6.1.1
  google_generative_ai: ^0.2.0
  image_picker: ^1.0.7
  shared_preferences: ^2.2.2
```

**Best Practices:**
1. Gunakan StreamBuilder untuk real-time data
2. Implement pagination untuk large datasets
3. Use transactions untuk operasi atomic
4. Cache data dengan SharedPreferences
5. Optimize images sebelum upload
6. Implement proper error handling
7. Use security rules untuk protect data
8. Monitor usage dengan Firebase Analytics

---

**Disusun untuk Jurnal Aplikasi SmartPark**
**Tanggal: November 2025**

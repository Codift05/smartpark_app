#  Dokumentasi UML SmartPark App

**Aplikasi:** SmartPark - Smart Parking Management System  
**Platform:** Flutter (Android, iOS, Web)  
**Tanggal:** November 2025  
**Versi:** 1.0.0

---

##  Daftar Isi

1. [Use Case Diagram](#1-use-case-diagram)
2. [Activity Diagram](#2-activity-diagram)
3. [Sequence Diagram](#3-sequence-diagram)
4. [Class Diagram](#4-class-diagram)
5. [Deployment Diagram](#5-deployment-diagram)
6. [Alur Sistem Lengkap](#6-alur-sistem-lengkap)

---

## 1. Use Case Diagram

### 1.1 Aktor dalam Sistem

| Aktor | Deskripsi |
|-------|-----------|
| **User (Pengguna)** | Pengguna aplikasi yang mencari parkir dan melakukan pembayaran |
| **Firebase Auth** | Sistem autentikasi eksternal |
| **Firestore Database** | Database cloud untuk menyimpan data |
| **Payment Gateway** | Sistem pembayaran QRIS/virtual payment |
| **AI Assistant** | Asisten virtual untuk membantu pengguna |

### 1.2 Use Case Utama

```
┌─────────────────────────────────────────────────────────────┐
│                      SmartPark System                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌──────────┐                                               │
│   │          │                                               │
│   │  User    │───────── UC-01: Login/Register               │
│   │          │                                               │
│   │          │───────── UC-02: Lihat Profil                 │
│   │          │                                               │
│   │          │───────── UC-03: Edit Profil & Upload Foto    │
│   │          │                                               │
│   │          │───────── UC-04: Lihat Dashboard/Home         │
│   │          │                                               │
│   │          │───────── UC-05: Cari Slot Parkir             │
│   │          │                                               │
│   │          │───────── UC-06: Lihat Map Lokasi             │
│   │          │                                               │
│   │          │───────── UC-07: Booking Slot Parkir          │
│   │          │                                               │
│   │          │───────── UC-08: Pembayaran (Top Up/Tarik)    │
│   │          │                                               │
│   │          │───────── UC-09: Lihat Riwayat Pembayaran     │
│   │          │                                               │
│   │          │───────── UC-10: Lihat Statistik Parkir       │
│   │          │                                               │
│   │          │───────── UC-11: Chat dengan AI Assistant     │
│   │          │                                               │
│   │          │───────── UC-12: Toggle Dark Mode             │
│   │          │                                               │
│   │          │───────── UC-13: Atur Preferensi/Notifikasi   │
│   │          │                                               │
│   └──────────┘                                               │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Detail Use Case

#### **UC-01: Login/Register**
- **Aktor:** User, Firebase Auth
- **Precondition:** User memiliki email valid
- **Flow:**
  1. User membuka aplikasi
  2. User memilih Login atau Sign Up
  3. User memasukkan email dan password
  4. Firebase Auth memvalidasi kredensial
  5. Sistem membuat/mengambil data user di Firestore
  6. User masuk ke Dashboard

#### **UC-03: Edit Profil & Upload Foto**
- **Aktor:** User, Firestore
- **Precondition:** User sudah login
- **Flow:**
  1. User masuk ke halaman Profil
  2. User tap pada foto profil
  3. Sistem membuka Image Picker
  4. User memilih foto dari galeri
  5. Sistem resize foto (512x512px, quality 85%)
  6. Sistem upload path ke Firestore (avatar_path)
  7. Foto profil ditampilkan di UI

#### **UC-05: Cari Slot Parkir**
- **Aktor:** User, Firestore
- **Precondition:** User sudah login
- **Flow:**
  1. User masuk ke halaman Slots
  2. Sistem fetch data slots dari Firestore
  3. User melihat daftar slot (Available/Occupied)
  4. User dapat filter berdasarkan status
  5. User dapat search berdasarkan nama lokasi

#### **UC-07: Booking Slot Parkir**
- **Aktor:** User, Firestore, Payment Gateway
- **Precondition:** User memiliki saldo cukup
- **Flow:**
  1. User pilih slot yang Available
  2. Sistem tampilkan detail slot dan harga
  3. User konfirmasi booking
  4. Sistem cek saldo user
  5. Sistem update status slot menjadi Occupied
  6. Sistem buat payment record
  7. Sistem kurangi saldo user
  8. Sistem tampilkan konfirmasi booking

#### **UC-11: Chat dengan AI Assistant**
- **Aktor:** User, AI Assistant
- **Precondition:** User sudah login
- **Flow:**
  1. User masuk ke halaman Assistant
  2. User mengetik pertanyaan
  3. Sistem kirim query ke AI service
  4. AI memproses dan generate response
  5. Sistem tampilkan jawaban AI
  6. User dapat melanjutkan percakapan

---

## 2. Activity Diagram

### 2.1 Activity Diagram: Proses Login & Register

```
┌─────────┐
│  Start  │
└────┬────┘
     │
     ▼
┌─────────────────┐
│ Buka Aplikasi   │
└────┬────────────┘
     │
     ▼
    ╱ ╲
   ╱   ╲ Sudah punya
  ╱     ╲ akun?
 ╱       ╲
╱─────────╲
│ No   Yes│
│          │
▼          ▼
┌─────────────────┐      ┌─────────────────┐
│ Pilih Sign Up   │      │ Pilih Login     │
└────┬────────────┘      └────┬────────────┘
     │                         │
     ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│ Input Email     │      │ Input Email     │
│ & Password      │      │ & Password      │
└────┬────────────┘      └────┬────────────┘
     │                         │
     ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│ Firebase Auth   │      │ Firebase Auth   │
│ Create User     │      │ Sign In         │
└────┬────────────┘      └────┬────────────┘
     │                         │
     └────────┬────────────────┘
              │
              ▼
         ╱────────╲
        ╱  Berhasil?╲ No
       ╱            ╲──────┐
      ╱──────────────╲     │
      │ Yes           │     │
      ▼               │     ▼
┌─────────────────┐   │  ┌─────────────────┐
│ Buat/Get User   │   │  │ Tampilkan Error │
│ Data Firestore  │   │  └────┬────────────┘
└────┬────────────┘   │       │
     │                │       └──────┐
     ▼                │              │
┌─────────────────┐   │              │
│ Redirect ke     │   │              │
│ Home/Dashboard  │   │              │
└────┬────────────┘   │              │
     │                │              │
     └────────────────┴──────────────┘
                      │
                      ▼
                 ┌─────────┐
                 │   End   │
                 └─────────┘
```

### 2.2 Activity Diagram: Proses Booking Slot Parkir

```
┌─────────┐
│  Start  │
└────┬────┘
     │
     ▼
┌─────────────────┐
│ Masuk Halaman   │
│ Slots           │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ Fetch Data Slot │
│ dari Firestore  │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ Tampilkan List  │
│ Slot Parkir     │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ User Pilih Slot │
│ (Available)     │
└────┬────────────┘
     │
     ▼
    ╱ ╲
   ╱   ╲ Slot
  ╱     ╲ Available?
 ╱       ╲
╱─────────╲
│ No   Yes│
│          │
▼          ▼
┌─────────────────┐      ┌─────────────────┐
│ Tampilkan       │      │ Tampilkan Detail│
│ "Slot Full"     │      │ Slot & Harga    │
└────┬────────────┘      └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ User Konfirmasi │
     │                    │ Booking         │
     │                    └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ Cek Saldo User  │
     │                    └────┬────────────┘
     │                         │
     │                         ▼
     │                        ╱ ╲
     │                       ╱   ╲ Saldo
     │                      ╱     ╲ Cukup?
     │                     ╱       ╲
     │                    ╱─────────╲
     │                    │ No   Yes│
     │                    │          │
     │                    ▼          ▼
     │              ┌─────────────────┐      ┌─────────────────┐
     │              │ Tampilkan       │      │ Update Slot     │
     │              │ "Saldo Kurang"  │      │ Status=Occupied │
     │              └────┬────────────┘      └────┬────────────┘
     │                   │                         │
     │                   │                         ▼
     │                   │                    ┌─────────────────┐
     │                   │                    │ Buat Payment    │
     │                   │                    │ Record          │
     │                   │                    └────┬────────────┘
     │                   │                         │
     │                   │                         ▼
     │                   │                    ┌─────────────────┐
     │                   │                    │ Kurangi Saldo   │
     │                   │                    │ User            │
     │                   │                    └────┬────────────┘
     │                   │                         │
     │                   │                         ▼
     │                   │                    ┌─────────────────┐
     │                   │                    │ Generate QR     │
     │                   │                    │ Payment Code    │
     │                   │                    └────┬────────────┘
     │                   │                         │
     │                   │                         ▼
     │                   │                    ┌─────────────────┐
     │                   │                    │ Tampilkan       │
     │                   │                    │ Konfirmasi      │
     │                   │                    └────┬────────────┘
     │                   │                         │
     └───────────────────┴─────────────────────────┘
                         │
                         ▼
                    ┌─────────┐
                    │   End   │
                    └─────────┘
```

### 2.3 Activity Diagram: Proses Upload Foto Profil

```
┌─────────┐
│  Start  │
└────┬────┘
     │
     ▼
┌─────────────────┐
│ User Buka       │
│ Halaman Profil  │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ User Tap Foto   │
│ Profil          │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│ Buka Image      │
│ Picker (Gallery)│
└────┬────────────┘
     │
     ▼
    ╱ ╲
   ╱   ╲ User Pilih
  ╱     ╲ Foto?
 ╱       ╲
╱─────────╲
│ No   Yes│
│          │
▼          ▼
┌─────────────────┐      ┌─────────────────┐
│ Cancel          │      │ Load Selected   │
│                 │      │ Image           │
└────┬────────────┘      └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ Resize Image    │
     │                    │ 512x512px       │
     │                    │ Quality: 85%    │
     │                    └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ Update State    │
     │                    │ _localImagePath │
     │                    └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ Save Path ke    │
     │                    │ Firestore       │
     │                    │ (avatar_path)   │
     │                    └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ Tampilkan       │
     │                    │ SnackBar Sukses │
     │                    └────┬────────────┘
     │                         │
     │                         ▼
     │                    ┌─────────────────┐
     │                    │ Refresh UI      │
     │                    │ Tampilkan Foto  │
     │                    └────┬────────────┘
     │                         │
     └─────────────────────────┘
                         │
                         ▼
                    ┌─────────┐
                    │   End   │
                    └─────────┘
```

---

## 3. Sequence Diagram

### 3.1 Sequence Diagram: Login Process

```
User          LoginPage       FirebaseAuth    Firestore       HomePage
 │                │                 │              │              │
 │   Open App     │                 │              │              │
 │───────────────>│                 │              │              │
 │                │                 │              │              │
 │  Input Email   │                 │              │              │
 │  & Password    │                 │              │              │
 │───────────────>│                 │              │              │
 │                │                 │              │              │
 │  Tap Login     │                 │              │              │
 │───────────────>│                 │              │              │
 │                │                 │              │              │
 │                │  signInWithEmailAndPassword()  │              │
 │                │────────────────>│              │              │
 │                │                 │              │              │
 │                │  <Authenticating>              │              │
 │                │                 │              │              │
 │                │     UserCredential             │              │
 │                │<────────────────│              │              │
 │                │                 │              │              │
 │                │  Get User UID   │              │              │
 │                │─────────────────┼─────────────>│              │
 │                │                 │              │              │
 │                │                 │  Check/Create User Doc      │
 │                │                 │              │              │
 │                │                 │  User Data   │              │
 │                │<────────────────┼──────────────│              │
 │                │                 │              │              │
 │                │  Navigator.pushReplacement()   │              │
 │                │────────────────────────────────┼─────────────>│
 │                │                 │              │              │
 │  HomePage      │                 │              │              │
 │<───────────────┼─────────────────┼──────────────┼──────────────│
 │                │                 │              │              │
```

### 3.2 Sequence Diagram: Booking Slot Parkir

```
User      SlotsPage    SlotService   Firestore   PaymentService   HomePage
 │            │            │             │              │              │
 │  Browse    │            │             │              │              │
 │───────────>│            │             │              │              │
 │            │            │             │              │              │
 │            │  fetchSlots()           │              │              │
 │            │───────────>│             │              │              │
 │            │            │             │              │              │
 │            │            │  Query Slots Collection    │              │
 │            │            │────────────>│              │              │
 │            │            │             │              │              │
 │            │            │  List<Slot> │              │              │
 │            │            │<────────────│              │              │
 │            │            │             │              │              │
 │            │  Display Slots           │              │              │
 │            │<───────────│             │              │              │
 │            │            │             │              │              │
 │  Tap Slot  │            │             │              │              │
 │───────────>│            │             │              │              │
 │            │            │             │              │              │
 │  Confirm   │            │             │              │              │
 │  Booking   │            │             │              │              │
 │───────────>│            │             │              │              │
 │            │            │             │              │              │
 │            │  bookSlot(slotId, userId)              │              │
 │            │───────────>│             │              │              │
 │            │            │             │              │              │
 │            │            │  Get User Balance          │              │
 │            │            │────────────┼──────────────>│              │
 │            │            │             │              │              │
 │            │            │  Balance OK?               │              │
 │            │            │             │              │              │
 │            │            │  Update Slot Status        │              │
 │            │            │────────────>│              │              │
 │            │            │             │              │              │
 │            │            │  Create Payment Record     │              │
 │            │            │────────────┼──────────────>│              │
 │            │            │             │              │              │
 │            │            │  Generate QR Payload       │              │
 │            │            │             │              │              │
 │            │            │  Adjust Balance (-amount)  │              │
 │            │            │────────────┼──────────────>│              │
 │            │            │             │              │              │
 │            │            │  Success    │              │              │
 │            │<───────────│             │              │              │
 │            │            │             │              │              │
 │  Show      │            │             │              │              │
 │  SnackBar  │            │             │              │              │
 │<───────────│            │             │              │              │
 │            │            │             │              │              │
 │  Navigate  │            │             │              │              │
 │  to Home   │            │             │              │              │
 │────────────┼────────────┼─────────────┼──────────────┼─────────────>│
 │            │            │             │              │              │
```

### 3.3 Sequence Diagram: Upload Foto Profil

```
User      ProfilePage   ImagePicker   FileSystem   Firestore   UI
 │            │              │             │            │        │
 │  Tap Photo │              │             │            │        │
 │───────────>│              │             │            │        │
 │            │              │             │            │        │
 │            │  pickImage() │             │            │        │
 │            │─────────────>│             │            │        │
 │            │              │             │            │        │
 │            │  Open Gallery│             │            │        │
 │            │              │             │            │        │
 │  Select    │              │             │            │        │
 │  Image     │              │             │            │        │
 │────────────┼─────────────>│             │            │        │
 │            │              │             │            │        │
 │            │  XFile       │             │            │        │
 │            │<─────────────│             │            │        │
 │            │              │             │            │        │
 │            │  Resize (512x512, quality=85%)         │        │
 │            │              │             │            │        │
 │            │  setState(_localImagePath)             │        │
 │            │──────────────────────────────────────────────────>│
 │            │              │             │            │        │
 │            │  Save to Firestore                     │        │
 │            │  users/{uid}.avatar_path               │        │
 │            │────────────────────────────────────────>│        │
 │            │              │             │            │        │
 │            │              │             │  Success   │        │
 │            │<────────────────────────────────────────│        │
 │            │              │             │            │        │
 │            │  Show SnackBar "Foto berhasil diubah!" │        │
 │            │──────────────────────────────────────────────────>│
 │            │              │             │            │        │
 │  Updated   │              │             │            │        │
 │  Photo     │              │             │            │        │
 │<───────────┼──────────────┼─────────────┼────────────┼────────│
 │            │              │             │            │        │
```

### 3.4 Sequence Diagram: Dark Mode Toggle

```
User      HomePage    ThemeProvider   SharedPrefs   UI
 │            │              │              │        │
 │  Tap      │              │              │        │
 │  Dark Mode│              │              │        │
 │  Toggle   │              │              │        │
 │───────────>│              │              │        │
 │            │              │              │        │
 │            │  toggleTheme()              │        │
 │            │─────────────>│              │        │
 │            │              │              │        │
 │            │              │  _isDarkMode = !_isDarkMode │
 │            │              │              │        │
 │            │              │  Save to SharedPreferences  │
 │            │              │─────────────>│        │
 │            │              │              │        │
 │            │              │  Success     │        │
 │            │              │<─────────────│        │
 │            │              │              │        │
 │            │              │  notifyListeners()   │
 │            │              │─────────────────────>│
 │            │              │              │        │
 │            │              │  Rebuild All Widgets │
 │            │              │              │        │
 │  Updated   │              │              │        │
 │  Theme     │              │              │        │
 │<───────────┼──────────────┼──────────────┼────────│
 │            │              │              │        │
```

---

## 4. Class Diagram

### 4.1 Class Diagram: Model Classes

```
┌─────────────────────────────────┐
│         Payment                 │
├─────────────────────────────────┤
│ - id: String                    │
│ - userId: String                │
│ - slotId: String                │
│ - amount: int                   │
│ - timestamp: DateTime           │
│ - status: String                │
│ - qrPayload: String             │
├─────────────────────────────────┤
│ + PaymentHistory.fromDoc()      │
│ + toJson(): Map<String, dynamic>│
└─────────────────────────────────┘
                 │
                 │ uses
                 ▼
┌─────────────────────────────────┐
│           Slot                  │
├─────────────────────────────────┤
│ - id: String                    │
│ - name: String                  │
│ - location: String              │
│ - status: String                │
│ - price: int                    │
│ - latitude: double?             │
│ - longitude: double?            │
├─────────────────────────────────┤
│ + Slot.fromDoc()                │
│ + toJson(): Map<String, dynamic>│
└─────────────────────────────────┘
                 │
                 │ uses
                 ▼
┌─────────────────────────────────┐
│        Prediction               │
├─────────────────────────────────┤
│ - timestamp: DateTime           │
│ - slotId: String                │
│ - occupancyRate: double         │
│ - predictedStatus: String       │
├─────────────────────────────────┤
│ + Prediction.fromDoc()          │
│ + toJson(): Map<String, dynamic>│
└─────────────────────────────────┘
```

### 4.2 Class Diagram: Service Classes

```
┌─────────────────────────────────┐
│      PaymentService             │
├─────────────────────────────────┤
│ - db: FirebaseFirestore         │
├─────────────────────────────────┤
│ + createPayment(): Future       │
│ + markPaid(id): Future<void>    │
│ + historyStream(): Stream       │
│ + balanceStream(): Stream<int>  │
│ + getBalance(): Future<double>  │
│ + adjustBalance(): Future<void> │
└─────────────────────────────────┘
                 │
                 │
                 ▼
┌─────────────────────────────────┐
│        UserService              │
├─────────────────────────────────┤
│ - db: FirebaseFirestore         │
├─────────────────────────────────┤
│ + getUserData(): Future         │
│ + updateProfile(): Future<void> │
│ + uploadAvatar(): Future<void>  │
│ + getPreferences(): Future      │
│ + updatePreferences(): Future   │
└─────────────────────────────────┘
                 │
                 │
                 ▼
┌─────────────────────────────────┐
│   MockParkingService            │
├─────────────────────────────────┤
│ - db: FirebaseFirestore         │
├─────────────────────────────────┤
│ + fetchSlots(): Future<List>    │
│ + bookSlot(): Future<void>      │
│ + getSlotById(): Future<Slot>   │
│ + updateSlotStatus(): Future    │
└─────────────────────────────────┘
```

### 4.3 Class Diagram: UI/Page Classes

```
┌─────────────────────────────────┐
│         HomePage                │
│      (StatefulWidget)           │
├─────────────────────────────────┤
│ - _selectedIndex: int           │
├─────────────────────────────────┤
│ + build(): Widget               │
│ + _onItemTapped(): void         │
└─────────────────────────────────┘
                 │
                 │ navigates to
                 ▼
┌─────────────────────────────────┐
│       ProfilePage               │
│      (StatefulWidget)           │
├─────────────────────────────────┤
│ - _localImagePath: String?      │
├─────────────────────────────────┤
│ + _pickImage(): Future<void>    │
│ + build(): Widget               │
└─────────────────────────────────┘
                 │
                 │
                 ▼
┌─────────────────────────────────┐
│         SlotsPage               │
│      (StatefulWidget)           │
├─────────────────────────────────┤
│ - searchQuery: String           │
│ - filterStatus: String?         │
├─────────────────────────────────┤
│ + _searchSlots(): void          │
│ + _filterByStatus(): void       │
│ + build(): Widget               │
└─────────────────────────────────┘
                 │
                 │
                 ▼
┌─────────────────────────────────┐
│         StatsPage               │
│      (StatefulWidget)           │
├─────────────────────────────────┤
│ - period: String                │
├─────────────────────────────────┤
│ + _fetchStats(): Future         │
│ + _buildChart(): Widget         │
│ + build(): Widget               │
└─────────────────────────────────┘
                 │
                 │
                 ▼
┌─────────────────────────────────┐
│      AssistantPage              │
│      (StatefulWidget)           │
├─────────────────────────────────┤
│ - messages: List<Message>       │
│ - _controller: TextController   │
├─────────────────────────────────┤
│ + _sendMessage(): Future<void>  │
│ + _getAIResponse(): Future      │
│ + build(): Widget               │
└─────────────────────────────────┘
```

### 4.4 Class Diagram: Provider Classes

```
┌─────────────────────────────────┐
│       ThemeProvider             │
│    (ChangeNotifier)             │
├─────────────────────────────────┤
│ - _isDarkMode: bool             │
│ - _prefs: SharedPreferences?    │
├─────────────────────────────────┤
│ + isDarkMode: bool (getter)     │
│ + lightTheme: ThemeData         │
│ + darkTheme: ThemeData          │
├─────────────────────────────────┤
│ + toggleTheme(): Future<void>   │
│ + _saveThemePreference(): Future│
│ + _loadThemePreference(): Future│
└─────────────────────────────────┘
```

---

## 5. Deployment Diagram

### 5.1 Arsitektur Deployment

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Devices                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│   │   Android    │    │     iOS      │    │     Web      │ │
│   │   Device     │    │   Device     │    │   Browser    │ │
│   └──────┬───────┘    └──────┬───────┘    └──────┬───────┘ │
│          │                   │                   │          │
└──────────┼───────────────────┼───────────────────┼──────────┘
           │                   │                   │
           │       HTTPS/WSS (Secure Connection)   │
           │                   │                   │
           └───────────────────┼───────────────────┘
                               │
┌──────────────────────────────┼──────────────────────────────┐
│                              ▼                               │
│                     Firebase Platform                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌────────────────────────────────────────────────────┐    │
│   │         Firebase Authentication                     │    │
│   │  - Email/Password Auth                              │    │
│   │  - Session Management                               │    │
│   │  - User Token Generation                            │    │
│   └────────────────────────────────────────────────────┘    │
│                              │                               │
│   ┌────────────────────────────────────────────────────┐    │
│   │         Cloud Firestore (Database)                  │    │
│   │                                                      │    │
│   │  Collections:                                        │    │
│   │  ├─ users/                                           │    │
│   │  │   ├─ {userId}                                     │    │
│   │  │   │   ├─ name, email, avatar_path                │    │
│   │  │   │   ├─ balance, notif_pref                     │    │
│   │  │   │   └─ created_at, updated_at                  │    │
│   │  │                                                   │    │
│   │  ├─ slots/                                           │    │
│   │  │   ├─ {slotId}                                     │    │
│   │  │   │   ├─ name, location, status                  │    │
│   │  │   │   ├─ price, latitude, longitude              │    │
│   │  │   │   └─ updated_at                               │    │
│   │  │                                                   │    │
│   │  └─ payment_history/                                 │    │
│   │      ├─ {paymentId}                                  │    │
│   │      │   ├─ user_id, slot_id, amount                │    │
│   │      │   ├─ timestamp, payment_status               │    │
│   │      │   └─ qr_payload                               │    │
│   │                                                      │    │
│   └────────────────────────────────────────────────────┘    │
│                              │                               │
│   ┌────────────────────────────────────────────────────┐    │
│   │         Firebase Storage (Optional)                 │    │
│   │  - Profile Images                                   │    │
│   │  - QR Codes                                          │    │
│   │  - Documents                                         │    │
│   └────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                               │
┌──────────────────────────────┼──────────────────────────────┐
│                              ▼                               │
│                  External Services (Future)                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌────────────────────┐    ┌────────────────────┐          │
│   │  Payment Gateway   │    │   AI Service       │          │
│   │  - QRIS            │    │   - ChatGPT API    │          │
│   │  - E-Wallet        │    │   - Assistant      │          │
│   └────────────────────┘    └────────────────────┘          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Technology Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Framework:  Flutter 3.35.4                                  │
│  Language:   Dart 3.x                                        │
│  UI:         Material 3 Design                               │
│  Fonts:      Google Fonts (Poppins)                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   State Management                           │
├─────────────────────────────────────────────────────────────┤
│  Provider:           v6.1.1                                  │
│  SharedPreferences:  v2.2.2                                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Backend Services                          │
├─────────────────────────────────────────────────────────────┤
│  Authentication:  Firebase Auth                              │
│  Database:        Cloud Firestore                            │
│  Storage:         Firebase Storage (Optional)                │
│  Hosting:         Firebase Hosting (Web)                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Key Packages                              │
├─────────────────────────────────────────────────────────────┤
│  firebase_auth:        Latest                                │
│  cloud_firestore:      Latest                                │
│  google_fonts:         Latest                                │
│  image_picker:         ^1.0.7                                │
│  provider:             ^6.1.1                                │
│  shared_preferences:   ^2.2.2                                │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Alur Sistem Lengkap

### 6.1 Alur Complete User Journey

```
┌─────────────────────────────────────────────────────────────┐
│                    USER JOURNEY FLOW                         │
└─────────────────────────────────────────────────────────────┘

1. ONBOARDING & AUTHENTICATION
   │
   ├─> User membuka aplikasi
   ├─> Splash screen (optional)
   ├─> Cek authentication status
   │   │
   │   ├─> Sudah login?
   │   │   ├─> Yes: Redirect ke HomePage
   │   │   └─> No: Tampilkan LoginPage
   │   │
   │   ├─> User pilih: Sign Up atau Login
   │   ├─> Input email & password
   │   ├─> Firebase Auth validasi
   │   ├─> Sukses: Create/Get user document di Firestore
   │   └─> Redirect ke HomePage
   │

2. DASHBOARD & NAVIGATION (HomePage)
   │
   ├─> Bottom Navigation dengan 5 menu:
   │   │
   │   ├─> [Home] Dashboard utama
   │   │   ├─> Welcome message
   │   │   ├─> Quick stats (total parkir, saldo)
   │   │   ├─> Recent bookings
   │   │   └─> Quick actions (Book Now, Top Up)
   │   │
   │   ├─> [Slots] Daftar slot parkir
   │   │   ├─> Fetch slots dari Firestore
   │   │   ├─> Filter: Available, Occupied, All
   │   │   ├─> Search by location name
   │   │   └─> Tap slot untuk detail & booking
   │   │
   │   ├─> [Map] Peta lokasi parkir
   │   │   ├─> Google Maps integration (future)
   │   │   ├─> Show markers untuk setiap slot
   │   │   ├─> Tap marker untuk detail
   │   │   └─> Navigate to location
   │   │
   │   ├─> [Stats] Statistik & analitik
   │   │   ├─> Total parkir bulan ini
   │   │   ├─> Total pengeluaran
   │   │   ├─> Chart penggunaan
   │   │   ├─> Most visited locations
   │   │   └─> Time-based analytics
   │   │
   │   └─> [Assistant] AI Chatbot
   │       ├─> Chat interface
   │       ├─> User kirim pertanyaan
   │       ├─> AI respond dengan jawaban
   │       └─> Context-aware responses
   │

3. BOOKING FLOW
   │
   ├─> User buka SlotsPage
   ├─> Browse atau search slot
   ├─> Tap slot yang Available
   ├─> Bottom sheet muncul dengan:
   │   ├─> Nama slot
   │   ├─> Lokasi
   │   ├─> Harga per jam
   │   └─> Tombol "Book Now"
   │
   ├─> User tap "Book Now"
   ├─> Sistem cek saldo user
   │   │
   │   ├─> Saldo cukup?
   │   │   ├─> Yes: Lanjut proses booking
   │   │   └─> No: Tampilkan error "Saldo tidak cukup"
   │   │
   │   ├─> Update slot status = "Occupied"
   │   ├─> Create payment record di payment_history
   │   ├─> Generate QR code payload
   │   ├─> Kurangi saldo user (adjustBalance)
   │   ├─> Tampilkan konfirmasi booking
   │   └─> Redirect ke HomePage
   │

4. PAYMENT & BALANCE MANAGEMENT
   │
   ├─> User buka ProfilePage
   ├─> Lihat balance card (Saldo SmartPark)
   │
   ├─> Top Up Flow:
   │   ├─> User tap tombol "Top Up"
   │   ├─> Dialog input nominal
   │   ├─> Generate payment QR (future: integrate gateway)
   │   ├─> User bayar via QRIS/e-wallet
   │   ├─> Sistem update balance
   │   └─> SnackBar konfirmasi
   │
   ├─> Tarik (Withdraw) Flow:
   │   ├─> User tap tombol "Tarik"
   │   ├─> Dialog input nominal & rekening
   │   ├─> Validasi saldo mencukupi
   │   ├─> Process withdrawal request
   │   ├─> Update balance
   │   └─> SnackBar konfirmasi
   │
   └─> Payment History:
       ├─> User buka PaymentHistoryPage
       ├─> Stream dari payment_history collection
       ├─> Filter by date, status
       ├─> Tap untuk detail transaksi
       └─> Export to PDF (future)
   │

5. PROFILE MANAGEMENT
   │
   ├─> User buka ProfilePage
   │
   ├─> Upload Foto Profil:
   │   ├─> User tap foto profil
   │   ├─> ImagePicker buka gallery
   │   ├─> User pilih foto
   │   ├─> Resize 512x512px, quality 85%
   │   ├─> Save path ke Firestore (avatar_path)
   │   ├─> Update UI dengan foto baru
   │   └─> SnackBar "Foto berhasil diubah!"
   │
   ├─> Edit Profil:
   │   ├─> User tap "Edit Profil"
   │   ├─> Dialog/Page edit nama
   │   ├─> Save ke Firestore users/{uid}
   │   └─> Update UI
   │
   ├─> Pengaturan Email:
   │   ├─> User tap "Email"
   │   ├─> Firebase Auth update email
   │   └─> Verification email sent
   │
   ├─> Keamanan:
   │   ├─> User tap "Keamanan"
   │   ├─> Form ubah password
   │   ├─> Firebase Auth updatePassword
   │   └─> Konfirmasi sukses
   │
   └─> Preferensi:
       ├─> Toggle Notifikasi
       │   ├─> Update Firestore notif_pref
       │   └─> Enable/disable push notifications
       │
       └─> Toggle Dark Mode
           ├─> ThemeProvider.toggleTheme()
           ├─> Save ke SharedPreferences
           ├─> notifyListeners()
           └─> UI rebuild dengan theme baru
   │

6. STATISTICS & ANALYTICS
   │
   ├─> User buka StatsPage
   ├─> Fetch payment history dari Firestore
   ├─> Calculate metrics:
   │   ├─> Total parkir bulan ini
   │   ├─> Total pengeluaran
   │   ├─> Average cost per parking
   │   ├─> Most frequent location
   │   └─> Peak usage hours
   │
   ├─> Display charts:
   │   ├─> Bar chart: Pengeluaran per minggu
   │   ├─> Pie chart: Distribusi lokasi
   │   └─> Line chart: Trend penggunaan
   │
   └─> Filter by period:
       ├─> Minggu ini
       ├─> Bulan ini
       ├─> 3 bulan terakhir
       └─> Custom range
   │

7. AI ASSISTANT
   │
   ├─> User buka AssistantPage
   ├─> Chat interface tampil
   │
   ├─> User Interaction:
   │   ├─> User ketik pertanyaan
   │   ├─> Tap send button
   │   ├─> Message ditambahkan ke list (role: user)
   │   ├─> Loading indicator muncul
   │   ├─> Call AI service API
   │   ├─> AI generate response
   │   ├─> Response ditambahkan (role: assistant)
   │   └─> Auto scroll ke bottom
   │
   └─> Context awareness:
       ├─> Akses data user (balance, recent bookings)
       ├─> Provide personalized recommendations
       └─> Answer parking-related questions
   │

8. LOGOUT FLOW
   │
   ├─> User tap tombol logout (di ProfilePage)
   ├─> Confirmation dialog
   ├─> User konfirmasi
   ├─> Firebase Auth signOut()
   ├─> Clear local cache (optional)
   ├─> Navigator.pushReplacement() ke LoginPage
   └─> Session berakhir
```

### 6.2 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      DATA FLOW                               │
└─────────────────────────────────────────────────────────────┘

┌──────────┐
│   User   │
│ Actions  │
└────┬─────┘
     │
     ▼
┌────────────────┐
│  UI Layer      │  ← ProfilePage, SlotsPage, HomePage, etc.
│  (Widgets)     │    - User interactions
└────┬───────────┘    - Display data
     │                - Handle events
     │
     ▼
┌────────────────┐
│ State Mgmt     │  ← Provider (ThemeProvider)
│ (Provider)     │    - Manage app state
└────┬───────────┘    - Notify listeners
     │                - Persist preferences
     │
     ▼
┌────────────────┐
│ Service Layer  │  ← PaymentService, UserService, etc.
│ (Business)     │    - Business logic
└────┬───────────┘    - Data transformation
     │                - API calls
     │
     ▼
┌────────────────┐
│ Firebase SDK   │  ← Firebase Auth, Firestore
│                │    - Authentication
└────┬───────────┘    - Real-time database
     │                - Cloud storage
     │
     ▼
┌────────────────┐
│ Cloud Backend  │  ← Firebase Platform
│ (Database)     │    - Store user data
└────────────────┘    - Store transactions
                      - Store slots info
```

### 6.3 Real-time Data Sync

```
Firestore Collection → Stream → Service → UI Widget
        │                                    │
        │                                    │
        └──────────── Auto Update ──────────┘
                   (Reactive)

Example:
┌─────────────────────────────────────────────────────────────┐
│ payment_history (Firestore)                                  │
│  └─> Stream<QuerySnapshot>                                   │
│       └─> PaymentService.historyStream()                     │
│            └─> StreamBuilder<List<Payment>>                  │
│                 └─> PaymentHistoryPage.build()               │
│                      └─> ListView of payments                │
│                                                               │
│ Ketika dokumen baru ditambahkan:                             │
│  1. Firestore emit event                                     │
│  2. Stream receive update                                    │
│  3. StreamBuilder rebuild                                    │
│  4. UI update otomatis (tanpa refresh manual)                │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Summary & Kesimpulan

### 7.1 Karakteristik Sistem

**SmartPark** adalah aplikasi mobile-first dengan karakteristik:

1. **Real-time Synchronization**
   - Data sync otomatis via Firestore streams
   - No manual refresh needed
   - Instant updates across devices

2. **Offline Capability** (Future)
   - Firestore offline persistence
   - Local cache untuk data penting
   - Sync when connection available

3. **Scalable Architecture**
   - Modular service layer
   - Separation of concerns
   - Easy to extend with new features

4. **User-Centric Design**
   - Modern Material 3 UI
   - Dark mode support
   - Intuitive navigation
   - Responsive layout

5. **Security**
   - Firebase Authentication
   - Firestore Security Rules
   - Encrypted connections (HTTPS)
   - Token-based sessions

### 7.2 Future Enhancements

Berdasarkan UML ini, sistem dapat dikembangkan dengan:

1. **Advanced Features**
   - Google Maps integration
   - Real-time slot availability tracking
   - Push notifications
   - QR code scanner
   - Parking history export (PDF)

2. **Payment Integration**
   - Real payment gateway (Midtrans, Xendit)
   - Multiple payment methods
   - Auto top-up
   - Promo codes & discounts

3. **AI Enhancements**
   - Predictive slot availability
   - Smart recommendations
   - Voice commands
   - Image recognition (license plate)

4. **Analytics**
   - Advanced reporting
   - User behavior tracking
   - Business intelligence dashboard

5. **Social Features**
   - Share parking spots
   - Rate & review locations
   - Community features

---

##  Catatan Penggunaan Dokumen

Dokumen UML ini dapat digunakan untuk:

- **Development Reference** - Panduan implementasi fitur baru
- **Onboarding** - Orientasi developer baru ke codebase
- **Documentation** - Referensi arsitektur sistem
- **Presentation** - Presentasi ke stakeholder
- **Maintenance** - Troubleshooting dan debugging

Untuk update atau revisi, hubungi tim development.

---

**Last Updated:** November 12, 2025  
**Document Version:** 1.0.0  
**Author:** Development Team  
**Status:** Active


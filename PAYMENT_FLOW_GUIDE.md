# 💳 Payment Flow - Panduan Lengkap

## 📋 Overview

Dokumentasi ini menjelaskan **complete payment flow** dari booking slot sampai pembayaran di SmartPark App.

---

## 🎯 Flow Diagram

```
1. Home Page
   ↓
2. Click "Lihat Slot" → Modern Slots Page
   ↓
3. Select Available Slot → Booking Dialog
   ↓
4. Confirm Booking → Payment Created (Status: Pending)
   ↓
5. Go to "Riwayat" → Payment History Page
   ↓
6. Click "Bayar Sekarang" → QR Code Payment Dialog
   ↓
7. Scan QR / Click "Simulasi Bayar" → Status: Paid
   ↓
8. Success! ✓
```

---

## 🛠️ Technical Implementation

### 1️⃣ **Booking Slot** (`modern_slots_page.dart`)

```dart
// User clicks available slot
_showBookingDialog(slot) {
  // Shows confirmation dialog
  // Creates payment record with status: "Pending"
  PaymentService().createPayment(
    userId: currentUser.uid,
    slotId: slot.id,
    amount: 5000, // Rp 5.000
  );
}
```

**Output:**
- Payment record created in Firestore
- Status: `Pending`
- QR payload generated automatically

---

### 2️⃣ **Payment History** (`payment_history_page.dart`)

```dart
// Shows all payment history
StreamBuilder<List<PaymentHistory>>(
  stream: PaymentService().historyStream(userId),
  builder: (context, snapshot) {
    // Display payment cards
    return _PaymentCard(
      payment: payment,
      onPayNow: () => _showPaymentDialog(), // ← NEW!
    );
  },
)
```

**Features:**
- ✅ Real-time stream updates
- ✅ Status badges (Pending/Paid/Cancelled)
- ✅ **"Bayar Sekarang"** button for Pending payments
- ✅ QR info for Paid payments

---

### 3️⃣ **Payment Dialog** (`_PaymentBottomSheet`)

Bottom sheet dengan:
- 📱 **QR Code** untuk scan dengan e-wallet
- 💰 **Total amount** display
- 📝 **Instructions** step-by-step
- ⚡ **"Simulasi Bayar"** button (demo mode)

```dart
QrImageView(
  data: payment.qrPayload,
  size: 240,
  eyeStyle: QrEyeStyle(color: Color(0xFF00C9A7)),
)
```

**Demo Mode:**
- Tombol "Simulasi Bayar Sekarang" untuk testing
- Di produksi: User scan QR dengan e-wallet real
- Auto-update status ke `Paid` setelah payment

---

## 🎨 Design Improvements

### **Before (Old Design):**
```
❌ No payment button in history
❌ No way to complete pending payments
❌ Plain slot tiles (just numbers)
❌ No visual feedback
```

### **After (New Design):**
```
✅ "Bayar Sekarang" button for Pending status
✅ QR Code payment dialog
✅ Modern slot tiles with gradients & icons
✅ Professional animations
✅ Step-by-step instructions
```

---

## 📱 User Journey Example

### **Scenario:** User books Slot #5

1. **Home Page** → Click "Lihat Slot" card
2. **Slots Page** → Click Slot #5 (available, green dot)
3. **Booking Dialog** → Click "Book"
4. **Snackbar** → "✓ Slot 5 berhasil dibooking!"
5. **Navigate** → Click "Riwayat" from Quick Actions
6. **Payment History** → See Slot 5 with status "Pending" (orange)
7. **Click** → "Bayar Sekarang" button
8. **Payment Dialog** → QR Code displayed
9. **Scan QR** with e-wallet OR click "Simulasi Bayar"
10. **Success** → Status changes to "Paid" (green) ✓

---

## 🔧 Key Files Modified

| File | Changes |
|------|---------|
| `modern_slots_page.dart` | ✅ Professional slot tiles with gradients |
| `payment_history_page.dart` | ✅ Added payment button & QR dialog |
| `payment_service.dart` | ✅ QR payload generation |
| `pubspec.yaml` | ✅ Added `qr_flutter` package |

---

## 🚀 Production Checklist

Untuk produksi, ubah:

1. **QR Generation** → Integrate dengan payment gateway real (Midtrans/Xendit)
2. **Payment Verification** → Webhook untuk auto-update status
3. **Remove Demo Button** → Hapus "Simulasi Bayar Sekarang"
4. **Add Security** → Encrypt QR payload
5. **Add Timeout** → Expired payment after 15 menit

---

## 📦 Dependencies Used

```yaml
qr_flutter: ^4.1.0      # QR Code generation
intl: ^0.19.0           # Date formatting
flutter_svg: ^2.0.10+1  # SVG icons (future use)
```

---

## 🎯 Payment Status Flow

```
Pending → User needs to pay
   ↓
  Paid → Payment completed ✓
   ↓
History (read-only)
```

**Status Colors:**
- 🟠 Pending: Orange (`#FF8F00`)
- 🟢 Paid: Green (`#00C853`)
- 🔴 Cancelled: Red (`#EF5350`)

---

## ✨ Features Summary

✅ **Complete payment flow** from booking to paid
✅ **QR Code payment** integration
✅ **Modern UI/UX** with animations
✅ **Real-time updates** via Firestore streams
✅ **Professional design** Gojek/Grab style
✅ **Clear instructions** for users
✅ **Demo mode** for testing

---

**Created:** November 8, 2025
**Last Updated:** November 8, 2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore db;
  PaymentService({FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _hist =>
      db.collection('payment_history');
  DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      db.collection('users').doc(userId);

  Future<PaymentHistory> createPayment({
    required String userId,
    required String slotId,
    required int amount,
  }) async {
    // Simulasi QR payload; produksi: panggil Flask /payment/create
    // Gunakan batas aman untuk web (hindari RangeError pada shift besar)
    final rand = Random().nextInt(1 << 20); // ~1 juta kemungkinan
    final tsEpoch = DateTime.now().millisecondsSinceEpoch;
    final qr = 'QRIS:PAY:$userId:$slotId:$tsEpoch:${rand.toRadixString(16)}';
    final ts = DateTime.now();
    final doc = await _hist.add({
      'user_id': userId,
      'slot_id': slotId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(ts),
      'payment_status': 'Pending',
      'qr_payload': qr,
    });
    return PaymentHistory(
      id: doc.id,
      userId: userId,
      slotId: slotId,
      amount: amount,
      timestamp: ts,
      status: 'Pending',
      qrPayload: qr,
    );
  }

  Future<void> markPaid(String paymentId) async {
    await _hist.doc(paymentId).update({'payment_status': 'Paid'});
  }

  Stream<List<PaymentHistory>> historyStream(String userId) {
    return _hist
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => PaymentHistory.fromDoc(d)).toList());
  }

  // Simulasi saldo user di Firestore: users/{userId}.balance
  Stream<int> balanceStream(String userId) {
    return userDoc(userId)
        .snapshots()
        .map((doc) => (doc.data()?['balance'] ?? 0) as int);
  }

  Future<double> getBalance(String userId) async {
    final doc = await userDoc(userId).get();
    final balance = (doc.data()?['balance'] ?? 0);
    return (balance is int) ? balance.toDouble() : (balance as double? ?? 0.0);
  }

  Future<void> adjustBalance(String userId, int delta) async {
    await db.runTransaction((trx) async {
      final ref = userDoc(userId);
      final snap = await trx.get(ref);
      final current = (snap.data()?['balance'] ?? 0) as int;
      trx.set(ref, {'balance': current + delta}, SetOptions(merge: true));
    });
  }
}

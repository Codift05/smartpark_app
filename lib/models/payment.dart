import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistory {
  final String id;
  final String userId;
  final String slotId;
  final int amount; // in smallest currency unit
  final DateTime timestamp;
  final String status; // Pending, Paid, Failed
  final String? qrPayload;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.slotId,
    required this.amount,
    required this.timestamp,
    required this.status,
    this.qrPayload,
  });

  factory PaymentHistory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PaymentHistory(
      id: doc.id,
      userId: d['user_id'] ?? '',
      slotId: d['slot_id'] ?? '',
      amount: (d['amount'] ?? 0) as int,
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: d['payment_status'] ?? 'Pending',
      qrPayload: d['qr_payload'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'slot_id': slotId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'payment_status': status,
      'qr_payload': qrPayload,
    };
  }
}
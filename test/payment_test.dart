import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('PAYMENT - Firestore Tests', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      // ARRANGE: Setup fake firestore
      firestore = FakeFirebaseFirestore();
    });

    // TEST CASE 1: Save payment to Firestore
    test('Payment harus tersimpan di Firestore', () async {
      // ARRANGE
      const String userId = 'user123';
      const String slotId = 'slotA';
      const int amount = 50000;

      // ACT
      final paymentRef = await firestore.collection('payments').add({
        'userId': userId,
        'slotId': slotId,
        'amount': amount,
        'timestamp': Timestamp.now(),
        'status': 'pending',
      });

      // ASSERT
      final doc =
          await firestore.collection('payments').doc(paymentRef.id).get();
      expect(doc.exists, isTrue);
      expect(doc['userId'], equals(userId));
      expect(doc['amount'], equals(amount));
    });

    // TEST CASE 2: Multiple payments
    test('Multiple payments harus tersimpan dengan benar', () async {
      // ARRANGE
      final payments = [
        {'userId': 'user1', 'slotId': 'slotA', 'amount': 50000},
        {'userId': 'user2', 'slotId': 'slotB', 'amount': 75000},
        {'userId': 'user1', 'slotId': 'slotC', 'amount': 50000},
      ];

      // ACT
      for (var p in payments) {
        await firestore.collection('payments').add({
          'userId': p['userId'],
          'slotId': p['slotId'],
          'amount': p['amount'],
          'timestamp': Timestamp.now(),
        });
      }

      // ASSERT
      final docs = await firestore.collection('payments').get();
      expect(docs.docs.length, equals(3));
    });

    // TEST CASE 3: Payment has timestamp
    test('Payment harus memiliki timestamp', () async {
      // ARRANGE & ACT
      await firestore.collection('payments').add({
        'userId': 'user123',
        'amount': 50000,
        'timestamp': Timestamp.now(),
      });

      // ASSERT
      final docs = await firestore.collection('payments').get();
      expect(docs.docs.first['timestamp'], isA<Timestamp>());
    });

    // TEST CASE 4: Payment status initially pending
    test('Payment status awalnya pending', () async {
      // ARRANGE & ACT
      await firestore.collection('payments').add({
        'userId': 'user123',
        'amount': 50000,
        'status': 'pending',
      });

      // ASSERT
      final docs = await firestore.collection('payments').get();
      expect(docs.docs.first['status'], equals('pending'));
    });

    // TEST CASE 5: Update payment status to completed
    test('Update payment status menjadi completed', () async {
      // ARRANGE
      final paymentRef = await firestore.collection('payments').add({
        'userId': 'user123',
        'amount': 50000,
        'status': 'pending',
      });

      // ACT
      await firestore
          .collection('payments')
          .doc(paymentRef.id)
          .update({'status': 'completed'});

      // ASSERT
      final doc =
          await firestore.collection('payments').doc(paymentRef.id).get();
      expect(doc['status'], equals('completed'));
    });

    // TEST CASE 6: Query payments by user
    test('Query payments berdasarkan user', () async {
      // ARRANGE
      await firestore
          .collection('payments')
          .add({'userId': 'user1', 'amount': 50000});
      await firestore
          .collection('payments')
          .add({'userId': 'user2', 'amount': 75000});
      await firestore
          .collection('payments')
          .add({'userId': 'user1', 'amount': 60000});

      // ACT
      final docs = await firestore
          .collection('payments')
          .where('userId', isEqualTo: 'user1')
          .get();

      // ASSERT
      expect(docs.docs.length, equals(2));
    });

    // TEST CASE 7: Calculate total amount per user
    test('Hitung total amount payments per user', () async {
      // ARRANGE
      await firestore
          .collection('payments')
          .add({'userId': 'user1', 'amount': 50000});
      await firestore
          .collection('payments')
          .add({'userId': 'user1', 'amount': 75000});
      await firestore
          .collection('payments')
          .add({'userId': 'user1', 'amount': 50000});

      // ACT
      final docs = await firestore
          .collection('payments')
          .where('userId', isEqualTo: 'user1')
          .get();

      int total = 0;
      for (var doc in docs.docs) {
        total += doc['amount'] as int;
      }

      // ASSERT
      expect(total, equals(175000));
    });

    // TEST CASE 8: Payment with QR code
    test('Payment memiliki QR code payload', () async {
      // ARRANGE
      const qrPayload = 'QRIS:PAY:user1:slotA:1234567890';

      // ACT
      await firestore.collection('payments').add({
        'userId': 'user1',
        'amount': 50000,
        'qrCode': qrPayload,
      });

      // ASSERT
      final docs = await firestore.collection('payments').get();
      expect(docs.docs.first['qrCode'], isNotNull);
      expect((docs.docs.first['qrCode'] as String).startsWith('QRIS:PAY:'),
          isTrue);
    });

    // TEST CASE 9: Delete payment record
    test('Delete payment record dari Firestore', () async {
      // ARRANGE
      final paymentRef = await firestore.collection('payments').add({
        'userId': 'user123',
        'amount': 50000,
      });

      var docs = await firestore.collection('payments').get();
      expect(docs.docs.length, equals(1));

      // ACT
      await firestore.collection('payments').doc(paymentRef.id).delete();

      // ASSERT
      docs = await firestore.collection('payments').get();
      expect(docs.docs.length, equals(0));
    });

    // TEST CASE 10: Payment filtering by status
    test('Filter payment history berdasarkan status', () async {
      // ARRANGE
      await firestore.collection('payments').add({
        'userId': 'user1',
        'amount': 50000,
        'status': 'completed',
      });
      await firestore.collection('payments').add({
        'userId': 'user1',
        'amount': 75000,
        'status': 'pending',
      });

      // ACT
      final completedDocs = await firestore
          .collection('payments')
          .where('userId', isEqualTo: 'user1')
          .where('status', isEqualTo: 'completed')
          .get();

      // ASSERT
      expect(completedDocs.docs.length, equals(1));
      expect(completedDocs.docs.first['status'], equals('completed'));
    });
  });
}

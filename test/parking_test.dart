import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('PARKING STATUS - Firestore Integration Tests', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      // ARRANGE: Setup FakeFirebaseFirestore
      firestore = FakeFirebaseFirestore();
    });

    // TEST CASE 1: Create parking slot
    test('Membuat parking slot baru harus berhasil', () async {
      // ARRANGE
      const String slotId = 'slotA';
      const String slotsCollection = 'parking_slots';

      // ACT
      await firestore.collection(slotsCollection).doc(slotId).set({
        'id': slotId,
        'name': 'Slot A',
        'occupied': false,
        'lastUpdated': Timestamp.now(),
      });

      // ASSERT
      final doc = await firestore.collection(slotsCollection).doc(slotId).get();
      expect(doc.exists, isTrue);
      expect(doc['id'], equals(slotId));
      expect(doc['occupied'], isFalse);
    });

    // TEST CASE 2: Update slot status
    test('Update status slot dari tersedia menjadi terisi', () async {
      // ARRANGE
      const String slotId = 'slotB';
      const String slotsCollection = 'parking_slots';

      await firestore.collection(slotsCollection).doc(slotId).set({
        'id': slotId,
        'occupied': false,
      });

      // ACT: Update ke occupied
      await firestore.collection(slotsCollection).doc(slotId).update({
        'occupied': true,
        'lastUpdated': Timestamp.now(),
      });

      // ASSERT
      final doc = await firestore.collection(slotsCollection).doc(slotId).get();
      expect(doc['occupied'], isTrue);
    });

    // TEST CASE 3: Query available slots
    test('Query slots tersedia harus mengembalikan hasil yang benar', () async {
      // ARRANGE
      const String slotsCollection = 'parking_slots';
      final slotsData = [
        {'id': 'slotA', 'occupied': false},
        {'id': 'slotB', 'occupied': true},
        {'id': 'slotC', 'occupied': false},
      ];

      for (var slot in slotsData) {
        await firestore
            .collection(slotsCollection)
            .doc(slot['id'] as String)
            .set({
          'id': slot['id'],
          'occupied': slot['occupied'],
        });
      }

      // ACT
      final available = await firestore
          .collection(slotsCollection)
          .where('occupied', isEqualTo: false)
          .get();

      // ASSERT
      expect(available.docs.length, equals(2));
      for (var doc in available.docs) {
        expect(doc['occupied'], isFalse);
      }
    });

    // TEST CASE 4: Count occupied slots
    test('Hitung slot yang terisi harus akurat', () async {
      // ARRANGE
      const String slotsCollection = 'parking_slots';
      final slotsData = [
        {'id': 'slot1', 'occupied': true},
        {'id': 'slot2', 'occupied': true},
        {'id': 'slot3', 'occupied': false},
        {'id': 'slot4', 'occupied': false},
      ];

      for (var slot in slotsData) {
        await firestore
            .collection(slotsCollection)
            .doc(slot['id'] as String)
            .set({
          'id': slot['id'],
          'occupied': slot['occupied'],
        });
      }

      // ACT
      final occupied = await firestore
          .collection(slotsCollection)
          .where('occupied', isEqualTo: true)
          .get();
      final available = await firestore
          .collection(slotsCollection)
          .where('occupied', isEqualTo: false)
          .get();

      // ASSERT
      expect(occupied.docs.length, equals(2));
      expect(available.docs.length, equals(2));
    });

    // TEST CASE 5: Delete parking slot
    test('Delete parking slot harus bekerja', () async {
      // ARRANGE
      const String slotId = 'slotE';
      const String slotsCollection = 'parking_slots';

      await firestore.collection(slotsCollection).doc(slotId).set({
        'id': slotId,
        'occupied': false,
      });

      var doc = await firestore.collection(slotsCollection).doc(slotId).get();
      expect(doc.exists, isTrue);

      // ACT
      await firestore.collection(slotsCollection).doc(slotId).delete();

      // ASSERT
      doc = await firestore.collection(slotsCollection).doc(slotId).get();
      expect(doc.exists, isFalse);
    });

    // TEST CASE 6: Batch update multiple slots
    test('Update multiple slots dalam satu batch', () async {
      // ARRANGE
      const String slotsCollection = 'parking_slots';
      final slots = ['slot1', 'slot2', 'slot3'];

      for (String slotId in slots) {
        await firestore.collection(slotsCollection).doc(slotId).set({
          'id': slotId,
          'occupied': false,
        });
      }

      // ACT: Batch update
      WriteBatch batch = firestore.batch();
      for (int i = 0; i < slots.length; i++) {
        batch.update(
          firestore.collection(slotsCollection).doc(slots[i]),
          {'occupied': i % 2 == 0},
        );
      }
      await batch.commit();

      // ASSERT
      for (int i = 0; i < slots.length; i++) {
        final doc =
            await firestore.collection(slotsCollection).doc(slots[i]).get();
        expect(doc['occupied'], equals(i % 2 == 0));
      }
    });

    // TEST CASE 7: Occupancy calculation
    test('Kalkulasi ketersediaan parkir harus akurat', () async {
      // ARRANGE
      const String slotsCollection = 'parking_slots';
      const int totalSlots = 10;

      for (int i = 0; i < totalSlots; i++) {
        await firestore.collection(slotsCollection).doc('slot$i').set({
          'id': 'slot$i',
          'occupied': i < 3,
        });
      }

      // ACT
      final allDocs = await firestore.collection(slotsCollection).get();
      final occupiedCount = allDocs.docs.where((doc) => doc['occupied']).length;
      final availableCount = totalSlots - occupiedCount;
      final occupancyPercentage =
          (occupiedCount / totalSlots * 100).toStringAsFixed(1);

      // ASSERT
      expect(allDocs.docs.length, equals(totalSlots));
      expect(occupiedCount, equals(3));
      expect(availableCount, equals(7));
      expect(occupancyPercentage, equals('30.0'));
    });

    // TEST CASE 8: Timestamp tracking
    test('Timestamp harus ter-update saat status berubah', () async {
      // ARRANGE
      const String slotId = 'slotF';
      const String slotsCollection = 'parking_slots';
      final beforeTime = DateTime.now();

      await firestore.collection(slotsCollection).doc(slotId).set({
        'id': slotId,
        'occupied': false,
        'updatedAt': Timestamp.fromDate(beforeTime),
      });

      await Future.delayed(const Duration(milliseconds: 100));

      // ACT
      final afterTime = DateTime.now();
      await firestore.collection(slotsCollection).doc(slotId).update({
        'occupied': true,
        'updatedAt': Timestamp.fromDate(afterTime),
      });

      // ASSERT
      final doc = await firestore.collection(slotsCollection).doc(slotId).get();
      final updatedTime = (doc['updatedAt'] as Timestamp).toDate();
      expect(updatedTime.isAfter(beforeTime), isTrue);
    });
  });
}

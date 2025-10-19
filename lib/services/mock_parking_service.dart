import 'dart:async';
import 'dart:math';
import '../models/slot.dart';
import '../models/prediction.dart';

class MockParkingService {
  final int totalSlots;
  final _rand = Random();
  late List<ParkingSlot> _slots;
  final _slotsController = StreamController<List<ParkingSlot>>.broadcast();
  final _predController = StreamController<Prediction>.broadcast();
  Timer? _timer;

  MockParkingService({this.totalSlots = 12}) {
    _slots = List.generate(
      totalSlots,
      (i) => ParkingSlot(id: i + 1, occupied: false, lastUpdated: DateTime.now()),
    );
  }

  Stream<List<ParkingSlot>> get slotsStream => _slotsController.stream;
  Stream<Prediction> get predictionStream => _predController.stream;

  void start() {
    _emit();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Randomly toggle a few slots
      final changes = _rand.nextInt(max(1, totalSlots ~/ 3));
      for (int c = 0; c < changes; c++) {
        final i = _rand.nextInt(totalSlots);
        final current = _slots[i];
        final flip = _rand.nextBool();
        if (flip) {
          _slots[i] = current.copyWith(
            occupied: !current.occupied,
            lastUpdated: DateTime.now(),
          );
        }
      }
      _emit();
    });
  }

  void _emit() {
    final snapshot = List<ParkingSlot>.unmodifiable(_slots);
    _slotsController.add(snapshot);
    _predController.add(_makePrediction(snapshot));
  }

  Prediction _makePrediction(List<ParkingSlot> snapshot) {
    final occ = snapshot.where((s) => s.occupied).length;
    final ratio = occ / snapshot.length;
    // Simple probabilistic mapping with noise
    final noise = (_rand.nextDouble() - 0.5) * 0.2; // [-0.1, 0.1]
    double high = (ratio + noise).clamp(0.0, 1.0);
    double low = (1.0 - ratio - noise).clamp(0.0, 1.0);
    double medium = (1.0 - low - high).clamp(0.0, 1.0);
    final pairs = {
      'Rendah': low,
      'Sedang': medium,
      'Tinggi': high,
    };
    final level = pairs.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return Prediction(
      level: level,
      low: low,
      medium: medium,
      high: high,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {
    _timer?.cancel();
    _slotsController.close();
    _predController.close();
  }
}
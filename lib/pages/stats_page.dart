import 'package:flutter/material.dart';
import '../services/mock_parking_service.dart';
import '../models/prediction.dart';
import '../models/slot.dart';

class StatsPage extends StatelessWidget {
  final MockParkingService service;
  const StatsPage({super.key, required this.service});

  Color _levelColor(String level) {
    switch (level) {
      case 'Tinggi':
        return Colors.red;
      case 'Sedang':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StreamBuilder<Prediction>(
          stream: service.predictionStream,
          builder: (context, snap) {
            final pred = snap.data;
            if (pred == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prediksi Kepadatan', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(pred.level, style: TextStyle(color: _levelColor(pred.level), fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('(${pred.timestamp.hour.toString().padLeft(2, '0')}:${pred.timestamp.minute.toString().padLeft(2, '0')})'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _probRow('Rendah', pred.low),
                    _probRow('Sedang', pred.medium),
                    _probRow('Tinggi', pred.high),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ParkingSlot>>(
          stream: service.slotsStream,
          builder: (context, snap) {
            final slots = snap.data ?? [];
            final occ = slots.where((s) => s.occupied).length;
            final total = slots.length;
            final usage = total == 0 ? 0 : ((occ / total) * 100).round();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistik Harian', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Tingkat penggunaan: $usage%'),
                    const SizedBox(height: 8),
                    Text('Kunjungan estimasi hari ini: ${(usage * 3) + 10}'),
                    const SizedBox(height: 8),
                    Text('Waktu puncak (simulasi): 12:00 - 13:00'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _probRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${(value * 100).round()}%'),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: value),
        ],
      ),
    );
  }
}
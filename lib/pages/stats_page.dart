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
            final levelColor = _levelColor(pred.level);
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.insights, color: Theme.of(context).colorScheme.primary),
                      title: Text('Prediksi Kepadatan', style: Theme.of(context).textTheme.titleLarge),
                      subtitle: Text('Data realtime + simulasi pembelajaran'),
                      trailing: Chip(
                        label: Text(pred.level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: levelColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text('(${pred.timestamp.hour.toString().padLeft(2, '0')}:${pred.timestamp.minute.toString().padLeft(2, '0')})'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _probRow(context, 'Rendah', pred.low),
                    _probRow(context, 'Sedang', pred.medium),
                    _probRow(context, 'Tinggi', pred.high),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary),
                      title: Text('Statistik Harian', style: Theme.of(context).textTheme.titleLarge),
                      subtitle: Text('Ringkasan penggunaan area parkir'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text('Terisi: $occ'), avatar: const Icon(Icons.directions_car)),
                        const SizedBox(width: 8),
                        Chip(label: Text('Total: $total'), avatar: const Icon(Icons.local_parking)),
                        const SizedBox(width: 8),
                        Chip(label: Text('Usage: $usage%'), avatar: const Icon(Icons.speed)),
                      ],
                    ),
                    const SizedBox(height: 12),
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

  Widget _probRow(BuildContext context, String label, double value) {
    Color color;
    switch (label) {
      case 'Rendah':
        color = Colors.green;
        break;
      case 'Sedang':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$label: ${(value * 100).round()}%'),
              Text('${(value * 100).round()}%', style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}
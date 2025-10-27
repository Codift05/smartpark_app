import 'package:flutter/material.dart';
import '../ui/styles.dart';
import '../services/mock_parking_service.dart';
import '../models/slot.dart';

class SlotsPage extends StatelessWidget {
  final MockParkingService service;
  const SlotsPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        title:
            const Text('Home', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: StreamBuilder<List<ParkingSlot>>(
          stream: service.slotsStream,
          builder: (context, snap) {
            final slots = snap.data;
            if (slots == null) {
              return const Center(child: CircularProgressIndicator());
            }
            // modern header stats
            final occupiedCount = slots.where((s) => s.occupied).length;
            final emptyCount = slots.length - occupiedCount;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Area Parkir', style: AppText.h2(context)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statChip(
                          context, 'Terisi', occupiedCount, AppColors.blue),
                      _statChip(context, 'Kosong', emptyCount, Colors.green),
                      _statChip(context, 'Total', slots.length,
                          AppColors.navy.withValues(alpha: 0.7)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      // scrollable agar tidak overflow
                      itemCount: slots.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final occupied = slot.occupied;
                        return AppCard(
                          color: occupied
                              ? AppColors.accent.withValues(alpha: 0.06)
                              : Colors.white,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: occupied
                                        ? AppColors.blue
                                        : AppColors.navy.withValues(alpha: 0.1),
                                    child: Icon(Icons.local_parking,
                                        color: occupied
                                            ? Colors.white
                                            : AppColors.blue,
                                        size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Slot ${slot.id}',
                                        style: AppText.body(context).copyWith(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: occupied
                                          ? AppColors.blue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: occupied
                                              ? Colors.transparent
                                              : Colors.black12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            occupied
                                                ? Icons.lock
                                                : Icons.lock_open,
                                            size: 14,
                                            color: occupied
                                                ? Colors.white
                                                : AppColors.navy
                                                    .withValues(alpha: 0.7)),
                                        const SizedBox(width: 6),
                                        Text(
                                          occupied ? 'Terisi' : 'Kosong',
                                          style: AppText.caption(context)
                                              .copyWith(
                                                  color: occupied
                                                      ? Colors.white
                                                      : AppColors
                                                          .navy
                                                          .withValues(
                                                              alpha: 0.7)),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule,
                                      size: 14, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Diperbarui ${slot.lastUpdated.hour.toString().padLeft(2, '0')}:${slot.lastUpdated.minute.toString().padLeft(2, '0')}',
                                    style: AppText.caption(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _statChip(BuildContext context, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('$label: $value',
              style: AppText.caption(context).copyWith(color: AppColors.navy)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/mock_parking_service.dart';
import '../models/slot.dart';

class SlotsPage extends StatefulWidget {
  final MockParkingService service;
  const SlotsPage({super.key, required this.service});

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: StreamBuilder<List<ParkingSlot>>(
          stream: widget.service.slotsStream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = snap.data!;
            final available = all.where((s) => !s.occupied).length;
            final occupied = all.length - available;

            final slots = _selectedFilter == 'Semua'
                ? all
                : _selectedFilter == 'Tersedia'
                    ? all.where((s) => !s.occupied).toList()
                    : all.where((s) => s.occupied).toList();

            return Column(
              children: [
                // Header with gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF26D0CE), Color(0xFF1A9996)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // AppBar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios,
                                    color: Colors.white, size: 20),
                              ),
                              const Expanded(
                                child: Text(
                                  'Pilih Slot Parkir',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Stat Cards
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.check_circle,
                                  label: 'Tersedia',
                                  value: available,
                                  color: const Color(0xFF26D0CE),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.cancel,
                                  label: 'Terisi',
                                  value: occupied,
                                  color: const Color(0xFFEF5350),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Tersedia'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Terisi'),
                    ],
                  ),
                ),

                // Slots Grid
                Expanded(
                  child: slots.isEmpty
                      ? const Center(child: Text('Tidak ada slot'))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: slots.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                          itemBuilder: (context, i) {
                            final s = slots[i];
                            return _buildSlotCard(s);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF26D0CE) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF26D0CE) : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(ParkingSlot slot) {
    final isAvailable = !slot.occupied;
    return GestureDetector(
      onTap: isAvailable ? () => _confirmBooking(slot) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable
              ? const Color(0xFF26D0CE).withOpacity(0.2)
              : const Color(0xFFEF5350).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.local_parking : Icons.lock,
              color: isAvailable
                  ? const Color(0xFF26D0CE)
                  : const Color(0xFFEF5350),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              '${slot.id}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAvailable
                    ? const Color(0xFF1A9996)
                    : const Color(0xFFEF5350),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking(ParkingSlot slot) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Booking Slot ${slot.id}'),
        content: const Text('Konfirmasi booking untuk slot ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Slot ${slot.id} berhasil dibooking!'),
                  backgroundColor: const Color(0xFF26D0CE),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26D0CE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Booking'),
          ),
        ],
      ),
    );
  }
}

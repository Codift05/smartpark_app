import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_parking_service.dart';
import '../models/prediction.dart';
import '../models/slot.dart';
import '../ui/loading_animation.dart';

class StatsPage extends StatefulWidget {
  final MockParkingService service;
  const StatsPage({super.key, required this.service});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Clean modern theme colors - minimal palette
  static const Color _bgLight = Color(0xFFF8F9FA);
  static const Color _cardWhite = Color(0xFFFFFFFF);

  DateTime? _lastPredTs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analisis real-time area parkir',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick Stats Cards
                  StreamBuilder<List<ParkingSlot>>(
                    stream: widget.service.slotsStream,
                    builder: (context, snap) {
                      final slots = snap.data ?? const <ParkingSlot>[];
                      final occupied = slots.where((s) => s.occupied).length;
                      final total = slots.length;
                      final available = total - occupied;
                      final usage =
                          total == 0 ? 0 : ((occupied / total) * 100).round();

                      return Column(
                        children: [
                          // Quick Stats Row
                          Row(
                            children: [
                              Expanded(
                                child: _QuickStatCard(
                                  icon: Icons.local_parking_rounded,
                                  label: 'Tersedia',
                                  value: available.toString(),
                                  iconColor: const Color(0xFF00C9A7),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickStatCard(
                                  icon: Icons.directions_car_rounded,
                                  label: 'Terisi',
                                  value: occupied.toString(),
                                  iconColor: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickStatCard(
                                  icon: Icons.analytics_rounded,
                                  label: 'Tingkat Hunian',
                                  value: '$usage%',
                                  iconColor: const Color(0xFF00C9A7),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickStatCard(
                                  icon: Icons.garage_rounded,
                                  label: 'Total Slot',
                                  value: total.toString(),
                                  iconColor: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Prediksi Kepadatan Card
                  StreamBuilder<Prediction>(
                    stream: widget.service.predictionStream,
                    builder: (context, snap) {
                      final pred = snap.data;
                      if (pred == null) {
                        return const ModernLoadingAnimation(
                          type: LoadingType.builtIn,
                          size: 120,
                          customMessage: 'Memuat prediksi...',
                        );
                      }

                      // Update timestamp
                      if (_lastPredTs != pred.timestamp) {
                        _lastPredTs = pred.timestamp;
                      }

                      return _ModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C9A7)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.insights_rounded,
                                    color: Color(0xFF00C9A7),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Prediksi Kepadatan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF00C9A7),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Live • ${pred.timestamp.hour.toString().padLeft(2, '0')}:${pred.timestamp.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusBadge(level: pred.level),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Progress Bars
                            _ModernProgressBar(
                              label: 'Rendah',
                              value: pred.low,
                              icon: Icons.arrow_downward_rounded,
                              color: const Color(0xFF00C9A7),
                            ),
                            const SizedBox(height: 14),
                            _ModernProgressBar(
                              label: 'Sedang',
                              value: pred.medium,
                              icon: Icons.remove_rounded,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(height: 14),
                            _ModernProgressBar(
                              label: 'Tinggi',
                              value: pred.high,
                              icon: Icons.arrow_upward_rounded,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Activity Summary Card
                  StreamBuilder<List<ParkingSlot>>(
                    stream: widget.service.slotsStream,
                    builder: (context, snap) {
                      final slots = snap.data ?? const <ParkingSlot>[];
                      final usage = slots.isEmpty
                          ? 0
                          : ((slots.where((s) => s.occupied).length /
                                      slots.length) *
                                  100)
                              .round();
                      final estVisit = (usage * 3) + 15;

                      return _ModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00C9A7)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.timeline_rounded,
                                    color: Color(0xFF00C9A7),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Aktivitas Hari Ini',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Activity Items
                            _ActivityItem(
                              icon: Icons.groups_rounded,
                              label: 'Estimasi Pengunjung',
                              value: '$estVisit kendaraan',
                              color: const Color(0xFF00C9A7),
                            ),
                            const SizedBox(height: 12),
                            const _ActivityItem(
                              icon: Icons.schedule_rounded,
                              label: 'Waktu Puncak',
                              value: '12:00 - 13:00 WIB',
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(height: 12),
                            _ActivityItem(
                              icon: Icons.trending_up_rounded,
                              label: 'Trend Hunian',
                              value: usage > 50 ? 'Meningkat' : 'Stabil',
                              color: const Color(0xFF00C9A7),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100), // Bottom padding for navbar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Modern UI Components ============

// Quick Stat Card - Clean minimal style
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Card Container
class _ModernCard extends StatelessWidget {
  final Widget child;

  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Status Badge - Clean style
class _StatusBadge extends StatelessWidget {
  final String level;

  const _StatusBadge({required this.level});

  Color _getColor() {
    switch (level) {
      case 'Tinggi':
        return const Color(0xFF1A1A1A);
      case 'Sedang':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF00C9A7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        level,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Modern Progress Bar - Clean minimal style
class _ModernProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _ModernProgressBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Text(
              '$percent%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFF3F4F6),
                ),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: value),
                  builder: (context, v, _) {
                    return FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Activity Item - Clean minimal style
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}

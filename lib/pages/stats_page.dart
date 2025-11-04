import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mock_parking_service.dart';
import '../models/prediction.dart';
import '../models/slot.dart';

class StatsPage extends StatefulWidget {
  final MockParkingService service;
  const StatsPage({super.key, required this.service});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  // Modern theme colors - Gojek/Traveloka inspired
  static const Color _primaryGreen = Color(0xFF00AA13);
  static const Color _secondaryBlue = Color(0xFF0081A0);
  static const Color _accentOrange = Color(0xFFFF6F00);
  static const Color _bgLight = Color(0xFFF8F9FA);
  static const Color _cardWhite = Color(0xFFFFFFFF);

  late final AnimationController _pulseCtrl;
  DateTime? _lastPredTs;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

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
                                  color: _primaryGreen,
                                  gradient: const [
                                    Color(0xFF00AA13),
                                    Color(0xFF00C853)
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickStatCard(
                                  icon: Icons.directions_car_rounded,
                                  label: 'Terisi',
                                  value: occupied.toString(),
                                  color: _secondaryBlue,
                                  gradient: const [
                                    Color(0xFF0081A0),
                                    Color(0xFF00ACC1)
                                  ],
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
                                  color: _accentOrange,
                                  gradient: const [
                                    Color(0xFFFF6F00),
                                    Color(0xFFFF8F00)
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickStatCard(
                                  icon: Icons.garage_rounded,
                                  label: 'Total Slot',
                                  value: total.toString(),
                                  color: const Color(0xFF7B1FA2),
                                  gradient: const [
                                    Color(0xFF7B1FA2),
                                    Color(0xFF9C27B0)
                                  ],
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
                        return const Center(child: CircularProgressIndicator());
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
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.insights_rounded,
                                    color: Colors.white,
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
                                            decoration: BoxDecoration(
                                              color: _primaryGreen,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Live • ${pred.timestamp.hour.toString().padLeft(2, '0')}:${pred.timestamp.minute.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black45,
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
                              colors: const [
                                Color(0xFF00C853),
                                Color(0xFF64DD17)
                              ],
                            ),
                            const SizedBox(height: 14),
                            _ModernProgressBar(
                              label: 'Sedang',
                              value: pred.medium,
                              icon: Icons.remove_rounded,
                              colors: const [
                                Color(0xFFFF8F00),
                                Color(0xFFFFAB00)
                              ],
                            ),
                            const SizedBox(height: 14),
                            _ModernProgressBar(
                              label: 'Tinggi',
                              value: pred.high,
                              icon: Icons.arrow_upward_rounded,
                              colors: const [
                                Color(0xFFE53935),
                                Color(0xFFFF6F00)
                              ],
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
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFf093fb),
                                        Color(0xFFf5576c)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFf5576c)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.timeline_rounded,
                                    color: Colors.white,
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
                              color: const Color(0xFF667EEA),
                            ),
                            const SizedBox(height: 12),
                            _ActivityItem(
                              icon: Icons.schedule_rounded,
                              label: 'Waktu Puncak',
                              value: '12:00 - 13:00 WIB',
                              color: const Color(0xFFFF6F00),
                            ),
                            const SizedBox(height: 12),
                            _ActivityItem(
                              icon: Icons.trending_up_rounded,
                              label: 'Trend Hunian',
                              value: usage > 50 ? 'Meningkat' : 'Stabil',
                              color: const Color(0xFF00C853),
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

// Quick Stat Card - Gojek/Traveloka style
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final List<Color> gradient;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
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
              color: Colors.black54,
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

// Status Badge
class _StatusBadge extends StatelessWidget {
  final String level;

  const _StatusBadge({required this.level});

  List<Color> _getColors() {
    switch (level) {
      case 'Tinggi':
        return const [Color(0xFFE53935), Color(0xFFFF6F00)];
      case 'Sedang':
        return const [Color(0xFFFF8F00), Color(0xFFFFAB00)];
      default:
        return const [Color(0xFF00C853), Color(0xFF64DD17)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        level,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Modern Progress Bar
class _ModernProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final List<Color> colors;

  const _ModernProgressBar({
    required this.label,
    required this.value,
    required this.icon,
    required this.colors,
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
                color: colors[0].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: colors[0]),
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
                color: colors[0],
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                          gradient: LinearGradient(colors: colors),
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

// Activity Item
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
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
                    color: Colors.black54,
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
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.black26),
        ],
      ),
    );
  }
}

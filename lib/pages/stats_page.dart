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
  // Theme & accents
  static const Color _softPage = Color(0xFFEAF3FF);
  static const Color _white = Colors.white;
  static const Color _accentBlue = Color(0xFF3A8DFF);
  static const Color _gradStart = Color(0xFF4FC3F7);
  static const Color _gradEnd = Color(0xFF1976D2);

  late final AnimationController _pulseCtrl;
  double _scrollOffset = 0;
  DateTime? _lastPredTs;
  bool _flashPred = false;

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
    final titleStyle = GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF0F172A),
    );
    final subtitleStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _softPage,
            Color(0xFFF7FAFF),
          ],
        ),
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.axis == Axis.vertical) {
            setState(() => _scrollOffset = n.metrics.pixels);
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            // Prediksi Kepadatan
            StreamBuilder<Prediction>(
              stream: widget.service.predictionStream,
              builder: (context, snap) {
                final pred = snap.data;
                if (pred == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Trigger subtle flash when new data arrives
                if (_lastPredTs != pred.timestamp) {
                  _lastPredTs = pred.timestamp;
                  Future.microtask(() {
                    if (mounted) {
                      setState(() => _flashPred = true);
                      Future.delayed(const Duration(milliseconds: 700), () {
                        if (mounted) setState(() => _flashPred = false);
                      });
                    }
                  });
                }

                final badgeColors = _levelGradient(pred.level);
                return Transform.translate(
                  offset: Offset(0, -_scrollOffset * 0.03),
                  child: _InteractiveScale(
                    child: Stack(
                      children: [
                        _GlassCard(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [_gradStart, _gradEnd],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.insights,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Prediksi Kepadatan',
                                            style: titleStyle),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule,
                                                size: 16,
                                                color: Colors.black45),
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${pred.timestamp.hour.toString().padLeft(2, '0')}:${pred.timestamp.minute.toString().padLeft(2, '0')}) • realtime',
                                              style: subtitleStyle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  _GradientBadge(
                                      text: pred.level, colors: badgeColors),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _PulseIcon(controller: _pulseCtrl),
                              const SizedBox(height: 14),
                              _GradientProgressBar(
                                  label: 'Rendah',
                                  value: pred.low,
                                  start: Colors.greenAccent,
                                  end: Colors.green),
                              const SizedBox(height: 10),
                              _GradientProgressBar(
                                  label: 'Sedang',
                                  value: pred.medium,
                                  start: Colors.orangeAccent,
                                  end: Colors.deepOrange),
                              const SizedBox(height: 10),
                              _GradientProgressBar(
                                  label: 'Tinggi',
                                  value: pred.high,
                                  start: Colors.redAccent,
                                  end: Colors.red),
                            ],
                          ),
                        ),
                        _HighlightFlash(active: _flashPred, color: _accentBlue),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // Statistik Harian
            StreamBuilder<List<ParkingSlot>>(
              stream: widget.service.slotsStream,
              builder: (context, snap) {
                final slots = snap.data ?? const <ParkingSlot>[];
                final occ = slots.where((s) => s.occupied).length;
                final total = slots.length;
                final usage = total == 0 ? 0 : ((occ / total) * 100).round();
                final estVisit = (usage * 3) + 10;

                return Transform.translate(
                  offset: Offset(0, -_scrollOffset * 0.015),
                  child: _InteractiveScale(
                    child: _GlassCard(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE3F2FD),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.bar_chart,
                                    color: _accentBlue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Statistik Harian', style: titleStyle),
                                    const SizedBox(height: 4),
                                    Text('Ringkasan penggunaan area parkir',
                                        style: subtitleStyle),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _InfoRow(
                                  icon: Icons.directions_car,
                                  label: 'Terisi',
                                  value: '$occ / $total'),
                              _InfoRow(
                                  icon: Icons.speed,
                                  label: 'Usage',
                                  value: '$usage%'),
                              _InfoRow(
                                  icon: Icons.groups_rounded,
                                  label: 'Estimasi kunjungan',
                                  value: '$estVisit'),
                              const _InfoRow(
                                  icon: Icons.access_time,
                                  label: 'Puncak',
                                  value: '12:00 - 13:00'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Gradient colors for badges based on level
  List<Color> _levelGradient(String level) {
    switch (level) {
      case 'Tinggi':
        return const [Color(0xFFFF6B6B), Color(0xFFFF8E53)]; // red → orange
      case 'Sedang':
        return const [Color(0xFFFFC371), Color(0xFFFFA24C)]; // soft orange
      default:
        return const [Color(0xFF84FAB0), Color(0xFF2BD2FF)]; // greenish → cyan
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlassCard(
      {required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 12),
              child: const SizedBox.shrink(),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _GradientBadge extends StatelessWidget {
  final String text;
  final List<Color> colors;
  const _GradientBadge({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _PulseIcon extends StatelessWidget {
  final AnimationController controller;
  const _PulseIcon({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final scale = 1 + (controller.value * 0.08);
          final opacity = 0.6 + (controller.value * 0.4);
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up,
                        color: Color(0xFF1E88E5), size: 18),
                    const SizedBox(width: 6),
                    Text('Aktif',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E88E5))),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  final String label;
  final double value; // 0..1
  final Color start;
  final Color end;
  const _GradientProgressBar(
      {required this.label,
      required this.value,
      required this.start,
      required this.end});

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            Text('$percent%',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: width,
                    decoration:
                        BoxDecoration(color: Colors.black12.withOpacity(0.06)),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0, end: value),
                    builder: (context, v, child) {
                      return Container(
                        height: 12,
                        width: width * v,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [start, end],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                          boxShadow: [
                            BoxShadow(
                                color: end.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3A8DFF)),
          const SizedBox(width: 8),
          Text('$label: ',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

class _InteractiveScale extends StatefulWidget {
  final Widget child;
  const _InteractiveScale({required this.child});

  @override
  State<_InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<_InteractiveScale> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _scale = 1.02),
      onExit: (_) => setState(() => _scale = 1.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.98),
        onTapUp: (_) => setState(() => _scale = 1.02),
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: _scale,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class _HighlightFlash extends StatelessWidget {
  final bool active;
  final Color color;
  const _HighlightFlash({required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: active ? 0.25 : 0.0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withOpacity(0.0),
                color.withOpacity(0.15),
                color.withOpacity(0.0)
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

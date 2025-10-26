import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/slot.dart';
import '../services/mock_parking_service.dart';
import 'slots_page.dart';
import 'map_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MockParkingService service;
  int index = 0;
  bool _notifiedFull = false;

  @override
  void initState() {
    super.initState();
    service = MockParkingService(totalSlots: 12)..start();
    service.slotsStream.listen((slots) {
      final occupied = slots.where((s) => s.occupied).length;
      final total = slots.length;
      if (occupied == total && !_notifiedFull) {
        _notifiedFull = true;
        _showSnack('Area parkir penuh', Colors.red);
      } else if (occupied < total && _notifiedFull) {
        _notifiedFull = false;
        _showSnack('Slot kosong baru tersedia', Colors.green);
      }
    });
  }

  void _showSnack(String msg, Color color) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      extendBody: true,
      body: IndexedStack(
        index: index,
        children: [
          ModernHome(service: service),
          MapPage(),
          StatsPage(service: service),
        ],
      ),
      bottomNavigationBar: _ModernFloatingNavBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

class ModernHome extends StatelessWidget {
  final MockParkingService service;
  const ModernHome({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -60,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SafeArea(
          child: StreamBuilder<List<ParkingSlot>>(
            stream: service.slotsStream,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final slots = snap.data!;
              final occupiedCount = slots.where((s) => s.occupied).length;
              final emptyCount = slots.length - occupiedCount;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Home',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(255, 0, 57, 50),
                          ),
                        ),
                        const Icon(Icons.notifications_none,
                            color: Color.fromARGB(255, 0, 60, 57)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Area Parkir',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 0, 43, 39),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _badge('Terisi', occupiedCount,
                            const [Color(0xFF6EC1E4), Color(0xFF64B5F6)]),
                        _badge('Kosong', emptyCount,
                            const [Color(0xFF81C784), Color(0xFF66BB6A)]),
                        _badge('Total', slots.length,
                            const [Color(0xFF90A4AE), Color(0xFF78909C)]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: slots.length,
                        itemBuilder: (context, i) {
                          final slot = slots[i];
                          return _AnimatedSlotCard(slot: slot, index: i);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _badge(String label, int value, List<Color> colors) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.circle, size: 8, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _AnimatedSlotCard extends StatelessWidget {
  final ParkingSlot slot;
  final int index;
  const _AnimatedSlotCard({required this.slot, required this.index});

  @override
  Widget build(BuildContext context) {
    final isOccupied = slot.occupied;
    final accent = const Color(0xFF26A69A); // teal
    final titleStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF283D4A),
    );
    final subtitleStyle =
        GoogleFonts.poppins(fontSize: 12, color: Colors.black54);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 480 + (index * 40)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: child!,
          ),
        );
      },
      child: _HoverableCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {},
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          isOccupied ? accent : const Color(0xFFE3F2FD),
                      child: Icon(
                        Icons.local_parking,
                        color:
                            isOccupied ? Colors.white : const Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Slot ${slot.id}', style: titleStyle),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text(
                                'Diperbarui ${slot.lastUpdated.hour.toString().padLeft(2, '0')}:${slot.lastUpdated.minute.toString().padLeft(2, '0')}',
                                style: subtitleStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusChip(isOccupied),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _statusChip(bool occupied) {
  final accent = const Color(0xFF26A69A);
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: occupied ? accent : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: occupied ? Colors.transparent : Colors.black12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(occupied ? Icons.lock : Icons.lock_open,
            size: 16, color: occupied ? Colors.white : const Color(0xFF1E88E5)),
        const SizedBox(width: 6),
        Text(
          occupied ? 'Terisi' : 'Kosong',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: occupied ? Colors.white : const Color(0xFF1E88E5),
          ),
        ),
      ],
    ),
  );
}

class _HoverableCard extends StatefulWidget {
  final Widget child;
  const _HoverableCard({required this.child});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        scale: hovered ? 0.995 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _ModernFloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_ModernFloatingNavBar> createState() => _ModernFloatingNavBarState();
}

class _ModernFloatingNavBarState extends State<_ModernFloatingNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _animationController.forward().then((_) {
      _animationController.reverse();
      widget.onTap(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                  isSelected: widget.currentIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                _NavItem(
                  icon: Icons.map_rounded,
                  label: 'Map',
                  isSelected: widget.currentIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                _NavItem(
                  icon: Icons.insights_rounded,
                  label: 'Stats',
                  isSelected: widget.currentIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1E88E5).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF1E88E5)
                      : Colors.black.withOpacity(0.6),
                  size: 24,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

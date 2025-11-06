import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/slot.dart';
import '../services/mock_parking_service.dart';
import '../services/user_service.dart';
import 'map_page.dart';
import 'stats_page.dart';
import 'payment_history_page.dart';
import 'profile_page.dart';
import 'assistant_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_service.dart';

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
    // Pastikan profil user ada di Firestore (auto-provision)
    UserService.ensureUserProfile();
    service = MockParkingService(totalSlots: 55)..start();
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          final offsetAnim =
              Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
                  .animate(animation);
          final fadeAnim = animation;
          return FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(position: offsetAnim, child: child),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(index),
          index: index,
          children: [
            ModernHome(service: service),
            const MapPage(),
            StatsPage(service: service),
          ],
        ),
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
              final slots = snap.data as List<ParkingSlot>;
              final occupiedCount = slots.where((s) => s.occupied).length;
              final emptyCount = slots.length - occupiedCount;
              return Padding(
                padding: const EdgeInsets.all(12), // Dikurangi dari 16 ke 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'lib/img/Logo Nemu.in.png',
                                width: 48,
                                height: 48,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00D4AA),
                                          Color(0xFF00B894)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                        Icons.local_parking_rounded,
                                        color: Colors.white,
                                        size: 28),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'lib/img/Logo Nemu.in 4.png',
                                  height: 15,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      'smartpark',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A1A),
                                        letterSpacing: -0.5,
                                      ),
                                    );
                                  },
                                ),
                                StreamBuilder<User?>(
                                  stream:
                                      FirebaseAuth.instance.authStateChanges(),
                                  builder: (context, snapshot) {
                                    final displayName = snapshot
                                            .data?.displayName ??
                                        snapshot.data?.email?.split('@')[0] ??
                                        'User';
                                    return Row(
                                      children: [
                                        Text(
                                          'Halo, ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          displayName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                        const Text('Admin'),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_none,
                                    color: Color(0xFF616161)),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                    value: 'history',
                                    child: Text('Riwayat Pembayaran')),
                                PopupMenuItem(
                                    value: 'profile', child: Text('Profil')),
                                PopupMenuItem(
                                    value: 'assistant',
                                    child: Text('Asisten AI')),
                                PopupMenuItem(
                                    value: 'demo_pay',
                                    child: Text('Demo Pembayaran')),
                              ],
                              onSelected: (v) async {
                                switch (v) {
                                  case 'history':
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PaymentHistoryPage(),
                                      ),
                                    );
                                    break;
                                  case 'profile':
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProfilePage(),
                                      ),
                                    );
                                    break;
                                  case 'assistant':
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AssistantPage(),
                                      ),
                                    );
                                    break;
                                  case 'demo_pay':
                                    try {
                                      final uid = FirebaseAuth
                                          .instance.currentUser?.uid;
                                      if (uid == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Harap login terlebih dahulu')),
                                        );
                                        break;
                                      }
                                      final payment = PaymentService(
                                          firestore:
                                              FirebaseFirestore.instance);
                                      final history =
                                          await payment.createPayment(
                                        userId: uid,
                                        slotId: 'DEMO',
                                        amount: 5000,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Transaksi dibuat: ${history.id}')),
                                      );
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const PaymentHistoryPage()),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Gagal demo pembayaran: $e')),
                                      );
                                    }
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18), // Dikurangi dari 24 ke 18
                    _BigStatusCard(
                      occupied: occupiedCount,
                      empty: emptyCount,
                      total: slots.length,
                      onHistory: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PaymentHistoryPage()),
                      ),
                      onMap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MapPage()),
                      ),
                    ),
                    const SizedBox(height: 12), // Dikurangi dari 16 ke 12
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.receipt_long,
                            label: 'Riwayat',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const PaymentHistoryPage()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.person,
                            label: 'Profil',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ProfilePage()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Dikurangi dari 14 ke 10
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: slots.length,
                        itemBuilder: (context, i) {
                          final slot = slots[i];
                          return _GridSlotTile(slot: slot, index: i);
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

class _GridSlotTile extends StatelessWidget {
  final ParkingSlot slot;
  final int index;
  const _GridSlotTile({required this.slot, required this.index});

  @override
  Widget build(BuildContext context) {
    final isOccupied = slot.occupied;
    const accent = Color(0xFF00D4AA);
    final numberStyle = GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: isOccupied ? accent : const Color(0xFF1A1A1A),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 420 + (index * 30)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 12),
            child: child!,
          ),
        );
      },
      child: _HoverableCard(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openPayment(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                color: isOccupied ? accent.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isOccupied ? accent.withOpacity(0.25) : Colors.black12,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Status dot di pojok kanan atas
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOccupied ? accent : const Color(0xFF9E9E9E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nomor slot
                  Center(child: Text('${slot.id}', style: numberStyle)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openPayment(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap login terlebih dahulu')),
      );
      return;
    }
    try {
      final payment = PaymentService(firestore: FirebaseFirestore.instance);
      final history = await payment.createPayment(
        userId: uid,
        slotId: slot.id.toString(),
        amount: 5000,
      );
      if (!context.mounted) return;
      const accentPay = Color(0xFF00D4AA);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pembayaran Slot ${slot.id}',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    history.qrPayload ?? 'QR payload tidak tersedia',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accentPay,
                        ),
                        onPressed: () async {
                          await payment.markPaid(history.id);
                          await payment.adjustBalance(uid, -history.amount);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pembayaran ditandai lunas'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Tandai Lunas'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pembayaran: $e')),
      );
    }
  }
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

class _BigStatusCard extends StatelessWidget {
  final int occupied;
  final int empty;
  final int total;
  final VoidCallback onHistory;
  final VoidCallback onMap;
  const _BigStatusCard({
    required this.occupied,
    required this.empty,
    required this.total,
    required this.onHistory,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4AA).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status Parkir',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Live',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statusItem('Terisi', occupied, Icons.local_parking),
              const SizedBox(width: 12),
              _statusItem('Kosong', empty, Icons.check_circle_outline),
              const SizedBox(width: 12),
              _statusItem('Total', total, Icons.grid_view_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.search_rounded,
                  label: 'Cari Slot',
                  onTap: onMap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  onTap: onHistory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: Colors.white.withOpacity(0.8))),
            Text('$value',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF00D4AA), size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00D4AA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _HoverableCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE0F7F4),
                  child: Icon(icon, color: const Color(0xFF00D4AA)),
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Jalankan transisi visual nav bar tanpa menunda perpindahan tab
    widget.onTap(index);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 64, // Dikurangi dari 72 ke 64
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 6), // Dikurangi dari 8 ke 6
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: widget.currentIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _NavItem(
                icon: Icons.location_on_rounded,
                label: 'Map',
                isSelected: widget.currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Stats',
                isSelected: widget.currentIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
            ],
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
    const primaryColor = Color(0xFF00D4AA);
    const selectedBg = Color(0xFFE0F7F4);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4), // Dikurangi dari 6 ke 4
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(2), // Dikurangi dari 4 ke 2
                  child: Icon(
                    icon,
                    color: isSelected ? primaryColor : Colors.black45,
                    size: isSelected ? 22 : 20, // Dikurangi dari 24/22 ke 22/20
                  ),
                ),
                const SizedBox(height: 1), // Dikurangi dari 2 ke 1
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  style: GoogleFonts.poppins(
                    fontSize:
                        isSelected ? 10 : 9, // Dikurangi dari 11/10 ke 10/9
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? primaryColor : Colors.black45,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

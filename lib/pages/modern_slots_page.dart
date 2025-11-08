import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../ui/styles.dart';
import '../services/mock_parking_service.dart';
import '../models/slot.dart';
import '../ui/loading_animation.dart';

/// Modern Slots Page - Standalone page untuk lihat & booking slot parkir
class ModernSlotsPage extends StatefulWidget {
  final MockParkingService service;

  const ModernSlotsPage({
    super.key,
    required this.service,
  });

  @override
  State<ModernSlotsPage> createState() => _ModernSlotsPageState();
}

class _ModernSlotsPageState extends State<ModernSlotsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _filter = 'all'; // all, available, occupied

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder<List<ParkingSlot>>(
          stream: widget.service.slotsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ModernLoadingAnimation(
                type: LoadingType.builtIn,
                size: 150,
                customMessage: 'Memuat slot parkir...',
              );
            }

            final allSlots = snapshot.data!;
            final occupiedCount = allSlots.where((s) => s.occupied).length;
            final availableCount = allSlots.length - occupiedCount;

            // Filter slots
            final filteredSlots = _filter == 'all'
                ? allSlots
                : _filter == 'available'
                    ? allSlots.where((s) => !s.occupied).toList()
                    : allSlots.where((s) => s.occupied).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern Header dengan gradient
                _buildModernHeader(context, availableCount, occupiedCount),

                // Filter chips
                SliverToBoxAdapter(
                  child: _buildFilterSection(),
                ),

                // Slot grid - Sama seperti di Home Page (5 kolom)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildModernSlotTile(
                            filteredSlots[index], index);
                      },
                      childCount: filteredSlots.length,
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, int available, int occupied) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top bar with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Pilih Slot Parkir',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Tersedia',
                        value: available.toString(),
                        color: const Color(0xFF4CAF50),
                        bgColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.cancel_rounded,
                        label: 'Terisi',
                        value: occupied.toString(),
                        color: const Color(0xFFFF5252),
                        bgColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildFilterChip('Semua', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Tersedia', 'available'),
          const SizedBox(width: 8),
          _buildFilterChip('Terisi', 'occupied'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textLight,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildModernSlotTile(ParkingSlot slot, int index) {
    final isOccupied = slot.occupied;
    const accentAvailable = Color(0xFF00D4AA);
    const accentOccupied = Color(0xFFFF6B6B);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: !isOccupied ? () => _showBookingDialog(slot) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              gradient: isOccupied
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentOccupied.withOpacity(0.08),
                        accentOccupied.withOpacity(0.15),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        accentAvailable.withOpacity(0.05),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isOccupied
                      ? accentOccupied.withOpacity(0.12)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: isOccupied ? 12 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isOccupied
                    ? accentOccupied.withOpacity(0.3)
                    : accentAvailable.withOpacity(0.15),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles background
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOccupied
                          ? accentOccupied.withOpacity(0.08)
                          : accentAvailable.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  left: -5,
                  bottom: -5,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOccupied
                          ? accentOccupied.withOpacity(0.06)
                          : accentAvailable.withOpacity(0.06),
                    ),
                  ),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Car/Lock icon
                      Icon(
                        isOccupied
                            ? Icons.lock_rounded
                            : Icons.local_parking_rounded,
                        color: isOccupied ? accentOccupied : accentAvailable,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      // Slot number
                      Text(
                        '${slot.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isOccupied
                              ? accentOccupied
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status indicator
                if (!isOccupied)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentAvailable,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentAvailable.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(ParkingSlot slot) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon dengan Lottie (fallback ke icon)
              SizedBox(
                width: 100,
                height: 100,
                child: Lottie.network(
                  'https://lottie.host/embed/a7d3e5b4-57b4-4a4b-9f4a-3f0c3b5c5c5c/qTbPK9J8F7.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Booking Slot ${slot.id.toString()}?',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Slot ini akan direservasi untuk Anda',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.textLight),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessSnackbar(slot.id.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Book',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String slotId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Slot $slotId berhasil dibooking!',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  static const LatLng center = LatLng(1.484057, 124.834802); // Megamas Mall

  final MapController mapController = MapController();
  late AnimationController _markerController;
  late AnimationController _cardController;
  late AnimationController _loadingController;
  late Animation<double> _markerAnimation;
  late Animation<Offset> _cardAnimation;

  double zoom = 17;
  final Set<String> _filters = {};
  bool _showInfoCard = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _markerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _markerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _markerController, curve: Curves.elasticOut),
    );

    _cardAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    // Simulate loading map tiles
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _markerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _markerController.dispose();
    _cardController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _showParkingInfo() {
    setState(() => _showInfoCard = true);
    _cardController.forward();
  }

  void _hideParkingInfo() {
    _cardController.reverse().then((_) {
      setState(() => _showInfoCard = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Biarkan navbar HomePage tetap terlihat
      child: Stack(
        children: [
          // Main Map fullscreen
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              onTap: (_, __) => _hideParkingInfo(),
            ),
            children: [
              TileLayer(
                // Basemap ringan dan modern dari Carto (light_all)
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'smartpark_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: _showParkingInfo,
                      child: AnimatedBuilder(
                        animation: _markerAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _markerAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF74C0E3),
                                    Color(0xFF1E88E5)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E88E5)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_parking,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ), // Modern Search Bar
          Positioned(
            left: 16,
            right: 16,
            top: 50,
            child: _ModernGlassCard(
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari area parkir…',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF1E88E5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),
          ),

          // Modern Floating Action Buttons
          Positioned(
            right: 20,
            bottom: 110, // Adjusted agar tidak tertutup navbar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModernFAB(
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    // Recenter map to user location
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pusatkan ke lokasi saya',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: const Color(0xFF1E88E5),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  tooltip: 'Pusatkan Lokasi',
                ),
                const SizedBox(height: 12),
                _ModernFAB(
                  icon: Icons.layers_rounded,
                  onPressed: () {
                    // Toggle map layers
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ubah layer peta',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: const Color(0xFF1E88E5),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  tooltip: 'Layer Peta',
                ),
              ],
            ),
          ),

          // Filter Chips
          Positioned(
            left: 16,
            right: 16,
            bottom: 140,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ModernFilterChip(
                    label: 'Terdekat',
                    selected: _filters.contains('nearby'),
                    onSelected: (v) => setState(() {
                      v ? _filters.add('nearby') : _filters.remove('nearby');
                    }),
                  ),
                  const SizedBox(width: 8),
                  _ModernFilterChip(
                    label: 'Harga',
                    selected: _filters.contains('price'),
                    onSelected: (v) => setState(() {
                      v ? _filters.add('price') : _filters.remove('price');
                    }),
                  ),
                  const SizedBox(width: 8),
                  _ModernFilterChip(
                    label: '24 Jam',
                    selected: _filters.contains('24h'),
                    onSelected: (v) => setState(() {
                      v ? _filters.add('24h') : _filters.remove('24h');
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Floating Bottom Info Card
          if (_showInfoCard)
            Positioned(
              left: 16,
              right: 16,
              bottom: 110, // Adjusted untuk navbar yang lebih tinggi
              child: SlideTransition(
                position: _cardAnimation,
                child: _ModernInfoCard(),
              ),
            ),

          // Modern Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: _ModernLoadingOverlay(
                animationController: _loadingController,
              ),
            ),
        ],
      ),
    );
  }
}

class _ModernGlassCard extends StatelessWidget {
  final Widget child;
  const _ModernGlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: BoxDecoration(
          // Gradient-only agar ringan namun tetap modern
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(230, 255, 255, 255),
              Color.fromARGB(230, 248, 250, 252),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _ModernFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1E88E5).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1E88E5)
                  : Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? const Color(0xFF1E88E5) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(240, 255, 255, 255),
            Color.fromARGB(240, 248, 250, 252),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Megamas Mall',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF283D4A))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text('0.8 km',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Buka',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 12),
              Text('Kapasitas 12',
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF74C0E3), Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Navigasi',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Detail',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E88E5))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ModernFAB({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<_ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<_ModernFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {}, // Handled by GestureDetector
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF1E88E5),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Modern Loading Overlay with shimmer effect
class _ModernLoadingOverlay extends StatelessWidget {
  final AnimationController animationController;

  const _ModernLoadingOverlay({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Stack(
        children: [
          // Background shimmer effect
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFE3F2FD).withValues(
                        alpha: 0.3 + (animationController.value * 0.3),
                      ),
                      const Color(0xFFF8F9FA),
                    ],
                    stops: [
                      animationController.value - 0.3,
                      animationController.value,
                      animationController.value + 0.3,
                    ].map((e) => e.clamp(0.0, 1.0)).toList(),
                  ),
                ),
              );
            },
          ),

          // Loading content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated map icon with gradient
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 +
                          (0.1 *
                              (1 -
                                  (animationController.value - 0.5).abs() * 2)),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(
                                const Color(0xFF74C0E3),
                                const Color(0xFF1E88E5),
                                animationController.value,
                              )!,
                              Color.lerp(
                                const Color(0xFF1E88E5),
                                const Color(0xFF74C0E3),
                                animationController.value,
                              )!,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E88E5).withValues(
                                alpha: 0.3 + (animationController.value * 0.2),
                              ),
                              blurRadius: 20 + (animationController.value * 10),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Loading text with fade animation
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.6 +
                          (0.4 *
                              (1 -
                                  (animationController.value - 0.5).abs() * 2)),
                      child: Text(
                        'Memuat Peta...',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E88E5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Animated dots
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final dotValue =
                            ((animationController.value + delay) % 1.0);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              const Color(0xFF1E88E5).withValues(alpha: 0.3),
                              const Color(0xFF1E88E5),
                              dotValue,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Shimmer loading bar
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.3 + (animationController.value * 0.7),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF74C0E3),
                                Color(0xFF1E88E5),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E88E5)
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

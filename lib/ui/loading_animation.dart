import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'styles.dart';

/// Widget loading modern menggunakan Lottie animation
/// Pilihan:
/// 1. Built-in shimmer effect (tidak perlu file eksternal)
/// 2. Lottie dari asset (perlu download file .json)
/// 3. Lottie dari network (online)
class ModernLoadingAnimation extends StatelessWidget {
  final LoadingType type;
  final double size;
  final String? customMessage;

  const ModernLoadingAnimation({
    super.key,
    this.type = LoadingType.builtIn,
    this.size = 200,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: _buildAnimation(),
          ),
          if (customMessage != null) ...[
            const SizedBox(height: 24),
            Text(
              customMessage!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimation() {
    switch (type) {
      case LoadingType.builtIn:
        return _buildModernCircularProgress();
      case LoadingType.lottieAsset:
        return _buildLottieAsset();
      case LoadingType.lottieNetwork:
        return _buildLottieNetwork();
      case LoadingType.parkingCar:
        return _buildParkingAnimation();
    }
  }

  // Modern circular progress dengan gradient effect - STARTUP STYLE
  Widget _buildModernCircularProgress() {
    return _StartupStyleLoader(size: size);
  }

  // Lottie dari file asset (perlu download dulu)
  Widget _buildLottieAsset() {
    return Lottie.asset(
      'lib/animations/loading.json',
      fit: BoxFit.contain,
      // Fallback ke built-in jika file tidak ada
      errorBuilder: (context, error, stackTrace) {
        return _buildModernCircularProgress();
      },
    );
  }

  // Lottie dari internet (tidak perlu download)
  Widget _buildLottieNetwork() {
    return Lottie.network(
      'https://lottie.host/4f00e0e6-2b8c-4c74-bb44-d2efbc3a0e43/pMPq5iA2pv.json',
      fit: BoxFit.contain,
      // Fallback ke built-in jika koneksi gagal
      errorBuilder: (context, error, stackTrace) {
        return _buildModernCircularProgress();
      },
    );
  }

  // Custom parking car animation dengan built-in widgets
  Widget _buildParkingAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Parking slot
            Container(
              width: size * 0.7,
              height: size * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Animated car icon
            Transform.translate(
              offset: Offset(
                (value - 0.5) * size * 0.3,
                0,
              ),
              child: Icon(
                Icons.directions_car,
                size: size * 0.3,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
      onEnd: () {
        // Loop animation
      },
    );
  }
}

enum LoadingType {
  builtIn, // Menggunakan CircularProgressIndicator modern
  lottieAsset, // Menggunakan file Lottie dari asset
  lottieNetwork, // Menggunakan Lottie dari internet
  parkingCar, // Animasi mobil parkir custom
}

/// Full screen loading overlay yang bisa di-dismiss
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final LoadingType loadingType;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingType = LoadingType.builtIn,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: ModernLoadingAnimation(
              type: loadingType,
              customMessage: message ?? 'Loading...',
            ),
          ),
      ],
    );
  }
}

/// Shimmer effect untuk skeleton loading
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.background,
                AppColors.primary.withOpacity(0.3),
                AppColors.background,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Modern Startup-Style Loader - Clean & Minimalist
/// Inspired by: Notion, Linear, Vercel, Stripe loading animations
class _StartupStyleLoader extends StatefulWidget {
  final double size;

  const _StartupStyleLoader({required this.size});

  @override
  State<_StartupStyleLoader> createState() => _StartupStyleLoaderState();
}

class _StartupStyleLoaderState extends State<_StartupStyleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Subtle background pulse
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05),
                ),
              ),
            ),

            // Rotating arc - Startup style
            Transform.rotate(
              angle: _rotationAnimation.value * 6.28319, // 2 * PI
              child: CustomPaint(
                size: Size(widget.size * 0.35, widget.size * 0.35),
                painter: _StartupArcPainter(
                  color: AppColors.primary,
                  progress: _controller.value,
                ),
              ),
            ),

            // Center dot - minimalist
            Container(
              width: widget.size * 0.08,
              height: widget.size * 0.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for startup-style arc
class _StartupArcPainter extends CustomPainter {
  final Color color;
  final double progress;

  _StartupArcPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clean arc - like Linear/Notion
    const startAngle = -1.5708; // -90 degrees (top)
    const sweepAngle = 4.71239; // 270 degrees (3/4 circle)

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw gradient effect on arc
    paint.shader = LinearGradient(
      colors: [
        color.withOpacity(0.3),
        color,
        color.withOpacity(0.3),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_StartupArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

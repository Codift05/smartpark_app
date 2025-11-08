import 'package:flutter/material.dart';
import '../ui/loading_animation.dart';
import '../ui/styles.dart';

/// Halaman DEMO untuk menampilkan berbagai jenis loading animation
/// Akses via: Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingDemoPage()))
class LoadingDemoPage extends StatefulWidget {
  const LoadingDemoPage({super.key});

  @override
  State<LoadingDemoPage> createState() => _LoadingDemoPageState();
}

class _LoadingDemoPageState extends State<LoadingDemoPage> {
  bool _isLoadingOverlay = false;
  bool _isShimmerLoading = false;

  // Simulasi loading data
  Future<void> _simulateLoading() async {
    setState(() => _isLoadingOverlay = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isLoadingOverlay = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Animation Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoadingOverlay,
        loadingType: LoadingType.builtIn,
        message: 'Memuat data parkir...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('✨ Modern Startup-Style Loader (NEW!)'),
              _buildDemoCard(
                child: const ModernLoadingAnimation(
                  type: LoadingType.builtIn,
                  size: 150,
                  customMessage: 'Clean & Minimalist',
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '🎯 Inspired by: Notion, Linear, Vercel, Stripe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('2. Custom Parking Car Animation'),
              _buildDemoCard(
                child: const ModernLoadingAnimation(
                  type: LoadingType.parkingCar,
                  size: 200,
                  customMessage: 'Mencari slot parkir...',
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('3. Lottie dari Internet (Online)'),
              _buildDemoCard(
                child: const ModernLoadingAnimation(
                  type: LoadingType.lottieNetwork,
                  size: 200,
                  customMessage: 'Memuat dari internet...',
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('4. Loading Overlay (Full Screen)'),
              _buildDemoCard(
                child: Column(
                  children: [
                    const Text(
                      'Tekan tombol untuk melihat loading overlay',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _simulateLoading,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Simulate Loading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('5. Shimmer Loading Effect'),
              _buildDemoCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Shimmer: '),
                        Switch(
                          value: _isShimmerLoading,
                          onChanged: (val) {
                            setState(() => _isShimmerLoading = val);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ShimmerLoading(
                      isLoading: _isShimmerLoading,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isShimmerLoading ? 'Loading...' : 'Loaded!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildDemoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cara Menggunakan:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '1. Built-in: Tidak perlu file eksternal, langsung pakai',
          ),
          _buildInstructionItem(
            '2. Parking Car: Animasi custom untuk tema parkir',
          ),
          _buildInstructionItem(
            '3. Lottie Network: Perlu koneksi internet',
          ),
          _buildInstructionItem(
            '4. Lottie Asset: Download file .json dari LottieFiles.com',
          ),
          const SizedBox(height: 12),
          Text(
            '💡 Rekomendasi: Gunakan Built-in atau Lottie Network untuk kemudahan!',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

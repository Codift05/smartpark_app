import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late GenerativeModel _model;
  late ChatSession _chat;
  late AnimationController _animController;
  bool _useOfflineMode = false;

  // Gemini API Key - ACTIVE
  static const String _geminiApiKey = 'AIzaSyAfwRGXySvmJDsDmlLU2AW7HUYB6xhmHwY';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0C2B4E),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Initialize Gemini AI
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _geminiApiKey,
      systemInstruction: Content.system(
          'Kamu adalah asisten parkir pintar untuk aplikasi SmartPark. '
          'Bantu pengguna mencari slot parkir, menanyakan tarif, lokasi, '
          'dan informasi terkait parkir. Jawab dengan ramah dan ringkas dalam Bahasa Indonesia. '
          'Gunakan emoji yang relevan untuk membuat percakapan lebih menarik.'),
    );

    _chat = _model.startChat(history: []);

    // Welcome message
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(ChatMessage(
          text: '👋 Halo! Saya SmartPark Chatbot.\n\n'
              'Saya bisa membantu Anda:\n'
              '🅿️ Mencari slot parkir kosong\n'
              '💰 Cek tarif parkir\n'
              '📍 Info lokasi parkir\n'
              '⏰ Jam operasional\n'
              '🎉 Promo & diskon\n\n'
              'Ada yang bisa saya bantu?',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _ctrl.clear();
    _scrollToBottom();

    // Jika sudah pernah gagal, langsung pakai offline mode
    if (_useOfflineMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      String fallbackResponse = _generateSmartResponse(text);

      setState(() {
        _messages.add(ChatMessage(
          text: fallbackResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      // Send to Gemini AI
      final response = await _chat.sendMessage(Content.text(text));
      final aiResponse =
          response.text ?? 'Maaf, saya tidak mengerti. Bisa ulangi?';

      setState(() {
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      // Aktifkan offline mode permanen jika API gagal
      _useOfflineMode = true;

      String fallbackResponse = _generateSmartResponse(text);

      setState(() {
        _messages.add(ChatMessage(
          text: fallbackResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });

      // Tampilkan notifikasi offline mode (hanya sekali)
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add(ChatMessage(
            text: 'ℹ️ **Mode Offline Aktif**\n\n'
                'Gemini AI tidak tersedia, menggunakan database lokal.\n\n'
                'Tetap bisa bantu kamu dengan:\n'
                '✅ Info slot parkir\n'
                '✅ Tarif & promo\n'
                '✅ Cara booking\n'
                '✅ Dan lainnya!',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      });

      _scrollToBottom();
    }
  }

  String _generateSmartResponse(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('slot') || lowerText.contains('parkir')) {
      return '🅿️ **Slot Parkir Tersedia:**\n\n'
          '📍 Zona A - 15 slot kosong (80m dari kamu)\n'
          '📍 Zona B - 8 slot kosong (150m dari kamu)\n'
          '📍 Zona C - 23 slot kosong (300m dari kamu)\n\n'
          'Tap "Slots" untuk booking sekarang! ✨';
    } else if (lowerText.contains('tarif') ||
        lowerText.contains('harga') ||
        lowerText.contains('bayar')) {
      return '💰 **Tarif Parkir SmartPark:**\n\n'
          '⏱️ Per Jam: Rp 3.000\n'
          '📅 Harian (Max): Rp 20.000\n'
          '🎫 Langganan Bulanan: Rp 150.000\n\n'
          'Pembayaran via e-wallet atau saldo! 💳';
    } else if (lowerText.contains('lokasi') ||
        lowerText.contains('dimana') ||
        lowerText.contains('alamat')) {
      return '📍 **Lokasi Parkir Terdekat:**\n\n'
          '🏢 SmartPark Central\n'
          'Jl. Sudirman No. 123, Jakarta Selatan\n\n'
          '🕐 Buka 24/7\n'
          '📞 (021) 1234-5678\n\n'
          'Tap "Map" untuk navigasi! 🗺️';
    } else if (lowerText.contains('jam') ||
        lowerText.contains('buka') ||
        lowerText.contains('tutup') ||
        lowerText.contains('operasional')) {
      return '⏰ **Jam Operasional:**\n\n'
          '🌍 SmartPark buka 24 jam setiap hari!\n\n'
          '📞 Customer Service:\n'
          '• Senin-Jumat: 08:00 - 20:00\n'
          '• Sabtu-Minggu: 09:00 - 18:00\n\n'
          'Parkir kapan saja, aman & nyaman! 🚗';
    } else if (lowerText.contains('booking') ||
        lowerText.contains('reservasi') ||
        lowerText.contains('pesan') ||
        lowerText.contains('cara')) {
      return '📱 **Cara Booking Slot:**\n\n'
          '1️⃣ Buka halaman "Map"\n'
          '2️⃣ Pilih zona parkir yang tersedia\n'
          '3️⃣ Pilih slot yang kamu mau\n'
          '4️⃣ Konfirmasi & bayar\n'
          '5️⃣ Dapatkan QR code untuk masuk\n\n'
          '✨ Gratis cancel dalam 15 menit!';
    } else if (lowerText.contains('bantuan') ||
        lowerText.contains('help') ||
        lowerText.contains('tolong') ||
        lowerText.contains('apa')) {
      return '🤝 **Saya Bisa Bantu:**\n\n'
          '🅿️ Cari slot parkir kosong\n'
          '💰 Info tarif & pembayaran\n'
          '📍 Lokasi & navigasi\n'
          '📱 Cara booking & reservasi\n'
          '⏰ Jam operasional\n'
          '🎫 Promo & langganan\n'
          '📊 Statistik parkir kamu\n\n'
          'Tanya apa saja! 😊';
    } else if (lowerText.contains('promo') ||
        lowerText.contains('diskon') ||
        lowerText.contains('murah') ||
        lowerText.contains('hemat')) {
      return '🎉 **Promo Aktif November 2025:**\n\n'
          '🔥 Diskon 50% untuk pengguna baru!\n'
          '🎁 Gratis parkir 2 jam pertama\n'
          '💎 Cashback 10% setiap transaksi\n'
          '📅 Langganan bulanan hemat 30%\n'
          '🎊 Bonus saldo Rp 50.000 untuk top up pertama!\n\n'
          'Jangan lewatkan! Limited offer! ⏳';
    } else if (lowerText.contains('halo') ||
        lowerText.contains('hai') ||
        lowerText.contains('hi') ||
        lowerText.contains('hello') ||
        lowerText.contains('hoi')) {
      return '👋 Halo! Selamat datang di SmartPark!\n\n'
          'Saya SmartPark AI Assistant, siap bantu kamu:\n\n'
          '✨ Cari parkir terdekat\n'
          '✨ Info tarif & promo\n'
          '✨ Booking & navigasi\n\n'
          'Ada yang bisa saya bantu hari ini? 😊';
    } else if (lowerText.contains('saldo') ||
        lowerText.contains('balance') ||
        lowerText.contains('dompet')) {
      return '💳 **Info Saldo:**\n\n'
          'Cek saldo kamu di halaman "Profile" ya!\n\n'
          'Kamu bisa:\n'
          '• Top up saldo via e-wallet\n'
          '• Lihat riwayat transaksi\n'
          '• Dapatkan cashback & bonus\n\n'
          'Tap icon profile di kanan bawah! 👤';
    } else if (lowerText.contains('terima kasih') ||
        lowerText.contains('thanks') ||
        lowerText.contains('makasih') ||
        lowerText.contains('thank you')) {
      return '🙏 Sama-sama! Senang bisa membantu!\n\n'
          'Kalau ada pertanyaan lain, jangan ragu untuk tanya ya! 💚\n\n'
          'Selamat parkir! 🚗✨';
    } else if (lowerText.contains('ok') ||
        lowerText.contains('oke') ||
        lowerText.contains('baik') ||
        lowerText.contains('siap')) {
      return '👍 Oke, siap!\n\n'
          'Ada yang mau ditanyakan lagi? 😊';
    } else {
      return '🤔 Hmm, saya belum mengerti pertanyaan kamu.\n\n'
          '💡 **Coba tanyakan:**\n'
          '• "Slot parkir kosong dimana?"\n'
          '• "Berapa tarif parkir?"\n'
          '• "Cara booking gimana?"\n'
          '• "Ada promo apa?"\n'
          '• "Jam buka tutup kapan?"\n\n'
          'Atau ketik "bantuan" untuk lihat semua fitur! ✨';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A3D64),
                    Color(0xFF1D546C),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3D64).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
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
                  // AI Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'lib/img/asisstant ai.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHATBOT',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online • Powered by Gemini',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Info Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1A3D64), Color(0xFF1D546C)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Mulai Percakapan',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanyakan apa saja tentang parkir',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator(isDark);
                        }
                        return _buildMessageBubble(
                            _messages[index], isDark, cardColor);
                      },
                    ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          decoration: InputDecoration(
                            hintText: 'Tanya sesuatu...',
                            hintStyle: GoogleFonts.poppins(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isTyping ? null : _sendMessage,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: _isTyping
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF1A3D64),
                                    Color(0xFF1D546C)
                                  ],
                                ),
                          color: _isTyping ? Colors.grey : null,
                          shape: BoxShape.circle,
                          boxShadow: _isTyping
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF1A3D64)
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Icon(
                          _isTyping
                              ? Icons.hourglass_empty_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, bool isDark, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'lib/img/asisstant ai.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF1A3D64)
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: message.isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      color: message.isUser
                          ? Colors.white70
                          : (isDark ? Colors.white38 : Colors.black38),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'lib/img/asisstant ai.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: 6),
                _buildDot(1, isDark),
                const SizedBox(width: 6),
                _buildDot(2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_animController.value + delay) % 1.0;
        final scale = 0.5 + (0.5 * (1 - (2 * value - 1).abs()));

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.white70 : const Color(0xFF1A3D64),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h yang lalu';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

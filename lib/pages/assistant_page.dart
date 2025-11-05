import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _ctrl = TextEditingController();

  Future<String> _sendToBackend(String text) async {
    // Stub jawaban; produksi: kirim ke Flask /assistant
    await Future.delayed(const Duration(milliseconds: 300));
    if (text.toLowerCase().contains('slot')) {
      return 'Slot kosong terdekat di Zona A, 80m dari lokasi kamu.';
    }
    if (text.toLowerCase().contains('tarif')) {
      return 'Tarif parkir Rp 3.000/jam, maksimal harian Rp 20.000.';
    }
    return 'Saya siap membantu terkait parkir, tanya saya apa saja!';
  }

  void _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': t});
    });
    _ctrl.clear();
    final reply = await _sendToBackend(t);
    setState(() {
      _messages.add({'role': 'assistant', 'text': reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asisten AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF00D4AA) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: GoogleFonts.poppins(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Tanya slot kosong atau tarif…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _send, child: const Text('Kirim')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


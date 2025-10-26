import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String? errorText;
  // Toggle visibilitas password
  bool showPass = false;
  bool showConfirm = false;

  String _toEmail(String input) {
    final v = input.trim();
    if (v.contains('@')) return v; // jika sudah email
    return '$v@smartparkapp.app';
  }

  Future<void> _signUp() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      errorText = null;
    });
    try {
      final email = _toEmail(usernameCtrl.text);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passCtrl.text,
      );
      // Setelah create, Firebase otomatis login → AuthGate akan ke HomePage
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorText = _mapError(e);
      });
    } catch (_) {
      setState(() {
        errorText = 'Terjadi kesalahan. Coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String? _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Username/email sudah dipakai.';
      case 'invalid-email':
        return 'Email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah.';
      default:
        return e.message ?? 'Registrasi gagal.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color tealDark = Color(0xFF00897B);
    const Color teal = Color(0xFF26A69A);
    const Color blue = Color(0xFF1E88E5);
    const Color tealLight = Color(0xFFA7FFEB);
    const Color grayLight = Color(0xFFE5E7EB);
    const Color grayText = Color(0xFF6B7280);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF26A69A), Color(0xFF1E88E5)],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(130),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (errorText != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            errorText!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usernameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Username (atau email)',
                                labelStyle: GoogleFonts.poppins(fontSize: 14),
                                prefixIcon: const Icon(Icons.email),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: grayLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: teal, width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Username wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: passCtrl,
                              obscureText: !showPass,
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
                                labelStyle: GoogleFonts.poppins(fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => showPass = !showPass),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: grayLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: teal, width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Kata sandi wajib diisi';
                                }
                                if (v.length < 6) return 'Minimal 6 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: confirmCtrl,
                              obscureText: !showConfirm,
                              decoration: InputDecoration(
                                labelText: 'Ulangi Kata Sandi',
                                labelStyle: GoogleFonts.poppins(fontSize: 14),
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(showConfirm ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => showConfirm = !showConfirm),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: grayLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: teal, width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (v) {
                                if (v != passCtrl.text) {
                                  return 'Kata sandi tidak sama';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: teal,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                                ),
                                onPressed: loading ? null : _signUp,
                                icon: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.person_add, color: Colors.white),
                                label: const Text('Buat Akun', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah punya akun? ',
                                  style: GoogleFonts.poppins(fontSize: 13, color: grayText),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: teal,
                                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: loading ? null : () => Navigator.pop(context),
                                  child: const Text('Masuk'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

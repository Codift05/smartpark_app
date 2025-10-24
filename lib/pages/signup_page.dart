import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../ui/styles.dart';

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
      if (mounted)
        setState(() {
          loading = false;
        });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorText != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorText!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: usernameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Username (atau email)',
                              prefixIcon: const Icon(Icons.person),
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Username wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passCtrl,
                            obscureText: !showPass,
                            decoration: InputDecoration(
                              labelText: 'Kata Sandi',
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => showPass = !showPass),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Kata sandi wajib diisi';
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
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => showConfirm = !showConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v != passCtrl.text)
                                return 'Kata sandi tidak sama';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: loading ? null : _signUp,
                              icon: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.person_add),
                              label: const Text('Buat Akun'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Sudah punya akun? Masuk'),
                          ),
                        ],
                      ),
                    ),
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

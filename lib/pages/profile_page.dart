import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/payment_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = PaymentService(firestore: FirebaseFirestore.instance);
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Tidak ada user')));
    }
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDoc.snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? {};
          final name = data['name'] as String? ?? (FirebaseAuth.instance.currentUser?.email ?? 'User');
          final avatarUrl = data['avatar_url'] as String?;
          final notif = (data['notif_pref'] ?? true) as bool;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(child: Text(name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600))),
              const SizedBox(height: 24),
              Text('Saldo', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StreamBuilder<int>(
                stream: service.balanceStream(uid),
                builder: (context, balSnap) {
                  final bal = balSnap.data ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rp $bal', style: GoogleFonts.poppins(fontSize: 16)),
                      Row(children: [
                        TextButton(onPressed: () => service.adjustBalance(uid, 10000), child: const Text('Topup 10k')),
                        TextButton(onPressed: () => service.adjustBalance(uid, -5000), child: const Text('Tarik 5k')),
                      ]),
                    ],
                  );
                },
              ),
              const Divider(height: 32),
              Text('Pengaturan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              SwitchListTile(
                title: Text('Notifikasi', style: GoogleFonts.poppins()),
                value: notif,
                onChanged: (v) => userDoc.set({'notif_pref': v}, SetOptions(merge: true)),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Nama'),
                controller: TextEditingController(text: name),
                onSubmitted: (v) => userDoc.set({'name': v}, SetOptions(merge: true)),
              ),
              const SizedBox(height: 24),
              Text('Avatar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              Text('Unggah avatar belum diaktifkan (butuh firebase_storage).', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
            ],
          );
        },
      ),
    );
  }
}
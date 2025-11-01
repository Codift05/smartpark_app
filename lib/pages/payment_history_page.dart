import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/payment_service.dart';
import '../models/payment.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = PaymentService(firestore: FirebaseFirestore.instance);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text('Tidak ada user'))
          : StreamBuilder<List<PaymentHistory>>(
              stream: service.historyStream(uid),
              builder: (context, snap) {
                final data = snap.data;
                if (data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (data.isEmpty) {
                  return Center(
                    child: Text('Belum ada pembayaran', style: GoogleFonts.poppins()),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = data[i];
                    final statusColor = p.status == 'Paid'
                        ? Colors.green
                        : (p.status == 'Failed' ? Colors.red : Colors.orange);
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text('Slot: ${p.slotId}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'Rp ${p.amount} • ${p.timestamp}' + (p.qrPayload != null ? '\n${p.qrPayload}' : ''),
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        trailing: Chip(
                          label: Text(p.status),
                          backgroundColor: statusColor.withOpacity(0.12),
                          labelStyle: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
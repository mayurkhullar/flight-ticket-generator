import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/ticket_model.dart';
import '../../theme/app_config.dart';
import '../../utils/pdf_generator.dart';
import '../create_ticket/create_ticket_view.dart';

class TicketHistoryView extends StatelessWidget {
  const TicketHistoryView({super.key});

  Future<void> _deleteTicket(String docId) async {
    print('🗑 Deleting ticket $docId');
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(docId)
          .delete();
      print('✅ Ticket deleted');
      Get.snackbar('Deleted', 'Ticket has been removed');
    } catch (e) {
      print('❌ Failed to delete ticket: $e');
      Get.snackbar('Error', 'Failed to delete ticket');
    }
  }

  Future<void> _exportPdf(TicketModel ticket) async {
    print('📤 Exporting ticket ${ticket.pnr}');
    try {
      final file = await PdfGenerator.generateTicketPdf(ticket);
      print('✅ PDF exported to ${file.path}');
      Get.snackbar(
        'PDF Exported',
        'Saved to: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Failed to export PDF: $e');
      Get.snackbar('Error', 'Failed to export PDF');
    }
  }

  void _editTicket(String docId, TicketModel ticket) {
    print('✏️ Editing ticket $docId');
    Get.to(() => CreateTicketView(existingTicket: ticket, docId: docId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text("Ticket History"),
        backgroundColor: AppConfig.surface,
        foregroundColor: AppConfig.textMain,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('tickets')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No tickets found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final ticket = TicketModel.fromMap(
                doc.data() as Map<String, dynamic>,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('PNR: ${ticket.pnr}'),
                  subtitle: Text(
                    '${ticket.airlineName} | ${ticket.fromAirport} → ${ticket.toAirport}\n'
                    'Date: ${ticket.date.day}/${ticket.date.month}/${ticket.date.year}',
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () => _exportPdf(ticket),
                        tooltip: "Export PDF",
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTicket(doc.id, ticket),
                        tooltip: "Edit",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTicket(doc.id),
                        tooltip: "Delete",
                      ),
                    ],
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

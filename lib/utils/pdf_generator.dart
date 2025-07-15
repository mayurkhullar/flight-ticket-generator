import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/ticket_model.dart';

class PdfGenerator {
  static Future<File> generateTicketPdf(TicketModel ticket) async {
    print('🖨️ Generating detailed ticket PDF');
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final logoImage = await _loadAirlineLogoFromFirebase(ticket.airlineCode);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Center(child: pw.Image(logoImage, height: 60)),
              pw.SizedBox(height: 20),
              pw.Text(
                'PNR: ${ticket.pnr}',
                style: pw.TextStyle(font: ttf, fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Airline: ${ticket.airlineName} (${ticket.flightNumber})',
                style: pw.TextStyle(font: ttf),
              ),
              pw.Text(
                'From: ${ticket.fromAirport} (${ticket.departureTime})',
                style: pw.TextStyle(font: ttf),
              ),
              pw.Text(
                'To: ${ticket.toAirport} (${ticket.arrivalTime})',
                style: pw.TextStyle(font: ttf),
              ),

              if (ticket.terminal.isNotEmpty)
                pw.Text(
                  'Terminal: ${ticket.terminal}',
                  style: pw.TextStyle(font: ttf),
                ),

              pw.SizedBox(height: 12),
              if (ticket.stopovers.isNotEmpty) ...[
                pw.Text(
                  'Stopovers:',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 6),
                pw.ListView.builder(
                  itemCount: ticket.stopovers.length,
                  itemBuilder: (ctx, index) {
                    final stop = ticket.stopovers[index];
                    return pw.Text(
                      '${index + 1}. ${stop['airport']}${stop['time']?.isNotEmpty == true ? " (${stop['time']})" : ""}',
                      style: pw.TextStyle(font: ttf),
                    );
                  },
                ),
                pw.SizedBox(height: 12),
              ],

              pw.Text(
                'Passengers:',
                style: pw.TextStyle(font: ttf, fontSize: 16),
              ),
              pw.SizedBox(height: 6),
              pw.ListView.builder(
                itemCount: ticket.passengers.length,
                itemBuilder: (ctx, index) {
                  return pw.Text(
                    '${index + 1}. ${ticket.passengers[index]}',
                    style: pw.TextStyle(font: ttf),
                  );
                },
              ),

              pw.SizedBox(height: 20),
              if (ticket.notes != null && ticket.notes!.isNotEmpty)
                pw.Text(
                  'Notes: ${ticket.notes!}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
            ],
          );
        },
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/ticket_${ticket.pnr}.pdf');
      await file.writeAsBytes(await pdf.save());
      print('✅ PDF saved at ${file.path}');
      return file;
    } catch (e) {
      print('❌ Failed to save PDF: $e');
      rethrow;
    }
  }

  static Future<pw.ImageProvider?> _loadAirlineLogoFromFirebase(
    String airlineCode,
  ) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'airline_logos/$airlineCode.png',
      );
      final bytes = await ref.getData(2 * 1024 * 1024); // Max 2MB
      if (bytes != null) {
        return pw.MemoryImage(Uint8List.fromList(bytes));
      }
    } catch (e) {
      // ignore error or log
      print('Failed to load airline logo: $e');
    }
    return null;
  }
}

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFService {
  static Future<File> generateTicketPDF({
    required String pnr,
    required String airline,
    required String flightNumber,
    required String from,
    required String to,
    required String date,
    required String departure,
    required String arrival,
    required List<String> passengers,
  }) async {
    print('🖨️ Generating simple ticket PDF');
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Flight Ticket',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('PNR: $pnr', style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 16),

                  pw.Text('Airline: $airline'),
                  pw.Text('Flight No: $flightNumber'),
                  pw.Text('From: $from'),
                  pw.Text('To: $to'),
                  pw.Text('Date: $date'),
                  pw.Text('Departure: $departure'),
                  pw.Text('Arrival: $arrival'),
                  pw.SizedBox(height: 16),

                  pw.Text(
                    'Passengers:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children:
                        passengers.map((name) => pw.Text('• $name')).toList(),
                  ),
                ],
              ),
            ),
      ),
    );
    try {
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/ticket_$pnr.pdf');
      await file.writeAsBytes(await pdf.save());
      print('✅ PDF saved at ${file.path}');
      return file;
    } catch (e) {
      print('❌ Failed to generate PDF: $e');
      rethrow;
    }
  }
}

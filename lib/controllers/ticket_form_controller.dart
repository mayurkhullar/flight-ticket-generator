import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/ticket_model.dart';
import '../utils/pdf_generator.dart';
import 'saved_flights_controller.dart';

class TicketFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final airlineName = TextEditingController();
  final airlineCode = TextEditingController();
  final flightNumber = TextEditingController();
  final fromAirport = TextEditingController();
  final toAirport = TextEditingController();
  final terminal = TextEditingController();
  final departureTime = TextEditingController();
  final arrivalTime = TextEditingController();
  final notes = TextEditingController();

  final RxList<TextEditingController> passengers =
      <TextEditingController>[].obs;
  final RxList<Map<String, TextEditingController>> stopovers =
      <Map<String, TextEditingController>>[].obs;

  final travelDate = DateTime.now().obs;
  final generatedFile = Rx<File?>(null);

  String? existingDocId;
  TicketModel? existingTicket;

  void addPassenger() {
    passengers.add(TextEditingController());
  }

  void removePassenger(int index) {
    passengers.removeAt(index);
  }

  void addStopover() {
    stopovers.add({
      'airport': TextEditingController(),
      'time': TextEditingController(),
    });
  }

  void removeStopover(int index) {
    stopovers.removeAt(index);
  }

  bool isValidTime(String value) {
    final regex = RegExp(r'^\d{2}:\d{2}$');
    return regex.hasMatch(value);
  }

  bool isValidIATACode(String value) {
    final regex = RegExp(r'^[A-Z0-9]{2,4}$');
    return regex.hasMatch(value);
  }

  TicketModel toTicketModel() {
    return TicketModel(
      pnr: existingTicket?.pnr ?? _generatePNR(),
      airlineName: airlineName.text.trim(),
      airlineCode: airlineCode.text.trim(),
      flightNumber: flightNumber.text.trim(),
      fromAirport: fromAirport.text.trim(),
      toAirport: toAirport.text.trim(),
      departureTime: departureTime.text.trim(),
      arrivalTime: arrivalTime.text.trim(),
      terminal: terminal.text.trim(),
      passengers:
          passengers
              .map((ctrl) => ctrl.text.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      stopovers:
          stopovers
              .map(
                (map) => {
                  'airport': map['airport']!.text.trim(),
                  'time': map['time']!.text.trim(),
                },
              )
              .where((e) => e['airport']!.isNotEmpty)
              .toList(),
      notes: notes.text.trim(),
      date: travelDate.value,
      createdAt: existingTicket?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    print('📝 Submitting ticket');
    try {
      final ticket = toTicketModel();
      final file = await PdfGenerator.generateTicketPdf(ticket);

      final data = ticket.toMap();
      if (existingDocId != null) {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(existingDocId)
            .set(data);
      } else {
        await FirebaseFirestore.instance.collection('tickets').add(data);
      }

      // Learn from this ticket for future suggestions
      if (existingDocId == null) { // Only learn from new tickets
        try {
          final savedFlightsController = Get.find<SavedFlightsController>();
          await savedFlightsController.learnFromTicket(ticket);
        } catch (e) {
          // SavedFlightsController might not be initialized, that's okay
          print('ℹ️ SavedFlightsController not found, skipping learning');
        }
      }

      generatedFile.value = file;
      print('✅ Ticket saved and PDF generated at ${file.path}');
      Get.snackbar('Success', 'Ticket saved and PDF generated');
    } catch (e) {
      print('❌ Ticket submit failed: $e');
      Get.snackbar('Error', 'Failed to save ticket');
    }
  }

  String _generatePNR() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  void loadExisting(TicketModel ticket, String docId) {
    existingTicket = ticket;
    existingDocId = docId;

    airlineName.text = ticket.airlineName;
    airlineCode.text = ticket.airlineCode;
    flightNumber.text = ticket.flightNumber;
    fromAirport.text = ticket.fromAirport;
    toAirport.text = ticket.toAirport;
    terminal.text = ticket.terminal ?? '';
    departureTime.text = ticket.departureTime;
    arrivalTime.text = ticket.arrivalTime;
    notes.text = ticket.notes ?? '';
    travelDate.value = ticket.date;

    passengers.clear();
    if (ticket.passengers.isNotEmpty) {
      passengers.addAll(
        ticket.passengers.map((p) => TextEditingController(text: p)),
      );
    } else {
      addPassenger();
    }

    stopovers.clear();
    stopovers.addAll(
      ticket.stopovers.map((s) {
        return {
          'airport': TextEditingController(text: s['airport'] ?? ''),
          'time': TextEditingController(text: s['time'] ?? ''),
        };
      }),
    );
  }

  @override
  void onInit() {
    super.onInit();
    addPassenger();
  }

  @override
  void onClose() {
    airlineName.dispose();
    airlineCode.dispose();
    flightNumber.dispose();
    fromAirport.dispose();
    toAirport.dispose();
    terminal.dispose();
    departureTime.dispose();
    arrivalTime.dispose();
    notes.dispose();
    for (var p in passengers) {
      p.dispose();
    }
    for (var s in stopovers) {
      s['airport']?.dispose();
      s['time']?.dispose();
    }
    super.onClose();
  }
}

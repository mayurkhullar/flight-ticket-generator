import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/ticket_model.dart';
import '../../utils/pdf_generator.dart';

class CreateTicketView extends StatefulWidget {
  final TicketModel? existingTicket;
  final String? docId;

  const CreateTicketView({super.key, this.existingTicket, this.docId});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();

  final airlineController = TextEditingController();
  final flightNumberController = TextEditingController();
  final airlineCodeController = TextEditingController();
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final terminalController = TextEditingController();
  final departureTimeController = TextEditingController();
  final arrivalTimeController = TextEditingController();
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final List<TextEditingController> passengerControllers = [];
  final List<MapEntry<TextEditingController, TextEditingController>>
  stopoverControllers = [];

  @override
  void initState() {
    super.initState();
    passengerControllers.add(TextEditingController());
    stopoverControllers.add(
      MapEntry(TextEditingController(), TextEditingController()),
    );

    if (widget.existingTicket != null) {
      final t = widget.existingTicket!;
      airlineController.text = t.airlineName;
      flightNumberController.text = t.flightNumber;
      airlineCodeController.text = t.airlineCode;
      originController.text = t.fromAirport;
      destinationController.text = t.toAirport;
      terminalController.text = t.terminal ?? '';
      departureTimeController.text = t.departureTime;
      arrivalTimeController.text = t.arrivalTime;
      selectedDate = t.date;
      notesController.text = t.notes ?? '';

      passengerControllers.clear();
      for (final p in t.passengers) {
        passengerControllers.add(TextEditingController(text: p));
      }

      stopoverControllers.clear();
      for (final s in t.stopovers) {
        stopoverControllers.add(
          MapEntry(
            TextEditingController(text: s['airport'] ?? ''),
            TextEditingController(text: s['time'] ?? ''),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    airlineController.dispose();
    flightNumberController.dispose();
    airlineCodeController.dispose();
    originController.dispose();
    destinationController.dispose();
    terminalController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    notesController.dispose();
    for (var c in passengerControllers) {
      c.dispose();
    }
    for (var c in stopoverControllers) {
      c.key.dispose();
      c.value.dispose();
    }
    super.dispose();
  }

  void _addPassenger() {
    setState(() => passengerControllers.add(TextEditingController()));
  }

  void _removePassenger(int index) {
    setState(() {
      passengerControllers[index].dispose();
      passengerControllers.removeAt(index);
    });
  }

  void _addStopover() {
    setState(() {
      stopoverControllers.add(
        MapEntry(TextEditingController(), TextEditingController()),
      );
    });
  }

  void _removeStopover(int index) {
    setState(() {
      stopoverControllers[index].key.dispose();
      stopoverControllers[index].value.dispose();
      stopoverControllers.removeAt(index);
    });
  }

  String _generatePNR() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final passengers =
        passengerControllers
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final stopovers =
        stopoverControllers
            .map(
              (entry) => {
                'airport': entry.key.text.trim(),
                'time': entry.value.text.trim(),
              },
            )
            .where((s) => s['airport']!.isNotEmpty)
            .toList();

    final ticket = TicketModel(
      pnr: widget.existingTicket?.pnr ?? _generatePNR(),
      airlineName: airlineController.text.trim(),
      airlineCode: airlineCodeController.text.trim(),
      flightNumber: flightNumberController.text.trim(),
      fromAirport: originController.text.trim(),
      toAirport: destinationController.text.trim(),
      terminal: terminalController.text.trim(),
      departureTime: departureTimeController.text.trim(),
      arrivalTime: arrivalTimeController.text.trim(),
      passengers: passengers,
      stopovers: stopovers,
      notes: notesController.text.trim(),
      date: selectedDate,
      createdAt: widget.existingTicket?.createdAt ?? DateTime.now(),
    );
    print('📝 Submitting ticket form');
    try {
      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(widget.docId)
            .set(ticket.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('tickets')
            .add(ticket.toMap());
      }

      final file = await PdfGenerator.generateTicketPdf(ticket);
      print('✅ Ticket saved and PDF at \${file.path}');
      Get.snackbar('Success', 'PDF saved to ${file.path}');
      Navigator.pop(context);
    } catch (e) {
      print('❌ Ticket creation failed: $e');
      Get.snackbar('Error', 'Failed to save ticket');
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTicket == null ? 'Create New Ticket' : 'Edit Ticket',
        ),
        backgroundColor: Colors.blueGrey.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(airlineController, 'Airline Name'),
              _buildTextField(airlineCodeController, 'Airline Code (IATA)'),
              _buildTextField(flightNumberController, 'Flight Number'),
              _buildTextField(originController, 'From (Origin Airport)'),
              _buildTextField(
                destinationController,
                'To (Destination Airport)',
              ),
              _buildTextField(terminalController, 'Terminal (optional)'),
              _buildTextField(departureTimeController, 'Departure Time (24hr)'),
              _buildTextField(arrivalTimeController, 'Arrival Time (24hr)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Travel Date: "),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Passengers",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...passengerControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final ctrl = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(ctrl, 'Passenger ${i + 1}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          passengerControllers.length > 1
                              ? () => _removePassenger(i)
                              : null,
                    ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addPassenger,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Passenger'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Stopovers",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stopoverControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final airportCtrl = entry.value.key;
                final timeCtrl = entry.value.value;
                return Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        airportCtrl,
                        'Stopover ${i + 1} Airport',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(timeCtrl, 'Time (optional)'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeStopover(i),
                    ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addStopover,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Stopover'),
                ),
              ),
              _buildTextField(notesController, 'Notes (optional)', lines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Generate Ticket PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

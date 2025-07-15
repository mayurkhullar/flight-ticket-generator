import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/saved_flight_model.dart';

class EditFlightDialog extends StatefulWidget {
  final SavedFlight flight;

  const EditFlightDialog({super.key, required this.flight});

  @override
  State<EditFlightDialog> createState() => _EditFlightDialogState();
}

class _EditFlightDialogState extends State<EditFlightDialog> {
  final _formKey = GlobalKey<FormState>();
  late String airline;
  late String airlineCode;
  late String flightNumber;
  late String from;
  late String to;
  late String departureTime;
  late String arrivalTime;
  late String terminal;

  @override
  void initState() {
    super.initState();
    airline = widget.flight.airline;
    airlineCode = widget.flight.airlineCode;
    flightNumber = widget.flight.flightNumber;
    from = widget.flight.from;
    to = widget.flight.to;
    departureTime = widget.flight.departureTime;
    arrivalTime = widget.flight.arrivalTime;
    terminal = widget.flight.terminal;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('💾 Updating flight ${widget.flight.id}');
      try {
        final newFlightKey = '${airlineCode}_${flightNumber}_${from}_$to';
        
        await FirebaseFirestore.instance
            .collection('saved_flights')
            .doc(widget.flight.id)
            .update({
              'airline': airline,
              'airlineCode': airlineCode,
              'flightNumber': flightNumber,
              'from': from,
              'to': to,
              'departureTime': departureTime,
              'arrivalTime': arrivalTime,
              'terminal': terminal,
              'flightKey': newFlightKey,
            });
        Get.back();
        print('✅ Flight updated');
        Get.snackbar('Updated', 'Flight details updated');
      } catch (e) {
        print('❌ Failed to update flight: $e');
        Get.snackbar('Error', 'Failed to update flight');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Flight'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(
                label: 'Airline Name',
                initial: airline,
                onChanged: (val) => airline = val,
              ),
              _buildField(
                label: 'Airline Code',
                initial: airlineCode,
                onChanged: (val) => airlineCode = val,
              ),
              _buildField(
                label: 'Flight Number',
                initial: flightNumber,
                onChanged: (val) => flightNumber = val,
              ),
              _buildField(
                label: 'From Airport',
                initial: from,
                onChanged: (val) => from = val,
              ),
              _buildField(
                label: 'To Airport',
                initial: to,
                onChanged: (val) => to = val,
              ),
              _buildField(
                label: 'Departure Time (HH:mm)',
                initial: departureTime,
                onChanged: (val) => departureTime = val,
              ),
              _buildField(
                label: 'Arrival Time (HH:mm)',
                initial: arrivalTime,
                onChanged: (val) => arrivalTime = val,
              ),
              _buildField(
                label: 'Terminal (Optional)',
                initial: terminal,
                onChanged: (val) => terminal = val,
                required: false,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String initial,
    required Function(String) onChanged,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initial,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => required && (val == null || val.isEmpty) ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }
}

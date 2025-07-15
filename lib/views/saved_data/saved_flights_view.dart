import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/saved_flight_model.dart';
import '../../theme/app_config.dart';
import 'edit_flight_dialog.dart';

class SavedFlightsView extends StatelessWidget {
  const SavedFlightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final flightsRef = FirebaseFirestore.instance.collection('saved_flights');

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Saved Flights'),
        backgroundColor: AppConfig.surface,
        foregroundColor: AppConfig.textMain,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: flightsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No flights saved.'));
          }

          final flights =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return SavedFlight.fromMap(data, doc.id);
              }).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: flights.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final flight = flights[index];
              return _FlightCard(
                flight: flight,
                onEdit: () => _showEditDialog(context, flight),
                onDelete: () => _deleteFlight(flight.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, FlightModel flight) {
    showDialog(
      context: context,
      builder: (_) => EditFlightDialog(flight: flight),
    );
  }

  Future<void> _deleteFlight(String id) async {
    print('🗑 Deleting flight $id');
    try {
      await FirebaseFirestore.instance
          .collection('saved_flights')
          .doc(id)
          .delete();
      print('✅ Flight deleted');
      Get.snackbar('Deleted', 'Flight entry deleted');
    } catch (e) {
      print('❌ Failed to delete flight: $e');
      Get.snackbar('Error', 'Failed to delete flight');
    }
  }
}

class _FlightCard extends StatelessWidget {
  final SavedFlight flight;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FlightCard({
    required this.flight,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConfig.elevation,
      color: AppConfig.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        side: BorderSide(color: AppConfig.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(flight.airlineName, style: AppConfig.heading),
            const SizedBox(height: 6),
            Text('Flight No: ${flight.flightNumber}', style: AppConfig.body),
            const SizedBox(height: 6),
            Text(
              'From: ${flight.from} (${flight.departureTime})',
              style: AppConfig.body,
            ),
            const SizedBox(height: 6),
            Text(
              'To: ${flight.to} (${flight.arrivalTime})',
              style: AppConfig.body,
            ),
            if (flight.terminal.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Terminal: ${flight.terminal}',
                style: AppConfig.body,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppConfig.danger,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

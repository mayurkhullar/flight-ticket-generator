import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/saved_flight_model.dart';
import '../models/ticket_model.dart';

class SavedFlightsController extends GetxController {
  final flights = <SavedFlight>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    print('📡 Fetching saved flights');
    isLoading.value = true;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('saved_flights').get();
      final data =
          snapshot.docs.map((doc) {
            return SavedFlight.fromMap(doc.data(), doc.id);
          }).toList();
      flights.assignAll(data);
      print('✅ Fetched ${data.length} flights');
    } catch (e) {
      print('❌ Failed to fetch flights: $e');
    }
    isLoading.value = false;
  }

  /// Save flight data for learning when user creates a ticket
  Future<void> learnFromTicket(TicketModel ticket) async {
    print('🧠 Learning flight data from ticket');
    try {
      final flightKey = '${ticket.airlineCode}_${ticket.flightNumber}_${ticket.fromAirport}_${ticket.toAirport}';
      
      // Check if this flight combo already exists
      final existing = await FirebaseFirestore.instance
          .collection('saved_flights')
          .where('flightKey', isEqualTo: flightKey)
          .get();

      if (existing.docs.isEmpty) {
        // Save new flight data
        await FirebaseFirestore.instance.collection('saved_flights').add({
          'flightKey': flightKey,
          'airline': ticket.airlineName,
          'airlineCode': ticket.airlineCode,
          'flightNumber': ticket.flightNumber,
          'from': ticket.fromAirport,
          'to': ticket.toAirport,
          'departureTime': ticket.departureTime,
          'arrivalTime': ticket.arrivalTime,
          'terminal': ticket.terminal,
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('✅ Learned new flight data: $flightKey');
        fetchFlights(); // Refresh the list
      }
    } catch (e) {
      print('❌ Failed to learn flight data: $e');
    }
  }

  /// Get flight suggestions for autocomplete
  List<SavedFlight> getFlightSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return flights.where((flight) {
      return flight.airline.toLowerCase().contains(lowerQuery) ||
          flight.flightNumber.toLowerCase().contains(lowerQuery) ||
          flight.from.toLowerCase().contains(lowerQuery) ||
          flight.to.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

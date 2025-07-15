class FlightModel {
  final String id;
  final String airlineName;
  final String flightNumber;
  final String departureAirport;
  final String departureTime;
  final String arrivalAirport;
  final String arrivalTime;

  FlightModel({
    required this.id,
    required this.airlineName,
    required this.flightNumber,
    required this.departureAirport,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalTime,
  });

  factory FlightModel.fromMap(Map<String, dynamic> map, String id) {
    return FlightModel(
      id: id,
      airlineName: map['airlineName'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      departureAirport: map['departureAirport'] ?? '',
      departureTime: map['departureTime'] ?? '',
      arrivalAirport: map['arrivalAirport'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'airlineName': airlineName,
      'flightNumber': flightNumber,
      'departureAirport': departureAirport,
      'departureTime': departureTime,
      'arrivalAirport': arrivalAirport,
      'arrivalTime': arrivalTime,
    };
  }
}

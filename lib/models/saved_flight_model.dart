class SavedFlight {
  final String id;
  final String airline;
  final String airlineCode;
  final String flightNumber;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String terminal;
  final String flightKey;

  SavedFlight({
    required this.id,
    required this.airline,
    required this.airlineCode,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.terminal,
    required this.flightKey,
  });

  factory SavedFlight.fromMap(Map<String, dynamic> map, String id) {
    return SavedFlight(
      id: id,
      airline: map['airline'] ?? '',
      airlineCode: map['airlineCode'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      terminal: map['terminal'] ?? '',
      flightKey: map['flightKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'airline': airline,
      'airlineCode': airlineCode,
      'flightNumber': flightNumber,
      'from': from,
      'to': to,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'terminal': terminal,
      'flightKey': flightKey,
    };
  }
}

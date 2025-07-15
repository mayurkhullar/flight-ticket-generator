class TicketModel {
  final String pnr;
  final String airlineName;
  final String airlineCode;
  final String flightNumber;
  final String fromAirport;
  final String toAirport;
  final String terminal;
  final String departureTime;
  final String arrivalTime;
  final List<String> passengers;
  final List<Map<String, String>> stopovers;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  TicketModel({
    required this.pnr,
    required this.airlineName,
    required this.airlineCode,
    required this.flightNumber,
    required this.fromAirport,
    required this.toAirport,
    required this.terminal,
    required this.departureTime,
    required this.arrivalTime,
    required this.passengers,
    required this.stopovers,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'pnr': pnr,
      'airlineName': airlineName,
      'airlineCode': airlineCode,
      'flightNumber': flightNumber,
      'fromAirport': fromAirport,
      'toAirport': toAirport,
      'terminal': terminal,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'passengers': passengers,
      'stopovers': stopovers,
      'notes': notes,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      pnr: map['pnr'] ?? '',
      airlineName: map['airlineName'] ?? '',
      airlineCode: map['airlineCode'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      fromAirport: map['fromAirport'] ?? '',
      toAirport: map['toAirport'] ?? '',
      terminal: map['terminal'] ?? '',
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      passengers: List<String>.from(map['passengers'] ?? []),
      stopovers: List<Map<String, String>>.from(
        (map['stopovers'] ?? []).map<Map<String, String>>(
          (item) => Map<String, String>.from(item),
        ),
      ),
      notes: map['notes'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

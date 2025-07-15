import 'package:firebase_core/firebase_core.dart';
import 'package:flight_tickets/views/saved_data/saved_flights_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'theme/app_config.dart';
import 'views/create_ticket/create_ticket_view.dart';
import 'views/home_view.dart';
import 'views/saved_data/flight_assets_view.dart';
import 'views/tickets/ticket_history_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase init failed: $e");
  }

  runApp(const FlightTicketApp());
}

class FlightTicketApp extends StatelessWidget {
  const FlightTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      routingCallback: (routing) {
        if (routing != null) {
          print('➡️ route change: ${routing.current}');
        }
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppConfig.backgroundColor,
        primaryColor: AppConfig.primaryAccent,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppConfig.primaryAccent,
          secondary: AppConfig.primaryAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConfig.primaryAccent,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppConfig.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppConfig.primaryAccent, width: 1.5),
          ),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeView()),
        GetPage(name: '/create-ticket', page: () => const CreateTicketView()),
        GetPage(name: '/saved-flights', page: () => const SavedFlightsView()),
        GetPage(name: '/flight-assets', page: () => const FlightAssetsView()),
        GetPage(name: '/ticket-history', page: () => const TicketHistoryView()),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Ticket Generator'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              title: '✈️ Create New Ticket',
              onTap: () => Get.toNamed('/create-ticket'),
            ),
            const SizedBox(height: 20),
            _buildButton(
              title: '🧾 View Ticket History',
              onTap: () => Get.toNamed('/ticket-history'),
            ),
            const SizedBox(height: 20),
            _buildButton(
              title: '🗂 Manage Saved Flights & Logos',
              onTap: () => Get.toNamed('/flight-assets'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required String title, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white, // <-- Ensures white text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

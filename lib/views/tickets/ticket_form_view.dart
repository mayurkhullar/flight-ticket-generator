import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/ticket_form_controller.dart';
import '../../theme/app_config.dart';

class TicketFormView extends StatelessWidget {
  const TicketFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TicketFormController());

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text("Create Ticket"),
        backgroundColor: AppConfig.surface,
        foregroundColor: AppConfig.textMain,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _input(controller.airlineName, "Airline Name"),
                _input(
                  controller.airlineCode,
                  "Airline Code (for logo)",
                  validator:
                      (val) =>
                          controller.isValidIATACode(val ?? '')
                              ? null
                              : "Invalid Code",
                ),
                _input(controller.flightNumber, "Flight Number"),
                _input(controller.fromAirport, "From Airport"),
                _input(controller.toAirport, "To Airport"),
                _input(controller.terminal, "Terminal (optional)"),
                _input(
                  controller.departureTime,
                  "Departure Time (HH:MM)",
                  validator:
                      (val) =>
                          controller.isValidTime(val ?? '')
                              ? null
                              : "Invalid time",
                ),
                _input(
                  controller.arrivalTime,
                  "Arrival Time (HH:MM)",
                  validator:
                      (val) =>
                          controller.isValidTime(val ?? '')
                              ? null
                              : "Invalid time",
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "Travel Date:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.travelDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.travelDate.value = picked;
                        }
                      },
                      child: Text(
                        "${controller.travelDate.value.day}/${controller.travelDate.value.month}/${controller.travelDate.value.year}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Passengers",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Column(
                  children: List.generate(controller.passengers.length, (i) {
                    return Row(
                      children: [
                        Expanded(
                          child: _input(
                            controller.passengers[i],
                            "Passenger ${i + 1}",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed:
                              controller.passengers.length > 1
                                  ? () => controller.removePassenger(i)
                                  : null,
                        ),
                      ],
                    );
                  }),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: controller.addPassenger,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Passenger"),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Stopovers",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Column(
                  children: List.generate(controller.stopovers.length, (i) {
                    final stop = controller.stopovers[i];
                    return Row(
                      children: [
                        Expanded(
                          child: _input(stop['airport']!, "Stopover Airport"),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _input(
                            stop['time']!,
                            "Stopover Time (optional)",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => controller.removeStopover(i),
                        ),
                      ],
                    );
                  }),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: controller.addStopover,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Stopover"),
                  ),
                ),
                const SizedBox(height: 24),
                _input(controller.notes, "Notes (optional)", lines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.submit,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Generate Ticket PDF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.generatedFile.value != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      final file = controller.generatedFile.value!;
                      Get.snackbar(
                        "PDF ready",
                        "Saved at ${file.path}",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      // Here you could launch or share the file
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Download PDF Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    int lines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        validator:
            validator ??
            (value) {
              if (label.contains("optional")) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            borderSide: BorderSide(color: AppConfig.borderColor),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_config.dart';

class FlightAssetsView extends StatefulWidget {
  const FlightAssetsView({super.key});

  @override
  State<FlightAssetsView> createState() => _FlightAssetsViewState();
}

class _FlightAssetsViewState extends State<FlightAssetsView> {
  final _airlineCodeCtrl = TextEditingController();
  final _airlineNameCtrl = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickAndUploadLogo() async {
    print('⬆️ Uploading airline logo');
    final code = _airlineCodeCtrl.text.trim().toLowerCase();
    final name = _airlineNameCtrl.text.trim();

    if (code.isEmpty || name.isEmpty) {
      Get.snackbar('Error', 'Please fill airline code and name');
      return;
    }

    // Check for duplicates
    final existing =
        await FirebaseFirestore.instance
            .collection('airline_logos')
            .doc(code)
            .get();
    if (existing.exists) {
      Get.snackbar('Duplicate', 'Airline code already exists.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.first.bytes == null) return;

    setState(() => _isUploading = true);

    try {
      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(
        'airline_logos/$code.png',
      );
      await ref.putData(result.files.first.bytes!);

      // Save metadata to Firestore
      await FirebaseFirestore.instance
          .collection('airline_logos')
          .doc(code)
          .set({
            'airlineName': name,
            'code': code,
            'uploadedAt': DateTime.now(),
          });
      print('✅ Logo uploaded for $code');
      Get.snackbar('Success', 'Logo uploaded successfully.');
      _airlineCodeCtrl.clear();
      _airlineNameCtrl.clear();
    } catch (e) {
      print('❌ Failed to upload logo: $e');
      Get.snackbar('Error', 'Failed to upload logo.');
    }

    setState(() => _isUploading = false);
  }

  Future<void> _deleteLogo(String code) async {
    print('🗑 Deleting logo $code');
    try {
      await FirebaseStorage.instance
          .ref()
          .child('airline_logos/$code.png')
          .delete();
      print('✅ Logo deleted $code');
      await FirebaseFirestore.instance
          .collection('airline_logos')
          .doc(code)
          .delete();
      Get.snackbar('Deleted', 'Logo deleted successfully.');
    } catch (e) {
      print('❌ Failed to delete logo: $e');
      Get.snackbar('Error', 'Failed to delete logo.');
    }
  }

  @override
  void dispose() {
    _airlineCodeCtrl.dispose();
    _airlineNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Flight Assets Manager'),
        backgroundColor: AppConfig.surface,
        foregroundColor: AppConfig.textMain,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _airlineCodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Airline Code (e.g. indigo)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _airlineNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Airline Name (e.g. IndiGo)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadLogo,
              icon: const Icon(Icons.upload_file),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Logo'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Uploaded Logos'),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('airline_logos')
                        .orderBy('airlineName')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No logos uploaded yet.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final code = data['code'] ?? '';
                      final name = data['airlineName'] ?? '';
                      final logoUrl =
                          'https://firebasestorage.googleapis.com/v0/b/${FirebaseStorage.instance.bucket}/o/airline_logos%2F$code.png?alt=media';

                      return ListTile(
                        leading: Image.network(
                          logoUrl,
                          width: 48,
                          height: 48,
                          errorBuilder:
                              (_, __, ___) => const Icon(Icons.flight),
                        ),
                        title: Text(name),
                        subtitle: Text(code),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteLogo(code),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

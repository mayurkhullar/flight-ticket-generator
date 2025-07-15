import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_config.dart';

class AirlineLogosView extends StatefulWidget {
  const AirlineLogosView({super.key});

  @override
  State<AirlineLogosView> createState() => _AirlineLogosViewState();
}

class _AirlineLogosViewState extends State<AirlineLogosView> {
  final CollectionReference logosRef = FirebaseFirestore.instance.collection(
    'airline_logos',
  );

  Future<void> _uploadLogo() async {
    print('⬆️ Uploading logo');
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final originalName = result.files.single.name;
      final baseName = originalName
          .split('.')
          .first
          .toLowerCase()
          .replaceAll(' ', '_');
      final ext = originalName.split('.').last;

      // Check existing logos with same baseName
      final existing =
          await logosRef.where('baseName', isEqualTo: baseName).get();
      final version = existing.size + 1;

      final finalName =
          version == 1 ? '$baseName.$ext' : '${baseName}_$version.$ext';
      final path = 'logos/$finalName';

      final ref = FirebaseStorage.instance.ref(path);
      final uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        try {
          final url = await ref.getDownloadURL();

          await logosRef.add({
            'name': finalName,
            'baseName': baseName,
            'url': url,
            'path': path,
            'uploadedAt': FieldValue.serverTimestamp(),
          });

          print('✅ Logo uploaded: $finalName');
          Get.snackbar('Uploaded', 'Logo "$finalName" uploaded successfully');
        } catch (e) {
          print('❌ Could not fetch download URL: $e');
          Get.snackbar('Error', 'Upload succeeded but getting URL failed');
        }
      });
    } catch (e) {
      print('❌ Upload task failed: $e');
      Get.snackbar('Error', 'Failed to upload logo');
    }
  }

  Future<void> _deleteLogo(String docId, String storagePath) async {
    print('🗑 Deleting logo $docId');
    try {
      await FirebaseStorage.instance.ref(storagePath).delete();
      await logosRef.doc(docId).delete();
      print('✅ Logo deleted');
      Get.snackbar('Deleted', 'Logo deleted');
    } catch (e) {
      print('❌ Failed to delete logo: $e');
      Get.snackbar('Error', 'Failed to delete logo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Airline Logos'),
        backgroundColor: AppConfig.surface,
        foregroundColor: AppConfig.textMain,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _uploadLogo,
            tooltip: 'Upload Logo',
            color: AppConfig.textMain,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: logosRef.orderBy('uploadedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No logos uploaded yet.'));
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'];
              final url = data['url'];
              final path = data['path'];

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppConfig.borderColor),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => _deleteLogo(doc.id, path),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

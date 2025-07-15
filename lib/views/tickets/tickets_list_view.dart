import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../theme/app_config.dart';

class TicketsListView extends StatefulWidget {
  const TicketsListView({super.key});

  @override
  State<TicketsListView> createState() => _TicketsListViewState();
}

class _TicketsListViewState extends State<TicketsListView> {
  List<FileSystemEntity> pdfFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  Future<void> _loadPdfFiles() async {
    print('📂 Loading PDF files');
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files =
          dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      setState(() {
        pdfFiles = files;
        isLoading = false;
      });
      print('✅ Loaded \${files.length} PDFs');
    } catch (e) {
      print('❌ Failed to load PDFs: $e');
      setState(() => isLoading = false);
    }
  }

  void _openPdf(File file) {
    print('📄 Opening PDF \${file.path}');
    OpenFile.open(file.path);
  }

  void _deletePdf(File file) async {
    print('🗑 Deleting PDF \${file.path}');
    try {
      await file.delete();
      await _loadPdfFiles();
    } catch (e) {
      print('❌ Failed to delete PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Generated Tickets'),
        backgroundColor: AppConfig.surface,
        foregroundColor: AppConfig.textMain,
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : pdfFiles.isEmpty
              ? const Center(child: Text('No tickets found'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: pdfFiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final file = pdfFiles[index];
                  final name = file.uri.pathSegments.last;
                  final modified = file.statSync().modified;

                  return ListTile(
                    tileColor: AppConfig.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConfig.borderRadius,
                      ),
                      side: BorderSide(color: AppConfig.borderColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(name, style: AppConfig.body),
                    subtitle: Text(
                      'Modified: ${modified.toLocal()}',
                      style: AppConfig.label,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () => _openPdf(File(file.path)),
                          tooltip: 'Open',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AppConfig.danger,
                          onPressed: () => _deletePdf(File(file.path)),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

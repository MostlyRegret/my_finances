import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = "/settings";
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  Future<void> _exportJson(BuildContext context) async {
    try {
      final jsonString = appState.exportAllDataJson();

      final dir = await getTemporaryDirectory();
      final filename =
          "my_finances_export_${DateTime.now().millisecondsSinceEpoch}.json";
      final file = File("${dir.path}/$filename");
      await file.writeAsString(jsonString);

      await Share.shareXFiles([
        XFile(file.path, mimeType: "application/json", name: filename),
      ], text: "My Finances export (JSON)");
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  Future<void> _importJson(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["json"],
        withData: true, // ensures bytes available even if path is null
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      String jsonString;
      if (file.bytes != null) {
        jsonString = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        jsonString = await File(file.path!).readAsString();
      } else {
        throw Exception("Could not read selected file.");
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Restore data?"),
          content: const Text(
            "This will REPLACE your current loans + budget on this device.\n\nContinue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Restore"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await appState.restoreFromJsonString(jsonString);

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Restore complete.")));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Import failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
          children: [
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: appState.isDarkMode,
              onChanged: (v) => appState.setDarkMode(v),
            ),
            const Divider(),
            ListTile(
              title: const Text("Export data (JSON)"),
              subtitle: const Text("Share to Google Drive, email, etc."),
              leading: const Icon(Icons.upload_file),
              onTap: () => _exportJson(context),
            ),
            ListTile(
              title: const Text("Import / Restore (JSON)"),
              subtitle: const Text(
                "Pick a previous export to restore your data.",
              ),
              leading: const Icon(Icons.download),
              onTap: () => _importJson(context),
            ),
            const Divider(),
            const ListTile(
              title: Text("Storage"),
              subtitle: Text("All data is stored locally on this device."),
            ),
          ],
        ),
      ),
    );
  }
}

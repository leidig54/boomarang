import 'package:boomarang_shared/models/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ViewResponseScreen extends StatefulWidget {
  const ViewResponseScreen({
    super.key,
    required this.response,
  });

  final BoomarangResponse response;

  @override
  State<ViewResponseScreen> createState() => _ViewResponseScreenState();
}

class _ViewResponseScreenState extends State<ViewResponseScreen> {
  late QuillController reportQuillController;

  @override
  void initState() {
    reportQuillController = QuillController(
      document: Document.fromJson(widget.response.report),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: QuillEditor.basic(
                configurations: const QuillEditorConfigurations(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

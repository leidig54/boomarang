import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RespondRequestScreen extends StatefulWidget {
  const RespondRequestScreen({
    super.key,
    required this.request,
  });

  final BoomarangRequest request;

  @override
  State<RespondRequestScreen> createState() => _RespondRequestScreenState();
}

class _RespondRequestScreenState extends State<RespondRequestScreen> {
  final _responseFormKey = GlobalKey<FormBuilderState>();

  BoomarangRequest get request => widget.request;

  QuillController reportQuillController = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        body: Container(),
      ),
    );
  }
}

import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang/providers/inbox_provider.dart';
import 'package:boomarang_shared/models/boomarang_element.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class RequestForm extends StatefulWidget {
  const RequestForm({
    super.key,
    required this.selectedRequest,
  });

  final BoomarangRequest selectedRequest;

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          if (widget.selectedRequest.elements != null &&
              widget.selectedRequest.elements!.isNotEmpty == true)
            ...List.generate(
              widget.selectedRequest.elements!.length,
              (index) {
                BoomarangElement element =
                    widget.selectedRequest.elements![index];

                bool responseComplete =
                    context.watch<InboxProvider>().responseComplete;

                if (element.type == "text") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderTextField(
                      name: element.id,
                      enabled: !responseComplete && !isSaving,
                      initialValue: kDebugMode ? "Test" : null,
                      decoration: InputDecoration(
                        labelText: element.labelText,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                } else if (element.type == "checkbox") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderCheckbox(
                      name: element.id,
                      enabled: !responseComplete && !isSaving,
                      initialValue: kDebugMode ? true : null,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(element.labelText!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                } else if (element.type == 'radio') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderRadioGroup(
                      name: element.id,
                      enabled: !responseComplete && !isSaving,
                      initialValue: kDebugMode ? element.options!.first : null,
                      decoration: InputDecoration(
                        labelText: element.labelText,
                        border: const OutlineInputBorder(),
                      ),
                      options: element.options!
                          .map((e) => FormBuilderFieldOption(
                                value: e,
                                child: Text(
                                  e,
                                  style: !responseComplete && !isSaving
                                      ? null
                                      : const TextStyle(color: Colors.grey),
                                ),
                              ))
                          .toList(),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          //submit button
          if (!context.watch<InboxProvider>().responseComplete)
            FloatingActionButton.extended(
              onPressed: isSaving
                  ? null
                  : () async {
                      formKey.currentState!.save();

                      setState(() {
                        isSaving = true;
                      });

                      await Future.delayed(const Duration(seconds: 2));

                      await functions.httpsCallable('submitResponse').call({
                        'requestId': widget.selectedRequest.id,
                        'response': formKey.currentState!.value,
                      });

                      await Future.delayed(const Duration(milliseconds: 100));

                      setState(() {
                        isSaving = false;
                      });
                    },
              label: isSaving
                  ? const CircularProgressIndicator.adaptive()
                  : const Text("Submit"),
            ),
          if (widget.selectedRequest.consentVerified != true &&
              !context.watch<InboxProvider>().responseComplete) ...[
            const SizedBox(
              height: 16,
            ),
            Text(
              "Your response won't be released until the subject has accepted the consent policy.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}

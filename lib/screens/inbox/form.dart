import 'dart:async';

import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/boomarang_element.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class InboxRequestForm extends StatefulWidget {
  const InboxRequestForm({
    super.key,
    required this.selectedRequest,
  });

  final BoomarangRequest selectedRequest;

  @override
  State<InboxRequestForm> createState() => _InboxRequestFormState();
}

class _InboxRequestFormState extends State<InboxRequestForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    BoomarangRequest request = widget.selectedRequest;

    return FormBuilder(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          Text(request.form.name,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(
            height: 4,
          ),
          Text(
            request.form.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 32,
          ),
          if (request.form.elements.isNotEmpty == true)
            ...List.generate(
              request.form.elements.length,
              (index) {
                FormElement element = request.form.elements[index];
                bool responseComplete = request.responseSubmitted;

                if (element.type == "text") {
                  dynamic initialValue;
                  if (request.response?[element.id] != null) {
                    initialValue = request.response?[element.id];
                  } else {
                    initialValue =
                        kDebugMode ? "Test response for text fields" : null;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderTextField(
                      key: Key(element.id),
                      name: element.id,
                      enabled: !responseComplete && !isSaving,
                      initialValue: initialValue,
                      decoration: InputDecoration(
                        labelText: element.labelText,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                } else if (element.type == "checkbox") {
                  dynamic initialValue;
                  if (request.response?[element.id] != null) {
                    initialValue = request.response?[element.id];
                  } else {
                    initialValue = kDebugMode ? true : null;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderCheckbox(
                      key: Key(element.id),
                      name: element.id,
                      enabled: !responseComplete && !isSaving,
                      initialValue: initialValue,
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(element.labelText!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                } else if (element.type == 'radio') {
                  dynamic initialValue;
                  if (request.response?[element.id] != null) {
                    initialValue = request.response?[element.id];
                  } else {
                    initialValue = kDebugMode ? element.options?.first : null;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderRadioGroup(
                      key: Key(element.id),
                      name: element.id,
                      enabled: !responseComplete && !isSaving,
                      initialValue: initialValue,
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
                } else if (element.type == "statement") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      element.text!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: responseComplete || isSaving
                                ? Colors.grey
                                : null,
                          ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          //submit button
          if (!request.responseSubmitted)
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
                        'requestId': request.id,
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
          if (request.consentVerified != true &&
              !request.responseSubmitted) ...[
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

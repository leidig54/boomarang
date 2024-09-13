import 'package:boomarang_shared/models/boomarang_element.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SentRequestForm extends StatefulWidget {
  const SentRequestForm({
    super.key,
    required this.selectedRequest,
  });

  final BoomarangRequest selectedRequest;

  @override
  State<SentRequestForm> createState() => _SentRequestFormState();
}

class _SentRequestFormState extends State<SentRequestForm> {
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
          if (request.elements != null && request.elements!.isNotEmpty == true)
            ...List.generate(
              request.elements!.length,
              (index) {
                BoomarangElement element = request.elements![index];
                bool responseComplete = request.responseSubmitted;

                if (element.type == "text") {
                  dynamic initialValue;
                  if (request.response?[element.id] != null) {
                    initialValue = request.response?[element.id];
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderTextField(
                      name: element.id,
                      readOnly: true,
                      enabled: false,
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
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderCheckbox(
                      name: element.id,
                      enabled: false,
                      onChanged: null,
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
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderRadioGroup(
                      name: element.id,
                      enabled: false,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.grey,
                                      ),
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
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}

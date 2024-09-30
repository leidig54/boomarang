import 'package:boomarang_shared/models/form_element.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

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
          Text(request.form.name,
              style: Theme.of(context).textTheme.headlineSmall),
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

                if (element.type == "text") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderTextField(
                      name: element.id,
                      readOnly: true,
                      enabled: false,
                      initialValue: request.response?[element.id],
                      minLines: element.minLines,
                      maxLines: element.maxLines,
                      decoration: InputDecoration(
                        labelText: element.labelText,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  );
                } else if (element.type == "checkbox") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderCheckbox(
                      name: element.id,
                      enabled: false,
                      onChanged: null,
                      initialValue: request.response?[element.id],
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
                      enabled: false,
                      initialValue: request.response?[element.id],
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
                } else if (element.type == "statement") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      element.text!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  );
                } else if (element.type == "date") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: FormBuilderDateTimePicker(
                      name: element.id,
                      enabled: false,
                      initialValue: request.response?[element.id] != null
                          ? (request.response?[element.id] as Timestamp)
                              .toDate()
                          : null,
                      inputType: InputType.date,
                      format: DateFormat.yMMMMd(),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      decoration: InputDecoration(
                        labelText: element.labelText,
                        border: const OutlineInputBorder(),
                      ),
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

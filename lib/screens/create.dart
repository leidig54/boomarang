import 'package:boomarang_shared/models/boomarang_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CreateNewRequest extends StatefulWidget {
  const CreateNewRequest({
    super.key,
  });

  @override
  State<CreateNewRequest> createState() => _CreateNewRequestState();
}

class _CreateNewRequestState extends State<CreateNewRequest> {
  List<BoomarangElement> elements = [];
  //formbuilder key
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKey,
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text("Subject"),
                    subtitle: const Text("Incomplete"),
                    leading: const Icon(Icons.horizontal_rule),
                    initiallyExpanded: true,
                    children: [
                      //name, dob and email fields
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'first_name',
                              decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder()),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'last_name',
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'email',
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.email(),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            //dob
                            FormBuilderDateTimePicker(
                              name: 'dob',
                              inputType: InputType.date,
                              initialEntryMode: DatePickerEntryMode.input,
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

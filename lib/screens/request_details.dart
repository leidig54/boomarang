import 'package:boomarang/providers/tab_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateNewRequest extends StatefulWidget {
  const CreateNewRequest({
    super.key,
  });

  @override
  State<CreateNewRequest> createState() => _CreateNewRequestState();
}

class _CreateNewRequestState extends State<CreateNewRequest> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isSaving = false;
  late String id;
  String? selectedType;

  @override
  void initState() {
    super.initState();
    id = const Uuid().v4();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      onChanged: () {
        if (_formKey.currentState!.fields['type']!.value != null) {
          setState(() {
            selectedType =
                _formKey.currentState!.fields['type']!.value as String;
          });
        }
      },
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: [
                const SizedBox(height: 16),
                const Text("Owner"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'subject_first_name',
                        initialValue: kDebugMode ? 'John' : null,
                        decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder()),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'subject_last_name',
                        initialValue: kDebugMode ? 'Doe' : null,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FormBuilderTextField(
                        name: 'subject_email',
                        initialValue:
                            kDebugMode ? 'georgeleidig@icloud.com' : null,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    //subject postcode
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'subject_postcode',
                        initialValue: kDebugMode ? 'PL1 3GD' : null,
                        decoration: const InputDecoration(
                          labelText: 'Postcode',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(4),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const Text("Pet"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: FormBuilderTextField(
                        name: 'pet_name',
                        initialValue: kDebugMode ? 'Fido' : null,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(3),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    //pet species dropdown
                    Expanded(
                      child: FormBuilderDropdown(
                        name: 'pet_species',
                        initialValue: kDebugMode ? 'Dog' : null,
                        decoration: const InputDecoration(
                          labelText: 'Species',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) async {
                          await Future.delayed(
                              const Duration(milliseconds: 10));
                          FocusScope.of(context).unfocus();
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Dog',
                            child: Text('Dog'),
                          ),
                          DropdownMenuItem(
                            value: 'Cat',
                            child: Text('Cat'),
                          ),
                          DropdownMenuItem(
                            value: 'Rabbit',
                            child: Text('Rabbit'),
                          ),
                          DropdownMenuItem(
                            value: 'Guinea Pig',
                            child: Text('Guinea Pig'),
                          ),
                          DropdownMenuItem(
                            value: 'Hamster',
                            child: Text('Hamster'),
                          ),
                          DropdownMenuItem(
                            value: 'Bird',
                            child: Text('Bird'),
                          ),
                          DropdownMenuItem(
                            value: 'Reptile',
                            child: Text('Reptile'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Text("Request"),
                const SizedBox(height: 16),
                FormBuilderRadioGroup(
                  name: 'type',
                  initialValue: null,
                  orientation: OptionsOrientation.vertical,
                  controlAffinity: ControlAffinity.trailing,
                  options: [
                    FormBuilderFieldOption(
                        value: 'insurance',
                        child: ListTile(
                          title: Text('Insurance'),
                          subtitle: Text(
                              "Get consent release medical records to an insurance company"),
                        )),
                    FormBuilderFieldOption(
                      value: 'transfer',
                      child: ListTile(
                        title: Text('Transfer'),
                        subtitle: Text(
                            "Get consent to transfer medical records to another practice"),
                      ),
                    ),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Type',
                  ),
                ),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
          ),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  if (selectedType == "insurance") ...[
                    const Text("Insurance Details"),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'insurance_company',
                      key: const Key('insurance_company'),
                      initialValue: kDebugMode ? 'PetPlan' : null,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(3),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'insurance_policy_number',
                      key: const Key('insurance_policy_number'),
                      initialValue: kDebugMode ? '123456789' : null,
                      decoration: const InputDecoration(
                        labelText: 'Policy Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(3),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (selectedType == "transfer") ...[
                    const Text("Transfer Details"),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'transfer_practice_name',
                      key: const Key('transfer_practice_name'),
                      initialValue: kDebugMode ? 'Vets4Pets' : null,
                      decoration: const InputDecoration(
                        labelText: 'Practice Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(3),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'transfer_practice_postcode',
                      key: const Key('transfer_practice_postcode'),
                      initialValue: kDebugMode ? 'PL1 3GD' : null,
                      decoration: const InputDecoration(
                        labelText: 'Postcode',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(4),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (selectedType != null) ...[
                    SizedBox(
                      height: 48,
                    ),
                    FloatingActionButton.extended(
                      onPressed: () async {
                        if (_formKey.currentState!.saveAndValidate()) {
                          setState(() {
                            isSaving = true;
                          });

                          // Simulate a delay to show the loading indicator
                          await Future.delayed(const Duration(seconds: 1));

                          //

                          setState(() {
                            isSaving = false;
                          });

                          if (!context.mounted) return;
                          context.read<TabIndexProvider>().setTabIndex(1);
                        }
                      },
                      label: isSaving
                          ? const CircularProgressIndicator.adaptive()
                          : const Text("Send Consent Request"),
                    )
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

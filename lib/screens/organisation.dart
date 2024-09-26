import 'package:boomarang/main.dart';
import 'package:boomarang/providers/organisation_provider.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class OrganisationScreen extends StatefulWidget {
  const OrganisationScreen({super.key});

  @override
  State<OrganisationScreen> createState() => _OrganisationScreenState();
}

class _OrganisationScreenState extends State<OrganisationScreen> {
  final _organisationFormKey = GlobalKey<FormBuilderState>();
  bool _formChanged = false;

  @override
  Widget build(BuildContext context) {
    Organisation? organisation =
        context.watch<OrganisationProvider>().organisation;

    if (organisation == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    bool isAdmin = organisation.admins.contains(auth.currentUser?.uid);

    return FormBuilder(
      key: _organisationFormKey,
      onChanged: () {
        if (!_formChanged) {
          setState(() {
            _formChanged = true;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    autofocus: organisation.name.isEmpty,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    initialValue: organisation.name,
                    enabled: isAdmin,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  //TODO: List of users and permissions if admin
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: !_formChanged
                        ? null
                        : () async {
                            if (_organisationFormKey.currentState!
                                .saveAndValidate()) {
                              final data =
                                  _organisationFormKey.currentState!.value;
                              await firestore
                                  .collection('organisations')
                                  .doc(organisation.id)
                                  .set(data, SetOptions(merge: true));
                              if (mounted) {
                                setState(() {
                                  _formChanged = false;
                                });
                              }
                            }
                          },
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

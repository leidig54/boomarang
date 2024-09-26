import 'package:boomarang/providers/user_provider.dart';
import 'package:boomarang_shared/models/user.dart';
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
    BoomarangUser? user = context.watch<UserProvider>().user;

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
                    name: 'title',
                    autofocus: user?.title == null,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    initialValue: user?.title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Mr, Mrs, Dr, etc.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'firstName',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(2),
                    ]),
                    initialValue: user?.firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderTextField(
                    name: 'lastName',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(2),
                    ]),
                    initialValue: user?.lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  //verify email
                  FormBuilderTextField(
                    name: 'email',
                    readOnly: true,
                    enableInteractiveSelection: false,
                    enabled: false,
                    initialValue: user?.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      helperText: 'Email cannot be changed',
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: () {},
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

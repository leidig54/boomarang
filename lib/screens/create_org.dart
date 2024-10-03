import 'package:boomarang/main.dart';
import 'package:boomarang/widgets/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CreateOrganisation extends StatefulWidget {
  const CreateOrganisation({super.key});

  @override
  State<CreateOrganisation> createState() => _CreateOrganisationState();
}

class _CreateOrganisationState extends State<CreateOrganisation> {
  final _createOrganisationFormKey = GlobalKey<FormBuilderState>();
  final _joinOrganisationFormKey = GlobalKey<FormBuilderState>();

  bool creatingOrganisation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create a new organisation',
                  ),
                  const SizedBox(height: 32),
                  FormBuilder(
                    key: _createOrganisationFormKey,
                    child: FormBuilderTextField(
                      name: 'name',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: creatingOrganisation
                        ? const CircularProgressIndicator.adaptive()
                        : const Icon(Icons.save),
                    onPressed: creatingOrganisation
                        ? null
                        : () async {
                            if (_createOrganisationFormKey.currentState!
                                .saveAndValidate()) {
                              setState(() {
                                creatingOrganisation = true;
                              });

                              await functions
                                  .httpsCallable('createOrganisation')
                                  .call({
                                'name': _createOrganisationFormKey
                                    .currentState!.value['name'],
                              }).then((value) {
                                setState(() {
                                  creatingOrganisation = false;
                                });
                              }).catchError((error) {
                                buildErrorAlertDialog(error);
                                setState(() {
                                  creatingOrganisation = false;
                                });
                              });
                            }
                          },
                    label: const Text('Create'),
                  ),
                  const SizedBox(height: 32),
                  //or enter invite code to join an organisation
                  const Text(
                    'Join an existing organisation',
                  ),
                  const SizedBox(height: 16),
                  FormBuilder(
                    key: _joinOrganisationFormKey,
                    child: FormBuilderTextField(
                      name: 'inviteCode',
                      decoration: const InputDecoration(
                        labelText: 'Invite Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: creatingOrganisation
                        ? const CircularProgressIndicator.adaptive()
                        : const Icon(Icons.add),
                    onPressed: creatingOrganisation
                        ? null
                        : () async {
                            if (_joinOrganisationFormKey.currentState!
                                .saveAndValidate()) {
                              setState(() {
                                creatingOrganisation = true;
                              });
                              await functions
                                  .httpsCallable('joinOrganisation')
                                  .call({
                                'inviteCode': _joinOrganisationFormKey
                                    .currentState!.value['inviteCode'],
                              }).then((value) {
                                if (!mounted) return;
                                setState(() {
                                  creatingOrganisation = false;
                                });
                              }).catchError((error) {
                                if (!mounted) return;
                                buildErrorAlertDialog(error);
                                setState(() {
                                  creatingOrganisation = false;
                                });
                              });
                            }
                          },
                    label: const Text('Join'),
                  ),
                  //exit
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () async {
                      await auth.signOut();
                    },
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

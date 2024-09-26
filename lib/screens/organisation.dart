import 'package:boomarang/main.dart';
import 'package:boomarang/providers/organisation_provider.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:boomarang_shared/models/user.dart';
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
                  const SizedBox(height: 32),

                  Text("User Management",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  //TODO: List of users and permissions if admin
                  ListView.builder(
                    itemBuilder: (context, index) {
                      String uid = organisation.admins[index];
                      return FutureBuilder(
                          future: firestore.collection('users').doc(uid).get(),
                          builder: (context, snapshot) {
                            BoomarangUser? user;
                            bool? userIsAdmin;

                            if (snapshot.hasData && snapshot.data!.exists) {
                              user = BoomarangUser.fromMap(snapshot.data!.data()
                                  as Map<String, dynamic>);
                              userIsAdmin = organisation.admins
                                  .contains(snapshot.data!.id);
                            }

                            if (user == null || userIsAdmin == null) {
                              return const SizedBox();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${user.firstName} ${user.lastName}'),
                                Text('${user.email}'),
                                DropdownButton(
                                  value: userIsAdmin ? 'admin' : 'member',
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'admin',
                                      child: Text('Admin'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'member',
                                      child: Text('Member'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    //TODO: Add user ID to the user object.
                                  },
                                )
                              ],
                            );
                          });
                    },
                    itemCount: organisation.members.length,
                    shrinkWrap: true,
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

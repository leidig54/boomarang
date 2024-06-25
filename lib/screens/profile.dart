import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _userFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder(
              future: firestore
                  .collection('users')
                  .doc(auth.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                BoomarangUser? user;

                if (snapshot.hasData && snapshot.data!.exists) {
                  user = BoomarangUser.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);
                }

                return FormBuilder(
                  key: _userFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'title',
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
                            initialValue: user?.firstName,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'lastName',
                            initialValue: user?.lastName,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_userFormKey.currentState!
                                      .saveAndValidate()) {
                                    final data =
                                        _userFormKey.currentState!.value;
                                    await firestore
                                        .collection('users')
                                        .doc(auth.currentUser!.uid)
                                        .set(data, SetOptions(merge: true));
                                    setState(() {});
                                    showAdaptiveDialog(
                                        context: navigatorKey.currentContext!,
                                        builder: (context) {
                                          return AlertDialog.adaptive(
                                            title:
                                                const Text('Profile Updated'),
                                            content: const Text(
                                                'Your profile has been updated.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                },
                                child: const Text('Save'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _userFormKey.currentState!.reset();
                                },
                                child: const Text('Discard Changes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

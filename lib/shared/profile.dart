import 'package:boomarang/data/user_provider.dart';
import 'package:boomarang/main.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userFormKey = GlobalKey<FormBuilderState>();
  bool _formChanged = false;

  @override
  Widget build(BuildContext context) {
    BoomarangUser? user = context.watch<UserProvider>().user;

    return FormBuilder(
      key: _userFormKey,
      onChanged: () {
        if (!_formChanged) {
          setState(() {
            _formChanged = true;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
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
                    border: UnderlineInputBorder(),
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
                    border: UnderlineInputBorder(),
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
                    border: UnderlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),
                //verify email
                FormBuilderTextField(
                  name: 'email',
                  readOnly: true,
                  initialValue: user?.email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: UnderlineInputBorder(),
                    helperText: 'Email cannot be changed',
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: !_formChanged
                          ? null
                          : () async {
                              if (_userFormKey.currentState!
                                  .saveAndValidate()) {
                                final data = _userFormKey.currentState!.value;
                                await firestore
                                    .collection('users')
                                    .doc(auth.currentUser!.uid)
                                    .set(data, SetOptions(merge: true));
                                setState(() {
                                  _formChanged = false;
                                });
                              }
                            },
                      label: const Text('Save'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: !_formChanged
                          ? null
                          : () {
                              _userFormKey.currentState!.reset();
                              setState(() {
                                _formChanged = false;
                              });
                            },
                      icon: const Icon(Icons.clear),
                      label: const Text('Discard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

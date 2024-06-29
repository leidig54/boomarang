import 'package:boomarang/main.dart';
import 'package:boomarang/misc/alert_dialog.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userFormKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  bool _formChanged = false;
  bool isSending = false;
  bool isVerifying = false;

  BoomarangUser? user;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    setState(() {
      isLoading = true;
    });
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        user = BoomarangUser.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (user?.emailVerified != true) {
      if (user?.emailVerificationCodeHasExpired == true) {
        //resend email button
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'Your email has not been verified. Please verify your email to continue.'),
            const SizedBox(height: 16),
            isSending
                ? const LinearProgressIndicator()
                : TextButton(
                    onPressed: () async {
                      setState(() {
                        isSending = true;
                      });
                      //send the user id to the cloud function
                      await functions
                          .httpsCallable('sendVerificationEmailCallable')
                          .call()
                          .catchError((e) {
                        setState(() {
                          isSending = false;
                        });
                        buildErrorAlertDialog(e);
                        throw e;
                      }).whenComplete(() {
                        setState(() {
                          isSending = false;
                        });
                        getUser();
                      });
                    },
                    child: const Text('Resend verification email'),
                  ),
          ],
        );
      } else {
        return Center(
          child: SizedBox(
            width: 400,
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Enter the verification code sent to your email',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (code) async {
                setState(() {
                  isVerifying = true;
                });
                await functions
                    .httpsCallable('checkEmailVerificationCode')
                    .call({'code': code}).catchError((e) {
                  buildErrorAlertDialog(e);
                  throw e;
                }).whenComplete(() {
                  setState(() {
                    isVerifying = false;
                  });
                  getUser();
                });
              },
            ),
          ),
        );
      }
    }

    if (user?.userType == null) {
      //userType (holder or requester)
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Select User Type",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              ListTile(
                title: const Text('Holder'),
                subtitle: const Text(
                    'You hold sensitive data and want to respond to requests.\nE.g. doctors, accountants, universities.'),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                leading: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_circle_up),
                  ],
                ),
                isThreeLine: true,
                onTap: () async {
                  await firestore
                      .collection('users')
                      .doc(auth.currentUser!.uid)
                      .set({'userType': 'holder'}, SetOptions(merge: true));
                  await getUser();
                },
              ),
              const Divider(
                thickness: 1,
                height: 1,
              ),
              ListTile(
                title: const Text('Requester'),
                subtitle: const Text(
                    'You want to submit requests for sensitive data.\nE.g. insurance, legal, recruitment.'),
                trailing: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                leading: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_circle_down),
                  ],
                ),
                isThreeLine: true,
                onTap: () async {
                  await firestore
                      .collection('users')
                      .doc(auth.currentUser!.uid)
                      .set({'userType': 'requester'}, SetOptions(merge: true));
                  await getUser();
                },
              ),
            ],
          ),
        ),
      );
    }

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
                //if email is not verified, show a button to resend verification email or verify email
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
                                await getUser();
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

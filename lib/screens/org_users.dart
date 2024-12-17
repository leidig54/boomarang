import 'package:boomarang/main.dart';
import 'package:boomarang/providers/organisation_provider.dart';
import 'package:boomarang/providers/user_provider.dart';
import 'package:boomarang/widgets/error.dart';
import 'package:boomarang_shared/models/invite.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class OrganisationUsersScreen extends StatefulWidget {
  const OrganisationUsersScreen({super.key});

  @override
  State<OrganisationUsersScreen> createState() =>
      _OrganisationUsersScreenState();
}

class _OrganisationUsersScreenState extends State<OrganisationUsersScreen> {
  @override
  Widget build(BuildContext context) {
    Organisation? organisation =
        context.watch<OrganisationProvider>().organisation;

    if (organisation == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    bool isAdmin =
        context.watch<UserProvider>().user?.organisationRole == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organisation Users',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                //add user
                const SizedBox(height: 16),
                if (isAdmin)
                  ElevatedButton(
                    onPressed: () {
                      //show dialog
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AddUserDialog();
                          });
                    },
                    child: const Text('Add User'),
                  ),
                const SizedBox(height: 32),
                ListView.builder(
                  itemBuilder: (context, index) {
                    String uid = organisation.users[index];
                    return FutureBuilder(
                        future: firestore.collection('users').doc(uid).get(),
                        builder: (context, snapshot) {
                          BoomarangUser? user;
                          bool? userIsAdmin;

                          if (snapshot.hasData && snapshot.data!.exists) {
                            user = BoomarangUser.fromMap(
                                snapshot.data!.data() as Map<String, dynamic>);
                            userIsAdmin = user.organisationRole == 'admin';
                          }

                          if (user == null || userIsAdmin == null) {
                            return const SizedBox();
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text('${user.email}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              Expanded(
                                child: PermissionsDropdown(
                                  isAdmin: isAdmin,
                                  organisation: organisation,
                                  user: user,
                                ),
                              )
                            ],
                          );
                        });
                  },
                  itemCount: organisation.users.length,
                  shrinkWrap: true,
                ),
                //pending invites
                const SizedBox(height: 64),
                Text(
                  'Pending Invites',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                StreamBuilder(
                    stream: firestore
                        .collection('invites')
                        .where('organisationId', isEqualTo: organisation.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No pending invites',
                            style: Theme.of(context).textTheme.titleMedium);
                      } else {
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            Invite invite = Invite.fromMap(
                                snapshot.data!.docs[index].data());

                            //recipient email, status, and option to resend if invite has expired
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(invite.recipientEmail,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                                Expanded(
                                  child: invite.isExpired
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            await functions
                                                .httpsCallable('sendInvite')
                                                .call({
                                              'recipientEmail':
                                                  invite.recipientEmail,
                                              'recipientRole':
                                                  invite.recipientRole,
                                            });
                                          },
                                          child: const Text('Resend'),
                                        )
                                      : const SizedBox(),
                                )
                              ],
                            );
                          },
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({
    super.key,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  bool isAddingUser = false;
  //formkey
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add User'),
      content: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Enter the email address of the user you would like to add to the organisation.'),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'email',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            //select role, admin or member from dropdown
            FormBuilderDropdown(
              name: 'role',
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
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
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isAddingUser
              ? null
              : () async {
                  if (!_formKey.currentState!.saveAndValidate()) {
                    return;
                  }
                  setState(() {
                    isAddingUser = true;
                  });
                  await functions.httpsCallable('sendInvite').call({
                    'recipientEmail': _formKey.currentState!.value['email'],
                    'recipientRole': _formKey.currentState!.value['role'],
                  }).then((_) {
                    if (context.mounted) {
                      setState(() {
                        isAddingUser = false;
                      });
                      Navigator.pop(context);
                    }
                  }).catchError((error) {
                    if (mounted) {
                      buildErrorAlertDialog(error);
                      setState(() {
                        isAddingUser = false;
                      });
                    }
                  });
                },
          child: isAddingUser
              ? const CircularProgressIndicator.adaptive()
              : const Text('Add'),
        ),
      ],
    );
  }
}

class PermissionsDropdown extends StatefulWidget {
  const PermissionsDropdown({
    super.key,
    required this.isAdmin,
    required this.organisation,
    required this.user,
  });

  final bool isAdmin;
  final Organisation organisation;
  final BoomarangUser user;

  @override
  State<PermissionsDropdown> createState() => _PermissionsDropdownState();
}

class _PermissionsDropdownState extends State<PermissionsDropdown> {
  bool isUpdatingPermissions = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: firestore.collection('users').doc(widget.user.id).snapshots(),
        builder: (context, snapshot) {
          BoomarangUser? user;
          if (snapshot.hasData && snapshot.data!.exists) {
            user = BoomarangUser.fromMap(
                snapshot.data!.data() as Map<String, dynamic>);
          }

          return DropdownButton(
              value: user?.organisationRole,
              disabledHint: const CircularProgressIndicator.adaptive(),
              isExpanded: true,
              underline: const SizedBox(),
              items: isUpdatingPermissions
                  ? null
                  : [
                      const DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                      const DropdownMenuItem(
                        value: 'member',
                        child: Text('Member'),
                      ),
                    ],
              onChanged: !widget.isAdmin
                  ? null
                  : (value) async {
                      //if the value is the same, don't do anything
                      if (value == user?.organisationRole) {
                        return;
                      }
                      setState(() {
                        isUpdatingPermissions = true;
                      });
                      await Future.delayed(const Duration(seconds: 1));

                      await functions
                          .httpsCallable('updateOrganisationRole')
                          .call({
                        'id': user?.id,
                        'organisationId': widget.organisation.id,
                        'role': value,
                      }).then((_) {
                        if (mounted) {
                          setState(() {
                            isUpdatingPermissions = false;
                          });
                        }
                      }).catchError((error) {
                        if (mounted) {
                          setState(() {
                            isUpdatingPermissions = false;
                          });
                        }
                      });
                    });
        });
  }
}

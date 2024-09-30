import 'package:boomarang/main.dart';
import 'package:boomarang/providers/organisation_provider.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

    bool isAdmin = organisation.admins.contains(auth.currentUser?.uid);

    return Column(
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
                Text(
                  'Organisation Users',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                ListView.builder(
                  itemBuilder: (context, index) {
                    String uid = organisation.members[index];
                    return FutureBuilder(
                        future: firestore.collection('users').doc(uid).get(),
                        builder: (context, snapshot) {
                          BoomarangUser? user;
                          bool? userIsAdmin;

                          if (snapshot.hasData && snapshot.data!.exists) {
                            user = BoomarangUser.fromMap(
                                snapshot.data!.data() as Map<String, dynamic>);
                            userIsAdmin =
                                organisation.admins.contains(snapshot.data!.id);
                          }

                          if (user == null || userIsAdmin == null) {
                            return const SizedBox();
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child:
                                    Text('${user.firstName} ${user.lastName}'),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${user.email}'),
                              ),
                              Expanded(
                                child: PermissionsDropdown(
                                    userIsAdmin: userIsAdmin,
                                    isAdmin: isAdmin,
                                    organisation: organisation,
                                    user: user),
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
    );
  }
}

class PermissionsDropdown extends StatefulWidget {
  const PermissionsDropdown({
    super.key,
    required this.userIsAdmin,
    required this.isAdmin,
    required this.organisation,
    required this.user,
  });

  final bool userIsAdmin;
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
    return DropdownButton(
        value: widget.userIsAdmin ? 'admin' : 'member',
        disabledHint: const CircularProgressIndicator.adaptive(),
        isExpanded: true,
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
                if ((value == 'admin' && widget.userIsAdmin) ||
                    (value == 'member' && !widget.userIsAdmin)) {
                  return;
                }
                setState(() {
                  isUpdatingPermissions = true;
                });
                await Future.delayed(const Duration(seconds: 1));
                if (value == 'admin') {
                  await firestore
                      .collection('organisations')
                      .doc(widget.organisation.id)
                      .update({
                    'admins': FieldValue.arrayUnion([widget.user.id])
                  });
                } else {
                  //if is the last admin, show an alert dialog and don't remove
                  if (widget.organisation.admins.length == 1) {
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Cannot remove last admin'),
                          content: const Text(
                              'You cannot remove the last admin from an organisation. Please add another admin before removing this user.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    await firestore
                        .collection('organisations')
                        .doc(widget.organisation.id)
                        .update({
                      'admins': FieldValue.arrayRemove([widget.user.id])
                    });
                  }
                }
                if (mounted) {
                  setState(() {
                    isUpdatingPermissions = false;
                  });
                }
              });
  }
}

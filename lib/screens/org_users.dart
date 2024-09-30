import 'package:boomarang/main.dart';
import 'package:boomarang/providers/organisation_provider.dart';
import 'package:boomarang/providers/user_provider.dart';
import 'package:boomarang_shared/models/organisation.dart';
import 'package:boomarang_shared/models/user.dart';
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
                        value: 'user',
                        child: Text('User'),
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

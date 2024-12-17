import 'package:boomarang/providers/organisation_provider.dart';
import 'package:boomarang/screens/org_users.dart';
import 'package:boomarang/screens/organisation.dart';
import 'package:boomarang/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String selectedTile = 'profile';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Theme.of(context).canvasColor,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Admin",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text('Profile'),
                          subtitle: const Text('Edit your profile'),
                          leading: const Icon(Icons.person),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: selectedTile == 'profile'
                              ? Theme.of(context).highlightColor
                              : null,
                          onTap: () => setState(() {
                            selectedTile = 'profile';
                          }),
                        ),
                        //Organisation
                        ListTile(
                          title: const Text('Organisation Details'),
                          subtitle:
                              const Text('Edit your organisation details'),
                          leading: const Icon(Icons.business),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: selectedTile == 'organisation'
                              ? Theme.of(context).highlightColor
                              : null,
                          onTap: () => setState(() {
                            selectedTile = 'organisation';
                          }),
                        ),
                        //Organisation Users
                        ListTile(
                          title: const Text('Organisation Users'),
                          subtitle:
                              const Text('Manage your organisation users'),
                          leading: const Icon(Icons.people),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabled: context
                                  .watch<OrganisationProvider>()
                                  .organisation !=
                              null,
                          tileColor: selectedTile == 'users'
                              ? Theme.of(context).highlightColor
                              : null,
                          onTap: () => setState(() {
                            selectedTile = 'users';
                          }),
                        ),
                        ListTile(
                          title: Text("Templates"),
                          subtitle: Text("Customise your consent templates"),
                          leading: Icon(Icons.description),
                          onTap: () {},
                        )
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                ),
                Expanded(
                  key: ValueKey(selectedTile),
                  flex: 2,
                  child: Builder(
                    builder: (context) {
                      if (selectedTile == 'profile') {
                        return const BoomarangProfileScreen();
                      } else if (selectedTile == 'organisation') {
                        return const OrganisationScreen();
                      } else if (selectedTile == 'users') {
                        return const OrganisationUsersScreen();
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:boomarang/requester/screens/add_request.dart';
import 'package:boomarang/requester/screens/datagrid.dart';
import 'package:boomarang/shared/navigation_bottom_widget.dart';
import 'package:boomarang/shared/profile.dart';
import 'package:flutter/material.dart';

class RequesterHome extends StatefulWidget {
  const RequesterHome({
    super.key,
  });

  @override
  State<RequesterHome> createState() => _RequesterHomeState();
}

class _RequesterHomeState extends State<RequesterHome> {
  int selectedIndex = 0;

  List<Widget> screens = [
    const AddRequestScreen(),
    const RequesterDatagridScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const FlutterLogo(size: 100),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  'Boomarang',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
            //Boomerang
          ),
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.add),
              label: Text(
                'Add New',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.mail),
              label: Text(
                'Requests',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person),
              label: Text(
                'Profile',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
          trailing: const NavigationRailTrailingWidget(),
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          extended: MediaQuery.of(context).size.width > 1400,
        ),
        const VerticalDivider(
          thickness: 3,
          width: 3,
        ),
        Expanded(child: Scaffold(body: screens[selectedIndex])),
      ],
    );
  }
}

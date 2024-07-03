import 'package:boomarang/holder/screens/request_datagrid.dart';
import 'package:boomarang/shared/navigation_bottom_widget.dart';
import 'package:boomarang/shared/profile.dart';
import 'package:flutter/material.dart';

class HolderHome extends StatefulWidget {
  const HolderHome({
    super.key,
  });

  @override
  State<HolderHome> createState() => _HolderHomeState();
}

class _HolderHomeState extends State<HolderHome> {
  int selectedIndex = 1;

  List<Widget> screens = [
    // Container(),
    const HolderDatagridScreen(),
    Container(),
    const BoomarangProfileScreen(),
    Container(),
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
            // NavigationRailDestination(
            //   icon: const Icon(Icons.dashboard),
            //   disabled: true,
            //   label: Text(
            //     'Dashboard',
            //     style: Theme.of(context).textTheme.bodyLarge,
            //   ),
            // ),
            NavigationRailDestination(
              icon: const Icon(Icons.mail),
              label: Text(
                'Requests',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            //payments
            NavigationRailDestination(
              icon: const Icon(Icons.payment),
              disabled: true,
              label: Text(
                'Payments',
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
            //admin
            NavigationRailDestination(
              icon: const Icon(Icons.admin_panel_settings),
              disabled: true,
              label: Text(
                'Admin',
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
          extended: true,
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

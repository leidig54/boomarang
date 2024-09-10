import 'package:boomarang/providers/request_provider.dart';
import 'package:boomarang/providers/tab_provider.dart';
import 'package:boomarang/widgets/navigation_bottom_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RequestProvider()),
      ],
      child: Row(
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
                icon: const Icon(Icons.dashboard),
                label: Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.inbox),
                label: Text(
                  'Inbox',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.outbox),
                label: Text(
                  'Sent',
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
            selectedIndex: context.watch<TabIndexProvider>().tabIndex,
            onDestinationSelected: (int index) {
              context.read<TabIndexProvider>().setTabIndex(index);
            },
            extended: true,
          ),
          const VerticalDivider(
            thickness: 3,
            width: 3,
          ),
          Expanded(
            child: Scaffold(
              body: context.watch<TabIndexProvider>().screen,
            ),
          ),
        ],
      ),
    );
  }
}

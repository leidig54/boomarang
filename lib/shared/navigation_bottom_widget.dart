import 'package:boomarang/main.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NavigationRailTrailingWidget extends StatefulWidget {
  const NavigationRailTrailingWidget({
    super.key,
  });

  @override
  State<NavigationRailTrailingWidget> createState() =>
      _NavigationRailTrailingWidgetState();
}

class _NavigationRailTrailingWidgetState
    extends State<NavigationRailTrailingWidget> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        packageInfo = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            auth.currentUser!.email!,
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton.icon(
            label: const Text('Sign out'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              auth.signOut();
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Text('Version: ${packageInfo?.version}',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('Build number: ${packageInfo?.buildNumber}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

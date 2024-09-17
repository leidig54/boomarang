import 'package:boomarang/providers/tab_provider.dart';
import 'package:boomarang/providers/user_provider.dart';
import 'package:boomarang/screens/create.dart';
import 'package:boomarang_shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    BoomarangUser? user = context.watch<UserProvider>().user;
    bool profileIsComplete = user?.profileIsComplete ?? false;
    bool hasReadGuide = user?.flags?['readGuide'] ?? false;

    String selected = 'create';

    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                "Dashboard",
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
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, bottom: 8.0, top: 32.0),
                        child: Text(
                          'Get Started',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ListTile(
                        title: const Text('Complete Profile'),
                        enabled: !profileIsComplete,
                        subtitle: const Text(
                            'Complete your profile to share with others when requesting data.'),
                        leading: profileIsComplete
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
                        onTap: () {
                          context.read<TabIndexProvider>().setTabIndex(3);
                        },
                      ),
                      ListTile(
                        title: const Text('Read The Guide'),
                        //TODO: Add Guide
                        enabled: false,
                        subtitle: const Text(
                            'Learn how to use Boomarang to request and share data.'),
                        leading: hasReadGuide
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
                        onTap: () {},
                      ),
                      //actions
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, bottom: 8.0, top: 32.0),
                        child: Text(
                          'Send',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ListTile(
                        title: const Text('Create New'),
                        subtitle: const Text(
                            'Want to request sensitive data? Send a Boomarang.'),
                        enabled: true,
                        leading: const Icon(Icons.send),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: selected == 'create'
                            ? Theme.of(context).highlightColor
                            : null,
                        onTap: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, bottom: 8.0, top: 32.0),
                        child: Text(
                          'Receive',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ListTile(
                        title: const Text('Letter'),
                        enabled: false,
                        subtitle: const Text(
                            "Received a paper request? We'll help you request it via Boomarang instead."),
                        leading: const Icon(Icons.mail),
                        onTap: () {},
                      ),
                      ListTile(
                        title: const Text('Website'),
                        enabled: false,
                        //TODO: Create website link
                        subtitle: const Text(
                            "Receive Boomarangs on your website - get a link to your portal here."),
                        leading: const Icon(Icons.web),
                        onTap: () {},
                      ),
                      //copy email forwarding link
                      ListTile(
                        title: const Text('Email'),
                        enabled: false,
                        //TODO: Create email forwarding
                        subtitle: const Text(
                            "Forward email requests to a dedicated inbox and we'll take care of the rest."),
                        leading: const Icon(Icons.alternate_email),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 0.5,
              ),
              const Expanded(
                flex: 2,
                child: CreateNewRequest(),
              )
            ],
          ),
        ),
      ],
    ));
  }
}

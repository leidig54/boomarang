import 'package:boomarang/dialogs/add_request.dart';
import 'package:boomarang/dialogs/request_boomarang.dart';
import 'package:boomarang/providers/tab_index_provider.dart';
import 'package:boomarang/providers/user_provider.dart';
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 32.0),
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
          enabled: !hasReadGuide,
          subtitle: const Text(
              'Learn how to use Boomarang to request and share data.'),
          leading: hasReadGuide
              ? const Icon(Icons.check_box)
              : const Icon(Icons.check_box_outline_blank),
          onTap: () {},
        ),
        //actions
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 32.0),
          child: Text(
            'Send',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Create New'),
          subtitle:
              const Text('Want to request sensitive data? Send a Boomarang.'),
          leading: const Icon(Icons.send),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreateBoomarangScreen(),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 32.0),
          child: Text(
            'Receive',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Letter'),
          subtitle: const Text(
              "Received a paper request? We'll help you request it via Boomarang instead."),
          leading: const Icon(Icons.mail),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const RequestBoomarangScreen(),
            );
          },
        ),
        ListTile(
          title: const Text('Website'),
          subtitle: const Text(
              "Receive Boomarangs on your website - get a link to your portal here."),
          leading: const Icon(Icons.web),
          onTap: () {},
        ),
        //copy email forwarding link
        ListTile(
          title: const Text('Email'),
          subtitle: const Text(
              "Forward email requests to a dedicated inbox and we'll take care of the rest."),
          leading: const Icon(Icons.alternate_email),
          onTap: () {
            //copy email to clipboard
            //TODO: Create a function to copy text to clipboard
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email copied to clipboard'),
              ),
            );
          },
        ),
      ],
    ));
  }
}

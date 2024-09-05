import 'package:boomarang/app/screens/add_request.dart';
import 'package:boomarang/app/screens/dialogs/request_boomarang.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
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
        //actions
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 32.0),
          child: Text(
            'Actions',
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
            'Share',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Request Boomarang'),
          subtitle: const Text(
              "If you've received a paper request and want it submitted via Boomarang"),
          leading: const Icon(Icons.add_task),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const RequestBoomarangScreen(),
            );
          },
        ),
        ListTile(
          title: const Text('Share Link'),
          subtitle: const Text(
              "Share your boomarang link with others to allow them to request data from you."),
          leading: const Icon(Icons.share),
          onTap: () {},
        ),
      ],
    ));
  }
}

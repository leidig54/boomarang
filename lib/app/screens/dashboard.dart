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
          padding: const EdgeInsets.only(left: 16.0, bottom: 16.0, top: 32.0),
          child: Text(
            'Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Create a Boomarang'),
          subtitle: const Text(
              'Want to request sensitive data? Create a new Boomarang.'),
          leading: const Icon(Icons.send),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreateBoomarangScreen(),
            );
          },
        ),
        ListTile(
          title: const Text('Request a Boomarang'),
          subtitle: const Text(
              "Useful if you've receive a paper request and want the sender to resubmit it via Boomarang."),
          leading: const Icon(Icons.add_task),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return const RequestBoomarangScreen();
                });
          },
        ),
      ],
    ));
  }
}

import 'package:boomarang/providers/sentbox_provider.dart';
import 'package:boomarang/screens/tabs/inbox/form.dart';
import 'package:boomarang/screens/tabs/inbox/meta.dart';
import 'package:boomarang/screens/tabs/inbox/tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  State<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  bool hideCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                "Inbox",
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
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  minWidth: 100,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        itemBuilder: (context, index) {
                          return RequestTile(
                            tileRequest: context
                                .watch<SentboxProvider>()
                                .requests[index],
                            isSelected: context
                                    .watch<SentboxProvider>()
                                    .selectedRequest
                                    ?.id ==
                                context
                                    .watch<SentboxProvider>()
                                    .requests[index]
                                    .id,
                            onTap: (request) {
                              context
                                  .read<SentboxProvider>()
                                  .selectRequest(request);
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(
                            indent: 8,
                            endIndent: 8,
                          );
                        },
                        itemCount:
                            context.watch<SentboxProvider>().requests.length,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (context.watch<SentboxProvider>().selectedRequest ==
                        null) {
                      return const Center(
                        child: Text("Select a request to view details"),
                      );
                    } else {
                      return RequestMeta(
                          selectedRequest: context
                              .watch<SentboxProvider>()
                              .selectedRequest!);
                    }
                  },
                ),
              ),
              const VerticalDivider(),
              Expanded(
                flex: 2,
                child: Builder(
                  builder: (context) {
                    if (context.watch<SentboxProvider>().selectedRequest ==
                        null) {
                      return const Center(
                        child: Text("Select a request to view details"),
                      );
                    } else {
                      return RequestForm(
                        selectedRequest:
                            context.watch<SentboxProvider>().selectedRequest!,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

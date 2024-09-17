import 'package:boomarang/providers/request_provider.dart';
import 'package:boomarang/screens/inbox/form.dart';
import 'package:boomarang/screens/shared/meta.dart';
import 'package:boomarang/screens/shared/tile.dart';
import 'package:boomarang_shared/models/request.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  BoomarangRequest? selectedRequest;
  bool hideCompleted = false;

  @override
  void didChangeDependencies() {
    if (selectedRequest == null) {
      selectedRequest =
          context.read<RequestProvider>().receivedRequests.firstOrNull;
    } else {
      selectedRequest = context
          .read<RequestProvider>()
          .receivedRequests
          .firstWhereOrNull((e) => e.id == selectedRequest!.id);
    }
    super.didChangeDependencies();
  }

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
                    CheckboxListTile(
                        value: hideCompleted,
                        tileColor: Theme.of(context).canvasColor,
                        onChanged: (value) {
                          setState(() {
                            hideCompleted = value ?? false;
                            if (value == true &&
                                selectedRequest?.responseSubmitted == true) {
                              selectedRequest = context
                                  .read<RequestProvider>()
                                  .receivedRequests
                                  .where((e) => !e.responseSubmitted)
                                  .firstOrNull;
                            }
                          });
                        },
                        title: const Text("Hide Completed"),
                        controlAffinity: ListTileControlAffinity.trailing),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        itemBuilder: (context, index) {
                          BoomarangRequest thisRequest = context
                              .watch<RequestProvider>()
                              .receivedRequests[index];

                          if (hideCompleted && thisRequest.responseSubmitted) {
                            return Container();
                          }

                          return RequestTile(
                            tileRequest: thisRequest,
                            isSelected: thisRequest.id == selectedRequest?.id,
                            onTap: (request) {
                              setState(() {
                                selectedRequest = thisRequest;
                              });
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          BoomarangRequest thisRequest = context
                              .watch<RequestProvider>()
                              .receivedRequests[index];

                          if (hideCompleted && thisRequest.responseSubmitted) {
                            return Container();
                          }
                          return const Divider(
                            indent: 8,
                            endIndent: 8,
                          );
                        },
                        itemCount: context
                            .watch<RequestProvider>()
                            .receivedRequests
                            .length,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                child: selectedRequest == null
                    ? Container()
                    : RequestMeta(
                        selectedRequest: selectedRequest!,
                        inbox: true,
                      ),
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                flex: 2,
                child: selectedRequest == null
                    ? Container()
                    : InboxRequestForm(selectedRequest: selectedRequest!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

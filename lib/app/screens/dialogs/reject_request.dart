import 'package:boomarang/main.dart';
import 'package:flutter/material.dart' hide Stepper, Step, StepperType;

class RejectRequestDialog extends StatefulWidget {
  const RejectRequestDialog({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<RejectRequestDialog> createState() => _RejectRequestDialogState();
}

class _RejectRequestDialogState extends State<RejectRequestDialog> {
  bool isLoading = false;
  TextEditingController reasonController = TextEditingController();

  List reasons = [
    'Insufficient information',
    'Innapproriate request',
    'Other',
  ];

  String value = '';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Are you sure you want to reject this request?'),
      children: [
        //radio list of reasons
        ...List.generate(
          reasons.length,
          (index) => RadioListTile(
            title: Text(reasons[index]),
            value: reasons[index],
            groupValue: value,
            onChanged: (value) {
              setState(() {
                this.value = value as String;
                if (value == 'Other') {
                  reasonController.text = '';
                } else {
                  reasonController.text = value;
                }
              });
            },
          ),
        ),
        if (value == 'Other')
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              autofocus: true,
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isLoading)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        await Future.delayed(const Duration(seconds: 1));
                        await functions.httpsCallable('rejectRequest').call({
                          'requestId': widget.id,
                          'reason': reasonController.text,
                        });
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Reject'),
              ),
            ],
          ),
        )
      ],
    );
  }
}

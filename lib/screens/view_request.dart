import 'package:boomarang/models/request.dart';
import 'package:flutter/material.dart';

class ViewRequestScreen extends StatefulWidget {
  const ViewRequestScreen({super.key, required this.request});

  final BoomarangRequest request;

  @override
  State<ViewRequestScreen> createState() => _ViewRequestScreenState();
}

class _ViewRequestScreenState extends State<ViewRequestScreen> {
  BoomarangRequest get request => widget.request;

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text("Authoriser"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: TextSpan(
                text: 'Name: ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text:
                          '${request.authoriserFirstName} ${request.authoriserLastName}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87))
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Date of Birth: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.formattedAuthoriserDob,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                //separator
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.black26,
                ),
                const SizedBox(width: 8),
                //dob verified
                RichText(
                  text: TextSpan(
                    text: 'DOB Verified: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.authoriserDOBVerified == true
                              ? 'Yes'
                              : 'No',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  request.authoriserDOBVerified == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: request.authoriserDOBVerified == true
                      ? Colors.green
                      : Colors.red,
                )
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Email: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.authoriserEmail,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                //separator
                Container(
                  height: 16,
                  width: 1,
                  color: Colors.black26,
                ),
                const SizedBox(width: 8),
                //email verified
                RichText(
                  text: TextSpan(
                    text: 'Email Verified: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: request.authoriserEmailVerified == true
                              ? 'Yes'
                              : 'No',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87))
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  request.authoriserEmailVerified == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: request.authoriserEmailVerified == true
                      ? Colors.green
                      : Colors.red,
                )
              ],
            ),
          ],
        ),
      ),
      Step(
        title: const Text("Consent"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //consent status
            RichText(
              text: TextSpan(
                text: 'Consent Status: ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: request.formattedConsentStatus,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87))
                ],
              ),
            ),
          ],
        ),
      )
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('View Request'),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${request.authoriserFirstName} ${request.authoriserLastName}',
                textAlign: TextAlign.end,
              ),
              //authoriserDOB
              Text(
                request.formattedAuthoriserDob,
                textAlign: TextAlign.end,
              ),
              Stepper(
                currentStep: _currentStep,
                onStepTapped: (step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
                onStepContinue: () {
                  setState(() {
                    if (_currentStep < steps.length - 1) {
                      _currentStep++;
                    }
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (_currentStep > 0) {
                      _currentStep--;
                    }
                  });
                },
                steps: steps,
              ),
            ],
          ),
        ));
  }
}

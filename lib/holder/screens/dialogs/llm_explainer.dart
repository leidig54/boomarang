import 'package:flutter/material.dart' hide Stepper, Step, StepperType;

class LlmExplainerDialog extends StatelessWidget {
  const LlmExplainerDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('AI Assistant'),
      contentPadding: const EdgeInsets.all(20),
      children: [
        Text("How does it work?",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(decoration: TextDecoration.underline)),
        const Text(
            'Boomarang AI uses the details of the request, along with the consultation data you upload, to generate a tailored report for the insurer.'),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Is it secure?",
          //underline
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(decoration: TextDecoration.underline),
        ),
        const Text(
            'Yes, all data is encrypted and stored securely. The subjects are fully consented before their data is shared, and the consultation data is only used for generating the report.\n\nThe consultation data is never made available to the insurer and is deleted immediately after the report is submitted.'),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Is is accurate?",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(decoration: TextDecoration.underline),
        ),
        const Text(
            "Boomarang AI uses the most advanced AI models available. It is capable of reliably extracting relevant information and producing accurate and detailed reports.\n\nHowever, the final report should always be reviewed by a medical professional before being submitted to the insurer."),
        const SizedBox(
          height: 20,
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'))
      ],
    );
  }
}

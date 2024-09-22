import 'package:boomarang_shared/models/boomarang_element.dart';
import 'package:boomarang_shared/models/request_form.dart';

List<RequestForm> forms = [
  RequestForm(
    id: 'veterinary_insurance_claim',
    name: "Veterinary Insurance Claim",
    description: "Claim for veterinary insurance.",
    elements: [
      FormElement(
        id: "symptom_start_date",
        labelText: "Symptom Start Date",
        type: "text",
        isRequired: true,
      ),
      //incident date
      FormElement(
        id: "consultation_date",
        labelText: "Treatment Date",
        type: "text",
        isRequired: true,
      ),
      //new or existing condition
      FormElement(
        id: "new_or_existing_condition",
        labelText: "New or Existing Condition",
        type: "radio",
        isRequired: true,
        options: [
          "New",
          "Existing",
        ],
      ),
      //diagnosis
      FormElement(
        id: "diagnosis",
        labelText: "Diagnosis",
        type: "text",
        isRequired: true,
      ),
      //treatment
      FormElement(
        id: "treatment",
        labelText: "Treatment",
        type: "text",
        expectedLines: 2,
        isRequired: true,
      ),
      //cost
      FormElement(
        id: "cost",
        labelText: "Cost",
        type: "text",
        isRequired: true,
      ),
    ],
  )
];

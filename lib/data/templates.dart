import 'package:boomarang_shared/models/boomarang_element.dart';
import 'package:boomarang_shared/models/request_form.dart';

List<RequestForm> b2bForms = [
  // 1. Employee Background Check Details
  RequestForm(
    id: 'employee_background_check_request',
    name: 'Employee Background Check Details',
    description: 'Details regarding the background check of the employee.',
    elements: [
      FormElement(
        id: 'context_statement',
        type: 'statement',
        text:
            'This request is regarding the background check performed for an employee.',
      ),
      FormElement(
        id: 'criminal_record_check',
        labelText: 'Has the employee passed the criminal record check?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'employment_history',
        labelText: 'Was the employee\'s employment history verified?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'employment_history_details',
        labelText: 'If yes, provide employment history details',
        helperText: 'Include company names, positions, and dates of employment',
        type: 'text',
        isRequired: false,
      ),
      FormElement(
        id: 'additional_comments',
        labelText: 'Additional Comments',
        helperText: 'Provide any additional details or comments',
        type: 'text',
        isRequired: false,
      ),
    ],
  ),

  // 2. Medical Records for Insurance Claim
  RequestForm(
    id: 'medical_records_insurance_claim_request',
    name: 'Medical Records for Insurance Claim',
    description:
        'Request for medical records related to the treatment of the patient for the purpose of an insurance claim.',
    elements: [
      FormElement(
        id: 'context_statement',
        type: 'statement',
        text:
            'This request is regarding the medical records of the patient related to a specific treatment.',
      ),
      FormElement(
        id: 'diagnosis_details',
        labelText: 'Diagnosis Details',
        helperText:
            'Please provide the diagnosis and relevant medical history.',
        type: 'text',
        isRequired: true,
      ),
      FormElement(
        id: 'treatment_administered',
        labelText: 'Treatment Administered',
        helperText: 'Describe the treatment given during the consultation.',
        type: 'text',
        isRequired: true,
      ),
      FormElement(
        id: 'follow_up_required',
        labelText: 'Is follow-up treatment required?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'additional_medical_information',
        labelText: 'Additional Medical Information',
        helperText:
            'Provide any other relevant medical information or details.',
        type: 'text',
        isRequired: false,
      ),
    ],
  ),

  // 3. Academic Transcript
  RequestForm(
    id: 'academic_transcript_request',
    name: 'Academic Transcript',
    description: 'Request for academic transcript details for the student.',
    elements: [
      FormElement(
        id: 'context_statement',
        type: 'statement',
        text:
            'This request is regarding the academic transcript of the student from the university.',
      ),
      FormElement(
        id: 'degree_awarded',
        labelText: 'Was the student awarded a degree?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'degree_details',
        labelText: 'If yes, provide the degree details',
        helperText: 'Include the degree name, major, and graduation date.',
        type: 'text',
        isRequired: false,
      ),
      FormElement(
        id: 'academic_performance',
        labelText: 'Provide academic performance details',
        helperText:
            'Include GPA, honors, or any other relevant academic performance metrics.',
        type: 'text',
        isRequired: true,
      ),
      FormElement(
        id: 'additional_academic_info',
        labelText: 'Additional Academic Information',
        helperText:
            'Provide any additional information about the student\'s academic history.',
        type: 'text',
        isRequired: false,
      ),
    ],
  ),

  // 4. Rental Payment History
  RequestForm(
    id: 'rental_payment_history_request',
    name: 'Rental Payment History',
    description:
        'Request for rental payment history for the tenant during their tenancy with the previous landlord.',
    elements: [
      FormElement(
        id: 'context_statement',
        type: 'statement',
        text:
            'This request is regarding rental payment history during the tenancy.',
      ),
      FormElement(
        id: 'rent_paid_on_time',
        labelText: 'Did the tenant consistently pay rent on time?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'late_payment_count',
        labelText: 'If no, how many times was rent paid late?',
        type: 'text',
        isRequired: false,
      ),
      FormElement(
        id: 'damage_to_property',
        labelText: 'Was there any damage to the property caused by the tenant?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'deposit_withheld',
        labelText: 'Was any part of the deposit withheld?',
        type: 'radio',
        options: ['Yes', 'No'],
        isRequired: true,
      ),
      FormElement(
        id: 'deposit_withheld_reason',
        labelText: 'If yes, provide the reason for withholding the deposit',
        type: 'text',
        isRequired: false,
      ),
    ],
  ),

  // 5. Client Financial Records
  RequestForm(
    id: 'client_financial_records_request',
    name: 'Client Financial Records',
    description: 'Request for financial records necessary for securing a loan.',
    elements: [
      FormElement(
        id: 'context_statement',
        type: 'statement',
        text:
            'This request is regarding the client\'s financial records necessary to support their loan application.',
      ),
      FormElement(
        id: 'balance_sheet',
        labelText: 'Please provide the client\'s most recent balance sheet',
        helperText:
            'Attach or describe the latest balance sheet including assets and liabilities.',
        type: 'text',
        isRequired: true,
      ),
      FormElement(
        id: 'profit_loss_statement',
        labelText:
            'Please provide the client\'s most recent profit and loss statement',
        helperText: 'Attach or describe the profit and loss statement.',
        type: 'text',
        isRequired: true,
      ),
      FormElement(
        id: 'cash_flow_statement',
        labelText:
            'Please provide the client\'s most recent cash flow statement',
        helperText: 'Attach or describe the cash flow statement.',
        type: 'text',
        isRequired: true,
      ),
      FormElement(
        id: 'additional_financial_info',
        labelText: 'Additional Financial Information',
        helperText:
            'Provide any other relevant financial information regarding the client.',
        type: 'text',
        isRequired: false,
      ),
    ],
  ),
];

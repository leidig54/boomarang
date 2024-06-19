// ignore_for_file: public_member_api_docs, sort_constructors_first
class BoomarangResponse {
  String id;
  String? consultationFormRef;
  String? consultationDetails;
  dynamic report;
  bool? isSubmitted;
  BoomarangResponse({
    required this.id,
    required this.consultationFormRef,
    this.consultationDetails,
    this.report,
    this.isSubmitted,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'consultationFormRef': consultationFormRef,
      'consultationDetails': consultationDetails,
      'report': report,
      'isSubmitted': isSubmitted,
    };
  }

  factory BoomarangResponse.fromMap(Map<String, dynamic> map) {
    return BoomarangResponse(
      id: (map['id']) as String,
      consultationFormRef: map['consultationFormRef'] != null
          ? map['consultationFormRef'] as String
          : null,
      consultationDetails: map['consultationDetails'] != null
          ? map['consultationDetails'] as String
          : null,
      report: map['report'] as dynamic,
      isSubmitted:
          map['isSubmitted'] != null ? map['isSubmitted'] as bool : null,
    );
  }
}

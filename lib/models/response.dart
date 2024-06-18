// ignore_for_file: public_member_api_docs, sort_constructors_first
class BoomarangResponse {
  String id;
  String consultationsFormRef;
  BoomarangResponse({
    required this.id,
    required this.consultationsFormRef,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'consultationsFormRef': consultationsFormRef,
    };
  }

  factory BoomarangResponse.fromMap(Map<String, dynamic> map) {
    return BoomarangResponse(
      id: (map['id']) as String,
      consultationsFormRef: (map['consultationsFormRef']) as String,
    );
  }
}

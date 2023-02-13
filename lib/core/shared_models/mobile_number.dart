class MobileNumber {
  late String extension;
  late String withExtension;
  late String withoutExtension;

  MobileNumber.fromJson(Map<String, dynamic> json) {
    extension = json['extension'];
    withExtension = json['withExtension'];
    withoutExtension = json['withoutExtension'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['extension'] = extension;
    data['withExtension'] = withExtension;
    data['withoutExtension'] = withoutExtension;
    return data;
  }
}
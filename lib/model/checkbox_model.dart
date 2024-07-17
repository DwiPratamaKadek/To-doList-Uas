class CheckboxModel {
  int? id;
  int titleId;
  String? title;
  bool isChecked;

  CheckboxModel({
    this.id,
    required this.titleId,
    this.title,
    required this.isChecked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleId': titleId,
      'title': title,
      'isChecked': isChecked ? 1 : 0,
    };
  }

  factory CheckboxModel.fromMap(Map<String, dynamic> map) {
    return CheckboxModel(
      id: map['id'],
      titleId: map['titleId'],
      title: map['title'],
      isChecked: map['isChecked'] == 1,
    );
  }
}

class TitleModel {
  int? id;
  String? title;
  String? deskripsi;

  TitleModel({
    this.id,
    this.title,
    this.deskripsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deskripsi': deskripsi,
    };
  }

  factory TitleModel.fromMap(Map<String, dynamic> map) {
    return TitleModel(
      id: map['id'],
      title: map['title'],
      deskripsi: map['deskripsi'],
    );
  }
}

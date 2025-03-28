import 'package:copy_with_extension/copy_with_extension.dart';

part 'api_model.g.dart';

@CopyWith()
class ApiModel {
  List<dynamic>? favorite = [];
  List<dynamic>? books = [];
  int? index;
  bool? theme;
  String? language;

  ApiModel({
    this.theme,
    this.language,
    this.favorite,
    this.books,
    this.index,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiModel &&
          favorite == other.favorite &&
          theme == other.theme &&
          language == other.language &&
          books == other.books &&
          index == other.index);
}

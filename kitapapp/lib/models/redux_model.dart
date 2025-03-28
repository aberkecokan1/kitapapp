import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:kitapapp/models/api_model.dart';

part 'redux_model.g.dart';

@CopyWith()
class ReduxModel {
  final ApiModel apiModel;

  ReduxModel({
    required this.apiModel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReduxModel && apiModel == other.apiModel);
}

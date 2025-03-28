// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redux_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReduxModelCWProxy {
  ReduxModel apiModel(ApiModel apiModel);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReduxModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReduxModel(...).copyWith(id: 12, name: "My name")
  /// ````
  ReduxModel call({
    ApiModel? apiModel,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReduxModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReduxModel.copyWith.fieldName(...)`
class _$ReduxModelCWProxyImpl implements _$ReduxModelCWProxy {
  final ReduxModel _value;

  const _$ReduxModelCWProxyImpl(this._value);

  @override
  ReduxModel apiModel(ApiModel apiModel) => this(apiModel: apiModel);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReduxModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReduxModel(...).copyWith(id: 12, name: "My name")
  /// ````
  ReduxModel call({
    Object? apiModel = const $CopyWithPlaceholder(),
  }) {
    return ReduxModel(
      apiModel: apiModel == const $CopyWithPlaceholder() || apiModel == null
          ? _value.apiModel
          // ignore: cast_nullable_to_non_nullable
          : apiModel as ApiModel,
    );
  }
}

extension $ReduxModelCopyWith on ReduxModel {
  /// Returns a callable class that can be used as follows: `instanceOfReduxModel.copyWith(...)` or like so:`instanceOfReduxModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReduxModelCWProxy get copyWith => _$ReduxModelCWProxyImpl(this);
}

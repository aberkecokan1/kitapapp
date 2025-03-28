// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiModelCWProxy {
  ApiModel books(List<dynamic>? books);

  ApiModel favorite(List<dynamic>? favorite);

  ApiModel index(int? index);

  ApiModel language(String? language);

  ApiModel theme(bool? theme);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiModel(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiModel call({
    List<dynamic>? books,
    List<dynamic>? favorite,
    int? index,
    String? language,
    bool? theme,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiModel.copyWith.fieldName(...)`
class _$ApiModelCWProxyImpl implements _$ApiModelCWProxy {
  final ApiModel _value;

  const _$ApiModelCWProxyImpl(this._value);

  @override
  ApiModel books(List<dynamic>? books) => this(books: books);

  @override
  ApiModel favorite(List<dynamic>? favorite) => this(favorite: favorite);

  @override
  ApiModel index(int? index) => this(index: index);

  @override
  ApiModel language(String? language) => this(language: language);

  @override
  ApiModel theme(bool? theme) => this(theme: theme);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiModel(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiModel call({
    Object? books = const $CopyWithPlaceholder(),
    Object? favorite = const $CopyWithPlaceholder(),
    Object? index = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? theme = const $CopyWithPlaceholder(),
  }) {
    return ApiModel(
      books: books == const $CopyWithPlaceholder()
          ? _value.books
          // ignore: cast_nullable_to_non_nullable
          : books as List<dynamic>?,
      favorite: favorite == const $CopyWithPlaceholder()
          ? _value.favorite
          // ignore: cast_nullable_to_non_nullable
          : favorite as List<dynamic>?,
      index: index == const $CopyWithPlaceholder()
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as String?,
      theme: theme == const $CopyWithPlaceholder()
          ? _value.theme
          // ignore: cast_nullable_to_non_nullable
          : theme as bool?,
    );
  }
}

extension $ApiModelCopyWith on ApiModel {
  /// Returns a callable class that can be used as follows: `instanceOfApiModel.copyWith(...)` or like so:`instanceOfApiModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiModelCWProxy get copyWith => _$ApiModelCWProxyImpl(this);
}

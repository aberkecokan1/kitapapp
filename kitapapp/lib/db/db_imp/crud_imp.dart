import 'package:hive/hive.dart';
import 'package:kitapapp/db/storage.dart';

class HiveBoxService implements IStorageService {
  final String boxName;
  Box<dynamic>? _box;

  HiveBoxService(this.boxName);

  // Box'ı açma ve önbelleğe alma
  Future<Box<dynamic>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(boxName);
    }
    return _box!;
  }

  @override
  Future<void> save(String key, dynamic value) async {
    final box = await _getBox();
    await box.put(key, value);
  }

  @override
  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    final box = await _getBox();
    return box.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> delete(String key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  @override
  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}

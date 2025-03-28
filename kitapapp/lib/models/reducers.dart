import 'package:kitapapp/models/redux_model.dart';
import 'package:kitapapp/models/actions.dart';

ReduxModel reducer(ReduxModel prevState, dynamic action) {
  final ReduxModel newstate = prevState.copyWith();

  if (action is UpdateStateAction) {
    return prevState.copyWith(apiModel: action.payload);
  }

  return newstate;
}

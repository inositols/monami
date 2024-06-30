import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monami/src/presentation/views/view_models/base_model.dart';

final userId = ChangeNotifierProvider((ref) => UserIdViewModel());

class UserIdViewModel extends BaseViewModel {}

import 'package:flutter_riverpod/legacy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:monami/src/presentation/views/view_models/base_model.dart';

final authServiceProvider = ChangeNotifierProvider((ref) => BaseViewModel());

import 'package:flutter/material.dart';

import '../injection.dart';
import '../services/navigation_service.dart';

final BuildContext context =
    getIt<NavigationService>().navigationKey.currentContext!;
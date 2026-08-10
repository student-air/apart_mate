// lib/domain/repositories/i_dashboard_repository.dart

import 'package:apart_mate/data/models/dashboard_models.dart';

abstract class IDashboardRepository {
  Future<DashboardData> getDashboardData(String userId);
}
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../feature/jadwal/service/jadwal.service.dart';
import '../../feature/jadwal/repository/jadwal.repo.dart';
import '../../feature/jadwal/presentation/viewmodel/jadwal.viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  debugPrint('🚀 Initializing dependencies...');

  sl.registerLazySingleton<http.Client>(() => http.Client());
  debugPrint('✅ HTTP Client registered');

  sl.registerLazySingleton<JadwalService>(
    () => JadwalServiceImpl(client: sl()),
  );
  debugPrint('✅ JadwalService registered');

  sl.registerLazySingleton<JadwalRepository>(
    () => JadwalRepositoryImpl(service: sl()),
  );
  debugPrint('✅ JadwalRepository registered');

  sl.registerFactory<JadwalViewModel>(() => JadwalViewModel(repository: sl()));
  debugPrint('✅ JadwalViewModel registered');

  debugPrint('🎉 All dependencies initialized successfully!');
}

Future<void> dispose() async {
  final client = sl<http.Client>();
  client.close();

  await sl.reset();
}

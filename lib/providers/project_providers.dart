import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/project_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(databaseProvider));
});

final allProjectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAll();
});

final projectByIdProvider = FutureProvider.family<Project?, int>((ref, id) {
  return ref.read(projectRepositoryProvider).getById(id);
});

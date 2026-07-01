import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/screens/primary/opportunities_screen.dart';
import 'package:ciaraos/screens/primary/projects_screen.dart';
import 'package:ciaraos/screens/primary/review_screen.dart';
import 'package:ciaraos/screens/primary/tasks_screen.dart';
import 'package:ciaraos/screens/primary/today_screen.dart';
import 'package:ciaraos/screens/secondary/onboarding_screen.dart';
import 'package:ciaraos/screens/secondary/opportunity_create_edit_screen.dart';
import 'package:ciaraos/screens/secondary/opportunity_detail_screen.dart';
import 'package:ciaraos/screens/secondary/project_create_edit_screen.dart';
import 'package:ciaraos/screens/secondary/project_detail_screen.dart';
import 'package:ciaraos/screens/secondary/task_create_edit_screen.dart';
import 'package:ciaraos/screens/secondary/task_detail_screen.dart';
import 'package:ciaraos/widgets/navigation/primary_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarding = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: onboarding,
    redirect: (context, state) {
      if (!onboarding.isLoaded) {
        return null;
      }

      final location = state.matchedLocation;
      final onOnboarding = location == '/onboarding';

      if (!onboarding.isComplete && !onOnboarding) {
        return '/onboarding';
      }
      if (onboarding.isComplete && onOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return PrimaryShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/opportunities',
            builder: (context, state) => const OpportunitiesScreen(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) => const ReviewScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskCreateEditScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/projects/new',
        builder: (context, state) => const ProjectCreateEditScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/opportunities/new',
        builder: (context, state) => const OpportunityCreateEditScreen(),
      ),
      GoRoute(
        path: '/opportunities/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OpportunityDetailScreen(opportunityId: id);
        },
      ),
    ],
  );
});

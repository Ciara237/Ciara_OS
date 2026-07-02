import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/screens/primary/opportunities_screen.dart';
import 'package:ciaraos/screens/primary/projects_screen.dart';
import 'package:ciaraos/screens/primary/review_screen.dart';
import 'package:ciaraos/screens/primary/tasks_screen.dart';
import 'package:ciaraos/screens/primary/today_screen.dart';
import 'package:ciaraos/screens/secondary/onboarding_screen.dart';
import 'package:ciaraos/screens/secondary/opportunity_create_edit_screen.dart';
import 'package:ciaraos/screens/secondary/opportunity_detail_screen.dart';
import 'package:ciaraos/screens/secondary/settings_screen.dart';
import 'package:ciaraos/screens/secondary/profile_screen.dart';
import 'package:ciaraos/screens/analytics/completed_tasks_screen.dart';
import 'package:ciaraos/screens/analytics/domain_breakdown_screen.dart';
import 'package:ciaraos/screens/analytics/planning_accuracy_screen.dart';
import 'package:ciaraos/screens/analytics/productivity_trends_screen.dart';
import 'package:ciaraos/screens/knowledge/note_editor_screen.dart';
import 'package:ciaraos/screens/knowledge/notes_screen.dart';
import 'package:ciaraos/screens/knowledge/resources_screen.dart';
import 'package:ciaraos/screens/skills/certifications_screen.dart';
import 'package:ciaraos/screens/skills/security_practice_screen.dart';
import 'package:ciaraos/screens/skills/github_activity_screen.dart';
import 'package:ciaraos/screens/skills/github_repositories_screen.dart';
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
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/skills/github',
        builder: (context, state) => const GitHubActivityScreen(),
        routes: [
          GoRoute(
            path: 'repos',
            builder: (context, state) => const GitHubRepositoriesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/skills/ctf',
        builder: (context, state) => const SecurityPracticeScreen(),
      ),
      GoRoute(
        path: '/skills/certifications',
        builder: (context, state) => const CertificationsScreen(),
      ),
      GoRoute(
        path: '/analytics/trends',
        builder: (context, state) => const ProductivityTrendsScreen(),
      ),
      GoRoute(
        path: '/analytics/domains',
        builder: (context, state) => const DomainBreakdownScreen(),
      ),
      GoRoute(
        path: '/analytics/accuracy',
        builder: (context, state) => const PlanningAccuracyScreen(),
      ),
      GoRoute(
        path: '/knowledge/notes/new',
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        path: '/knowledge/notes/:id',
        builder: (context, state) => NoteEditorScreen(
          noteId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/knowledge/notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/knowledge/resources',
        builder: (context, state) => const ResourcesScreen(),
      ),
      GoRoute(
        path: '/tasks/completed',
        builder: (context, state) => const CompletedTasksScreen(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => TaskCreateEditScreen(
          taskId: null,
          initialProjectId: state.uri.queryParameters['projectId'],
          initialTitle: state.uri.queryParameters['title'],
        ),
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskCreateEditScreen(taskId: id);
        },
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
        builder: (context, state) =>
            const ProjectCreateEditScreen(projectId: null),
      ),
      GoRoute(
        path: '/projects/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectCreateEditScreen(projectId: id);
        },
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
        builder: (context, state) =>
            const OpportunityCreateEditScreen(opportunityId: null),
      ),
      GoRoute(
        path: '/opportunities/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OpportunityCreateEditScreen(opportunityId: id);
        },
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

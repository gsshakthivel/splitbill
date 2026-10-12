import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:splitbill_frontend/features/expenses/presentation/screens/expense_details_screen.dart';
import 'package:splitbill_frontend/features/groups/presentation/screens/create_group_screen.dart';
import 'package:splitbill_frontend/features/groups/presentation/screens/group_details_screen.dart';
import 'package:splitbill_frontend/features/home/presentation/screens/home_screen.dart';
import 'package:splitbill_frontend/features/auth/presentation/screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.value != null;
      final isPublicRoute =
          state.matchedLocation == '/' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isPublicRoute) {
        return '/';
      }

      if (isLoggedIn && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) {
          return const CreateGroupScreen();
        },
      ),
      GoRoute(
        path: '/groups/:groupId',
        builder: (context, state) {
          final groupId = int.parse(state.pathParameters['groupId']!);

          return GroupDetailsScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/groups/:groupId/expenses/:expenseId',
        builder: (context, state) {
          final groupId = int.parse(state.pathParameters['groupId']!);

          final expenseId = int.parse(state.pathParameters['expenseId']!);

          return ExpenseDetailsScreen(groupId: groupId, expenseId: expenseId);
        },
      ),
    ],
  );

  ref.listen(authNotifierProvider, (_, _) {
    router.refresh();
  });

  ref.onDispose(router.dispose);

  return router;
});

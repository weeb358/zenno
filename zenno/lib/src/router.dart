import 'package:go_router/go_router.dart';
import 'package:zenno/screen/auth/login.dart';
import 'package:zenno/screen/auth/signup.dart';
import 'package:zenno/screen/auth/forgot_password.dart';
import 'package:zenno/screen/auth/change_password.dart';
import 'package:zenno/screen/splashscreen.dart';
import 'package:zenno/screen/mainscreen.dart';
import 'package:zenno/screen/homescreen.dart';
import 'package:zenno/screen/profile.dart';
import 'package:zenno/screen/game_description.dart';
import 'package:zenno/screen/checkout.dart';
import 'package:zenno/screen/checkout_success.dart';
import 'package:zenno/screen/store/browse_categories.dart';
import 'package:zenno/screen/store/search_games.dart';
import 'package:zenno/screen/cart/wallet_top_up.dart';
import 'package:zenno/screen/cart/transaction_history.dart';
import 'package:zenno/screen/library/library_details.dart';
import 'package:zenno/screen/profile/notifications.dart';
import 'package:zenno/screen/profile/settings.dart';
import 'package:zenno/screen/menu/history.dart';
import 'package:zenno/screen/menu/support.dart';
import 'package:zenno/screen/menu/feedback.dart';
import 'package:zenno/screen/chat/chatbot.dart';
import 'package:zenno/screen/admin/admin_dashboard.dart';
import 'package:zenno/screen/admin/admin_users.dart';
import 'package:zenno/screen/admin/admin_games.dart';
import 'package:zenno/screen/admin/admin_add_game.dart';
import 'package:zenno/screen/admin/admin_edit_game.dart';
import 'package:zenno/screen/admin/admin_upcoming_games.dart';
import 'package:zenno/screen/admin/admin_add_upcoming_game.dart';
import 'package:zenno/screen/admin/admin_notifications.dart';
import 'package:zenno/screen/admin/admin_settings.dart';
import 'package:zenno/screen/cart/cart_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreen(),
    ),
    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const Authenticator(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    // Store routes
    GoRoute(
      path: '/home',
      builder: (context, state) => const Homescreen(),
    ),
    GoRoute(
      path: '/browse-categories',
      builder: (context, state) => const BrowseCategoriesScreen(),
    ),
    GoRoute(
      path: '/search-games',
      builder: (context, state) => const SearchGamesScreen(),
    ),
    GoRoute(
      path: '/game-description',
      builder: (context, state) => const GameDescriptionScreen(
        gameName: 'Game',
        gamePrice: '\$29.99',
      ),
    ),
    // Cart & Wallet routes
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(
        gameName: 'Game',
        gamePrice: '\$29.99',
      ),
    ),
    GoRoute(
      path: '/checkout-success',
      builder: (context, state) => const CheckoutSuccessScreen(
        gameName: 'Game',
      ),
    ),
    GoRoute(
      path: '/wallet-top-up',
      builder: (context, state) => const WalletTopUpScreen(),
    ),
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    // Library routes
    GoRoute(
      path: '/library-details',
      builder: (context, state) => const LibraryDetailsScreen(),
    ),
    // Profile routes
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // Menu routes
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    // Chat route
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => const ChatbotScreen(),
    ),
    // Admin routes
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin-users',
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: '/admin-games',
      builder: (context, state) => const AdminGamesScreen(),
    ),
    GoRoute(
      path: '/admin-add-game',
      builder: (context, state) => const AdminAddGameScreen(),
    ),
    GoRoute(
      path: '/admin-edit-game/:gameId',
      builder: (context, state) => AdminEditGameScreen(
        gameId: state.pathParameters['gameId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/admin-upcoming-games',
      builder: (context, state) => const AdminUpcomingGamesScreen(),
    ),
    GoRoute(
      path: '/admin-add-upcoming-game',
      builder: (context, state) => const AdminAddUpcomingGameScreen(),
    ),
    GoRoute(
      path: '/admin-edit-upcoming-game/:id',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AdminAddUpcomingGameScreen(
          gameId: state.pathParameters['id'] ?? '',
          existingData: extra,
        );
      },
    ),
    GoRoute(
      path: '/admin-notifications',
      builder: (context, state) => const AdminNotificationsScreen(),
    ),
    GoRoute(
      path: '/admin-settings',
      builder: (context, state) => const AdminSettingsScreen(),
    ),
  ],
);

import 'package:birriadon/screens/home/home_screen.dart';
import 'package:birriadon/screens/orders/orders_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(initialLocation: "/", routes: [
  GoRoute(path: '/', builder: (context, state) => HomeScreen()),
  GoRoute(path: '/orders', builder: (context, state) => OrderScreen()),
]);

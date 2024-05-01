import 'package:birriadon/firebase_options.dart';
import 'package:birriadon/screens/home/home_screen.dart';
import 'package:birriadon/screens/orders/corte_screen.dart';
import 'package:birriadon/screens/orders/gasto_screen.dart';
import 'package:birriadon/screens/orders/orders_screen.dart';
import 'package:birriadon/screens/orders/resumen_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.pinkAccent),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Mostrar la notificación en la pantalla
        // Puedes utilizar un paquete de notificaciones como flutter_local_notifications para mostrar las notificaciones
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: SafeArea(
          child: TabBarView(
            children: [
              HomeScreen(),
              OrderScreen(),
              CorteScreen(),
              GastoScreen(),
              ResumenScreen(),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            top: 8.0, // Ajusta el espacio superior según sea necesario
          ),
          child: Container(
            color: Theme.of(context)
                .primaryColor, // Color de fondo de la barra de navegación
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                Tab(icon: Icon(Icons.shopping_cart), text: 'Orders'),
                Tab(icon: Icon(Icons.shopify), text: 'Corte'),
                Tab(icon: Icon(Icons.monetization_on), text: 'Gasto Semanal'),
                Tab(icon: Icon(Icons.stacked_line_chart_sharp), text: 'Gains'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

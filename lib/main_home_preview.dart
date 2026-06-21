import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/trips_provider.dart';
import 'providers/cars_provider.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HomePreviewApp());
}

class HomePreviewApp extends StatelessWidget {
  const HomePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => CarsProvider()),
      ],
      child: MaterialApp(
        title: 'HomePage Preview',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const IPhoneFrame(),
      ),
    );
  }
}

/// iPhone 16 Pro Max frame (430x932)
class IPhoneFrame extends StatelessWidget {
  const IPhoneFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Container(
          width: 430,
          height: 932,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.grey.shade800, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42),
            child: const HomePagePreview(),
          ),
        ),
      ),
    );
  }
}

/// Preview версия HomePage без go_router
class HomePagePreview extends StatefulWidget {
  const HomePagePreview({super.key});

  @override
  State<HomePagePreview> createState() => _HomePagePreviewState();
}

class _HomePagePreviewState extends State<HomePagePreview> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  int _selectedIndex = 0;
  bool _isDriver = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  String _getButtonText() {
    final from = _fromController.text.isEmpty ? 'a' : _fromController.text;
    final to = _toController.text.isEmpty ? 'b' : _toController.text;
    return '[changeTextOnButton($from, $to)]';
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E0F0),
      body: SafeArea(
        child: Column(
          children: [
            // Изображение путешественников
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/travelers.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Белая карточка с формой
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Поле "Откуда"
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _fromController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Откуда[From]',
                                hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      
                      // Поле "Куда"
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _toController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Куда [To]',
                                hintStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Кнопки выбора типа
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDriver = true),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isDriver ? Colors.deepPurple : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: _isDriver ? Colors.deepPurple.withValues(alpha: 0.1) : Colors.white,
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  size: 40,
                                  color: _isDriver ? Colors.deepPurple : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDriver = false),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: !_isDriver ? Colors.deepPurple : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: !_isDriver ? Colors.deepPurple.withValues(alpha: 0.1) : Colors.white,
                                ),
                                child: Icon(
                                  Icons.hail,
                                  size: 40,
                                  color: !_isDriver ? Colors.deepPurple : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Кнопка поиска
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Поиск: ${_fromController.text} → ${_toController.text}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4FCF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getButtonText(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTap,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                label: 'MyTrips',
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Выйти',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

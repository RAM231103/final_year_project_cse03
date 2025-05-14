import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:legal_assistant_chatbot/models/language_option.dart'; // Import for LanguageOption and appLanguages
import 'package:legal_assistant_chatbot/widgets/language_selector.dart';
import 'package:legal_assistant_chatbot/screens/AuthScreen.dart';
import 'package:legal_assistant_chatbot/screens/chatbot_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/legal_topics_screen.dart';
import 'services/localization_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Get saved preferences
  final prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString('language_code') ?? 'en';
  bool isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  
  runApp(MyApp(
    initialLocale: LocalizationService.getLocaleFromLanguage(languageCode),
    isDarkMode: isDarkMode,
  ));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  final bool isDarkMode;
  
  const MyApp({
    super.key, 
    required this.initialLocale,
    required this.isDarkMode,
  });
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _isDarkMode;
  late String _currentLanguage;
  final AuthService _authService = AuthService();
  User? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _isDarkMode = widget.isDarkMode;
    _currentLanguage = _locale.languageCode;
    
    // Check if user is already signed in
    _checkCurrentUser();
    
    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }
  
  Future<void> _checkCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUser = user;
    });
  }
  
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      _currentLanguage = locale.languageCode;
    });
    LocalizationService.setLanguage(locale.languageCode);
  }
  
  void _changeLanguage(String languageCode) {
    _setLocale(LocalizationService.getLocaleFromLanguage(languageCode));
  }
  
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _saveThemePreference(_isDarkMode);
  }
  
  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDarkMode);
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal Assistant',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _currentUser == null 
          ? AuthScreen(authService: _authService)
          : HomeScreen(
              changeLocale: _setLocale,
              changeLanguage: _changeLanguage,
              currentLanguage: _currentLanguage,
              toggleTheme: _toggleTheme,
              isDarkMode: _isDarkMode,
              authService: _authService,
            ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final Function(String) changeLanguage;
  final String currentLanguage;
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final AuthService authService;
  
  const HomeScreen({
    super.key, 
    required this.changeLocale,
    required this.changeLanguage,
    required this.currentLanguage,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.authService,
  });
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _signOut() async {
    await widget.authService.signOut();
  }
  
  String _getLocalizedTitle() {
    final titles = {
      'en': 'Legal Assistant',
      'es': 'Asistente Legal',
      'fr': 'Assistant Juridique',
      'de': 'Rechtsassistent',
      'hi': 'कानूनी सहायक',
      'te': 'చట్ట సహాయకుడు',
      'kn': 'ಕಾನೂನು ಸಹಾಯಕ',
    };
    
    return titles[widget.currentLanguage] ?? titles['en']!;
  }
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedTitle()),
        actions: [
          // Language selector
          LanguageSelector(
            currentLanguage: widget.currentLanguage,
            onLanguageChanged: widget.changeLanguage,
            languages: appLanguages, // Using appLanguages from models/language_option.dart
          ),
          
          // Theme toggle
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
            tooltip: widget.isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
          ),
          
          // User profile/logout button
          if (user != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _signOut();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoURL != null 
                          ? NetworkImage(user.photoURL!) 
                          : null,
                      child: user.photoURL == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(user.displayName ?? 'User'),
                    subtitle: Text(user.email ?? ''),
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sign out'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SimpleChatScreen(
            currentLanguage: widget.currentLanguage,
            languages: appLanguages, // Using appLanguages from models/language_option.dart
            apiKey: 'AIzaSyCCf5fvtxPuWfHezWW0x8hICn4cz8fmOM4',
          ),
          LegalTopicsScreen(
            changeLocale: widget.changeLocale,
            currentLanguage: widget.currentLanguage, 
            changeLanguage: widget.changeLanguage,
            apiKey: 'AIzaSyCCf5fvtxPuWfHezWW0x8hICn4cz8fmOM4',
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: _getLocalizedText({
              'en': 'Legal Assistant',
              'es': 'Asistente Legal',
              'fr': 'Assistant Juridique',
              'de': 'Rechtsassistent',
              'hi': 'कानूनी सहायक',
              'te': 'చట్ట సహాయకుడు',
              'kn': 'ಕಾನೂನು ಸಹಾಯಕ',
            }),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.gavel),
            label: _getLocalizedText({
              'en': 'Legal Topics',
              'es': 'Temas Legales',
              'fr': 'Sujets Juridiques',
              'de': 'Rechtsthemen',
              'hi': 'कानूनी विषय',
              'te': 'చట్టపరమైన అంశాలు',
              'kn': 'ಕಾನೂನು ವಿಷಯಗಳು',
            }),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  
  String _getLocalizedText(Map<String, String> textMap) {
    return textMap[widget.currentLanguage] ?? textMap['en'] ?? "Text not found";
  }
}
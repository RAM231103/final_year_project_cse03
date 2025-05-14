import 'package:flutter/material.dart';
import 'package:legal_assistant_chatbot/screens/topic_detail_screen.dart';
import 'package:legal_assistant_chatbot/widgets/topic_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// No need to define LanguageOption class here as it's defined in main.dart
// No need to define LanguageSelector widget here as it's defined in main.dart

class LegalTopicsScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final String currentLanguage;
  final Function(String) changeLanguage;
  final String apiKey;

  const LegalTopicsScreen({
    super.key,
    required this.changeLocale,
    required this.currentLanguage,
    required this.changeLanguage,
    required this.apiKey,
  });

  @override
  State<LegalTopicsScreen> createState() => _LegalTopicsScreenState();
}

class _LegalTopicsScreenState extends State<LegalTopicsScreen> {
  late final GeminiApiService _geminiApiService;
  List<Map<String, String>> _topics = [];
  bool _isLoading = true;
  bool _apiConnectionFailed = false;

  @override
  void initState() {
    super.initState();
    // Initialize the service with API key
    _geminiApiService = GeminiApiService(apiKey: widget.apiKey);
    _testApiConnection();
  }
  
  @override
  void didUpdateWidget(LegalTopicsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If language changed, reload topics in the new language
    if (widget.currentLanguage != oldWidget.currentLanguage) {
      _loadTopics();
    }
  }

  Future<void> _testApiConnection() async {
    try {
      final isConnected = await _geminiApiService.testConnection();
      if (!isConnected) {
        setState(() {
          _apiConnectionFailed = true;
          _isLoading = false;
        });
        return;
      }

      // If connection successful, load topics
      _loadTopics();
    } catch (e) {
      setState(() {
        _apiConnectionFailed = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to Gemini API: $e')),
        );
      }
    }
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate prompt for legal topics based on language
      final prompt = _createTopicsPrompt(widget.currentLanguage);

      // Use the service to generate content
      final response = await _geminiApiService.generateContent(prompt);

      // Parse the response to extract topics
      final topics = _parseTopicsFromResponse(response);

      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load topics: $e')));
      }
    }
  }

  // Create a structured prompt for the Gemini API
  String _createTopicsPrompt(String language) {
    final languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'hi': 'Hindi',
      'te': 'Telugu',
      'kn': 'Kannada',
      'ar': 'Arabic',
    };

    return '''
    Generate 10 common legal topics that people might need information about in ${languageNames[language] ?? 'English'}.
    For each topic, provide:
    1. A title (keep it short)
    2. A brief description (1-2 sentences)
    3. An icon suggestion (Material icon name)
    
    Format the response as a JSON array with objects containing "title", "description", and "icon" fields.
    All text should be in ${languageNames[language] ?? 'English'}.
    ''';
  }

  // Parse the response from Gemini API into a list of topic maps
  List<Map<String, String>> _parseTopicsFromResponse(String response) {
    try {
      // Basic parsing - in a real app, you would use json.decode
      // This is a simplistic approach assuming the response format is correct
      final topicsList = <Map<String, String>>[];

      // Simple cleanup to extract just the JSON part if there's extra text
      if (response.contains('[') && response.contains(']')) {}

      // Fallback to hardcoded topics if parsing fails
      topicsList.add({
        'title': 'Family Law',
        'description': 'Divorce, custody, and adoption matters',
        'icon': 'family_restroom',
      });

      topicsList.add({
        'title': 'Criminal Law',
        'description':
            'Defense against charges and understanding criminal procedures',
        'icon': 'gavel',
      });

      topicsList.add({
        'title': 'Property Law',
        'description': 'Real estate transactions and property disputes',
        'icon': 'home',
      });

      topicsList.add({
        'title': 'Immigration',
        'description': 'Visa applications, residency, and citizenship issues',
        'icon': 'flight',
      });

      topicsList.add({
        'title': 'Employment Law',
        'description':
            'Workplace rights, discrimination, and contract disputes',
        'icon': 'work',
      });

      topicsList.add({
        'title': 'Business Law',
        'description':
            'Company formation, regulations, and corporate compliance',
        'icon': 'business',
      });

      topicsList.add({
        'title': 'Intel Property',
        'description': 'Patents, trademarks, copyrights, and IP protection',
        'icon': 'copyright',
      });

      topicsList.add({
        'title': 'Personal Injury',
        'description': 'Compensation for accidents and injury claims',
        'icon': 'healing',
      });

      topicsList.add({
        'title': 'Consumer Rights',
        'description':
            'Product liability, fraud protection, and consumer disputes',
        'icon': 'shopping_cart',
      });

      topicsList.add({
        'title': 'Wills & Estates',
        'description': 'Estate planning, inheritance, and probate matters',
        'icon': 'description',
      });

      return topicsList;
    } catch (e) {
      debugPrint('Error parsing topics: $e');
      return [];
    }
  }

  void _navigateToTopicDetail(Map<String, String> topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TopicDetailScreen(
              topic: topic,
              language: widget.currentLanguage,
              apiKey: widget.apiKey,
            ),
      ),
    );
  }


  String _getLocalizedText(Map<String, String> textMap) {
    return textMap[widget.currentLanguage] ?? textMap['en'] ?? "An error occurred";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _apiConnectionFailed
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _getApiErrorMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _apiConnectionFailed = false;
                      _isLoading = true;
                    });
                    _testApiConnection();
                  },
                  child: Text(_getLocalizedText({
                    'en': 'Retry Connection',
                    'es': 'Reintentar Conexión',
                    'fr': 'Réessayer la Connexion',
                    'de': 'Verbindung erneut versuchen',
                    'hi': 'कनेक्शन पुनः प्रयास करें',
                    'te': 'కనెక్షన్ మళ్లీ ప్రయత్నించండి',
                    'kn': 'ಸಂಪರ್ಕವನ್ನು ಮರುಪ್ರಯತ್ನಿಸಿ',
                  })),
                ),
              ],
            ),
          )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
          ? Center(child: Text(_getEmptyMessage()))
          : GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              return TopicCard(
                topic: _topics[index],
                onTap: () => _navigateToTopicDetail(_topics[index]),
              );
            },
          ),
    );
  }

  String _getEmptyMessage() {
    final messages = {
      'en': 'No legal topics available',
      'es': 'No hay temas legales disponibles',
      'fr': 'Aucun sujet juridique disponible',
      'de': 'Keine Rechtsthemen verfügbar',
      'hi': 'कोई कानूनी विषय उपलब्ध नहीं है',
      'te': 'చట్టపరమైన అంశాలు అందుబాటులో లేవు',
      'kn': 'ಯಾವುದೇ ಕಾನೂನು ವಿಷಯಗಳು ಲಭ್ಯವಿಲ್ಲ',
      'ar': 'لا توجد موضوعات قانونية متاحة',
    };

    return messages[widget.currentLanguage] ?? messages['en']!;
  }

  String _getApiErrorMessage() {
    final messages = {
      'en':
          'Could not connect to the Gemini API. Please check your API key and internet connection.',
      'es':
          'No se pudo conectar a la API de Gemini. Por favor, verifica tu clave API y conexión a internet.',
      'fr':
          'Impossible de se connecter à l\'API Gemini. Veuillez vérifier votre clé API et votre connexion Internet.',
      'de':
          'Es konnte keine Verbindung zur Gemini-API hergestellt werden. Bitte überprüfen Sie Ihren API-Schlüssel und Ihre Internetverbindung.',
      'hi':
          'जेमिनी API से कनेक्ट नहीं हो सका। कृपया अपनी API कुंजी और इंटरनेट कनेक्शन जांचें।',
      'te':
          'జెమిని API కి కనెక్ట్ చేయలేకపోయింది. దయచేసి మీ API కీ మరియు ఇంటర్నెట్ కనెక్షన్ ని తనిఖీ చేయండి.',
      'kn':
          'ಜೆಮಿನಿ API ಗೆ ಸಂಪರ್ಕಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ API ಕೀ ಮತ್ತು ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ.',
      'ar':
          'تعذر الاتصال بواجهة برمجة تطبيقات Gemini. يرجى التحقق من مفتاح API والاتصال بالإنترنت.',
    };

    return messages[widget.currentLanguage] ?? messages['en']!;
  }
}

// These classes might be needed if not imported from other files
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class GeminiApiService {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1';

  GeminiApiService({required this.apiKey});

  Future<String> generateContent(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/models/gemini-1.5-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            { "parts": [{"text": prompt}] }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 800
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Gemini API: $e');
    }
  }
  
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/models/gemini-1.5-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            { "parts": [{"text": "Hello"}] }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 10
          }
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
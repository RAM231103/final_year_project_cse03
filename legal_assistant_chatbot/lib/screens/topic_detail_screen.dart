import 'package:flutter/material.dart';
import 'package:legal_assistant_chatbot/models/language_option.dart'; // Import for appLanguages if needed

import 'chatbot_Screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final Map<String, String> topic;
  final String language;
  final String apiKey;
  
  const TopicDetailScreen({
    super.key,
    required this.topic,
    required this.language,
    required this.apiKey,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late final GeminiApiService _geminiApiService;
  String _content = '';
  bool _isLoading = true;
  bool _hasError = false;
  bool _isQuotaExceeded = false;

  @override
  void initState() {
    super.initState();
    // Initialize the service with API key
    _geminiApiService = GeminiApiService(apiKey: widget.apiKey);
    _loadTopicContent();
  }

  Future<void> _loadTopicContent() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isQuotaExceeded = false;
    });

    try {
      // Create a simpler prompt that will be enhanced by the API service
      final prompt = _createTopicDetailPrompt(widget.topic['title'] ?? '');
      
      // Use the improved generateContent method that handles language properly
      final response = await _geminiApiService.generateContent(prompt, widget.language);
      
      setState(() {
        _content = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading topic content: $e");
      
      setState(() {
        _isLoading = false;
        _hasError = true;
        // Check if the error is due to quota exceeded
        _isQuotaExceeded = e.toString().contains("429") || 
            e.toString().toLowerCase().contains("quota") || 
            e.toString().toLowerCase().contains("exhausted") ||
            e.toString().toLowerCase().contains("resource_exhausted");
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isQuotaExceeded 
            ? _getQuotaExceededMessage() 
            : _getErrorMessage())),
        );
      }
    }
  }

  String _createTopicDetailPrompt(String topicTitle) {
    return '''
Provide detailed information about the legal topic: "$topicTitle".
    
Include the following sections:
1. Overview - What this legal area covers
2. Common Issues - Typical situations people face
3. Key Legal Principles - Important laws or regulations
4. Seeking Help - When and how to get legal assistance
    
Format the response in clear paragraphs with section headers.
Keep the response informative but accessible to non-lawyers.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic['title'] ?? _getLocalizedText({
          'en': 'Topic Details',
          'es': 'Detalles del Tema',
          'fr': 'Détails du Sujet',
          'de': 'Themendetails',
          'hi': 'विषय विवरण',
          'te': 'అంశం వివరాలు',
          'kn': 'ವಿಷಯದ ವಿವರಗಳು',
        })),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_getLocalizedText({
                    'en': 'Loading content...',
                    'es': 'Cargando contenido...',
                    'fr': 'Chargement du contenu...',
                    'de': 'Inhalt wird geladen...',
                    'hi': 'सामग्री लोड हो रही है...',
                    'te': 'కంటెంట్ లోడ్ అవుతోంది...',
                    'kn': 'ವಿಷಯವನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
                  })),
                ],
              ))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _isQuotaExceeded ? _getQuotaExceededMessage() : _getErrorMessage(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadTopicContent,
                        child: Text(_getLocalizedText({
                          'en': 'Try Again',
                          'es': 'Intentar de nuevo',
                          'fr': 'Réessayer',
                          'de': 'Erneut versuchen',
                          'hi': 'पुनः प्रयास करें',
                          'te': 'మళ్ళీ ప్రయత్నించండి',
                          'kn': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
                        })),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.topic['icon'] != null)
                        Icon(
                          _getIconData(widget.topic['icon'] ?? 'info'),
                          size: 64,
                          color: Theme.of(context).primaryColor,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.topic['description'] ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      // Display the generated content
                      Text(_content),
                    ],
                  ),
                ),
      // Add floating action button to retrigger content generation if needed
      floatingActionButton: _isLoading || _hasError ? null : FloatingActionButton(
        onPressed: _loadTopicContent,
        tooltip: _getLocalizedText({
          'en': 'Refresh content',
          'es': 'Actualizar contenido',
          'fr': 'Actualiser le contenu',
          'de': 'Inhalt aktualisieren',
          'hi': 'सामग्री को रिफ्रेश करें',
          'te': 'కంటెంట్ రిఫ్రెష్ చేయండి',
          'kn': 'ವಿಷಯವನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ',
        }),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map string icon names to IconData
    switch (iconName) {
      case 'family_restroom':
        return Icons.family_restroom;
      case 'gavel':
        return Icons.gavel;
      case 'home':
        return Icons.home;
      case 'flight':
        return Icons.flight;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'copyright':
        return Icons.copyright;
      case 'healing':
        return Icons.healing;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'description':
        return Icons.description;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.info;
    }
  }

  String _getLocalizedText(Map<String, String> textMap) {
    return textMap[widget.language] ?? textMap['en'] ?? "Text not found";
  }

  String _getErrorMessage() {
    final messages = {
      'en': 'Failed to load content. Please check your internet connection.',
      'es': 'No se pudo cargar el contenido. Por favor, verifica tu conexión a internet.',
      'fr': 'Échec du chargement du contenu. Veuillez vérifier votre connexion Internet.',
      'de': 'Fehler beim Laden des Inhalts. Bitte überprüfen Sie Ihre Internetverbindung.',
      'hi': 'सामग्री लोड करने में विफल। कृपया अपने इंटरनेट कनेक्शन की जांच करें।',
      'te': 'కంటెంట్ లోడ్ చేయడం విఫలమైంది. దయచేసి మీ ఇంటర్నెట్ కనెక్షన్ని తనిఖీ చేయండి.',
      'kn': 'ವಿಷಯವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ.',
      'ar': 'فشل تحميل المحتوى. يرجى التحقق من اتصالك بالإنترنت.',
    };
    
    return messages[widget.language] ?? messages['en']!;
  }
  
  String _getQuotaExceededMessage() {
    final messages = {
      'en': "API quota exceeded. Please try again later or consider updating your API key.",
      'es': "Cuota de API excedida. Por favor, inténtalo de nuevo más tarde o considera actualizar tu clave API.",
      'fr': "Quota d'API dépassé. Veuillez réessayer plus tard ou envisager de mettre à jour votre clé API.",
      'de': "API-Kontingent überschritten. Bitte versuchen Sie es später erneut oder erwägen Sie, Ihren API-Schlüssel zu aktualisieren.",
      'hi': "API कोटा खत्म हो गया है। कृपया बाद में पुनः प्रयास करें या अपनी API कुंजी को अपडेट करने पर विचार करें।",
      'te': "API కోటా మించిపోయింది. దయచేసి తర్వాత మళ్లీ ప్రయత్నించండి లేదా మీ API కీని అప్డేట్ చేయడం పరిగణించండి.",
      'kn': "API ಕೋಟಾ ಮೀರಿದೆ. ದಯವಿಟ್ಟು ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ ನಿಮ್ಮ API ಕೀ ಅನ್ನು ಅಪ್ಡೇಟ್ ಮಾಡಲು ಪರಿಗಣಿಸಿ.",
    };
    
    return messages[widget.language] ?? messages['en']!;
  }
}
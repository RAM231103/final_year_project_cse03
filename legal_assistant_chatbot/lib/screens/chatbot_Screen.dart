import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:legal_assistant_chatbot/models/language_option.dart';

// ChatMessage class
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

// GeminiApiService class with improved error handling and language support
class GeminiApiService {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1';

  GeminiApiService({required this.apiKey});

  Future<String> generateContent(String prompt, String languageCode) async {
    try {
      print("Sending request to Gemini API with prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...");
      print("Language code: $languageCode");
      
      // Map language codes to full language names for better instruction to the model
      final languageNames = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'hi': 'Hindi',
        'te': 'Telugu',
        'kn': 'Kannada',
      };
      
      // Create a more explicit language instruction
      final languageName = languageNames[languageCode] ?? 'English';
      final enhancedPrompt = """
I want you to respond in $languageName language only.
Language: $languageName
User query: $prompt
""";
      
      final response = await http.post(
        Uri.parse('$baseUrl/models/gemini-1.5-pro:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Charset': 'utf-8',
        },
        body: jsonEncode({
          "contents": [
            { "parts": [{"text": enhancedPrompt}] }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 800
          }
        }),
      );
      
      print("Response status code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && 
            data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null && 
            data['candidates'][0]['content']['parts'] != null && 
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final responseText = data['candidates'][0]['content']['parts'][0]['text'];
          print("Response received, length: ${responseText.length}");
          return responseText;
        } else {
          print("API returned unexpected data structure: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...");
          
          // Return error in the requested language
          if (languageCode == 'en') {
            return "Sorry, I received an unexpected response. Please try again.";
          } else if (languageCode == 'es') {
            return "Lo siento, recibí una respuesta inesperada. Por favor, inténtalo de nuevo.";
          } else if (languageCode == 'fr') {
            return "Désolé, j'ai reçu une réponse inattendue. Veuillez réessayer.";
          } else if (languageCode == 'de') {
            return "Entschuldigung, ich habe eine unerwartete Antwort erhalten. Bitte versuchen Sie es erneut.";
          } else if (languageCode == 'hi') {
            return "क्षमा करें, मुझे एक अप्रत्याशित प्रतिक्रिया मिली। कृपया पुनः प्रयास करें।";
          } else if (languageCode == 'te') {
            return "క్షమించండి, నేను ఊహించని ప్రతిస్పందన పొందాను. దయచేసి మళ్లీ ప్రయత్నించండి.";
          } else if (languageCode == 'kn') {
            return "ಕ್ಷಮಿಸಿ, ನಾನು ಅನಿರೀಕ್ಷಿತ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಪಡೆದುಕೊಂಡೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.";
          } else {
            return "Sorry, I received an unexpected response. Please try again.";
          }
        }
      } else if (response.statusCode == 429) {
        print("Error response (quota exceeded): ${response.body}");
        throw Exception('API quota exceeded: 429 - Resource has been exhausted. Please try again later.');
      } else {
        print("Error response: ${response.body}");
        throw Exception('Failed to get response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Exception occurred: $e");
      throw Exception('Failed to connect to Gemini API: $e');
    }
  }
  
  Future<bool> testConnection() async {
    try {
      print("Testing API connection...");
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
      
      print("Test connection status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("Test connection failed: $e");
      return false;
    }
  }
}

class SimpleChatScreen extends StatefulWidget {
  final String currentLanguage;
  final List<LanguageOption> languages;
  final String? apiKey;

  const SimpleChatScreen({
    Key? key,
    required this.currentLanguage,
    required this.languages,
    this.apiKey = 'AIzaSyCCf5fvtxPuWfHezWW0x8hICn4cz8fmOM4', // Default API key
  }) : super(key: key);

  @override
  State<SimpleChatScreen> createState() => _SimpleChatScreenState();
}

class _SimpleChatScreenState extends State<SimpleChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _apiConnectionFailed = false;
  late GeminiApiService _apiService;
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
    
    // Initialize the API service with the provided API key or default
    _apiService = GeminiApiService(apiKey: widget.apiKey ?? 'AIzaSyBFhe9uvFbxSwRIEBlkkK71IgvzweLREqk');
    _testApiConnection();
  }
  
  @override
  void didUpdateWidget(SimpleChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update language if it changed from parent widget
    if (widget.currentLanguage != oldWidget.currentLanguage) {
      setState(() {
        _currentLanguage = widget.currentLanguage;
      });
      // Don't clear messages on language change - just show welcome in new response
    }
    
    // Update API key if changed
    if (widget.apiKey != oldWidget.apiKey) {
      _apiService = GeminiApiService(apiKey: widget.apiKey ?? 'AIzaSyBFhe9uvFbxSwRIEBlkkK71IgvzweLREqk');
      _testApiConnection();
    }
  }

  Future<void> _testApiConnection() async {
    try {
      final isConnected = await _apiService.testConnection();
      if (!isConnected) {
        setState(() {
          _apiConnectionFailed = true;
        });
        _showWelcomeMessage(); // Still show welcome even if API fails
      } else {
        setState(() {
          _apiConnectionFailed = false;
        });
        _showWelcomeMessage();
      }
    } catch (e) {
      setState(() {
        _apiConnectionFailed = true;
      });
      _showWelcomeMessage(); // Still show welcome even if API fails
    }
  }

  void _showWelcomeMessage() {
    final welcomeMessage = widget.languages
        .firstWhere((lang) => lang.code == _currentLanguage, 
            orElse: () => widget.languages.first)
        .welcomeMessage;

    setState(() {
      _messages.clear();
      _addMessage(text: welcomeMessage, isUser: false);
    });
  }

  void _addMessage({required String text, required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _addMessage(text: text, isUser: true);
    
    setState(() {
      _isLoading = true;
    });

    _getResponse(text);
  }

  Future<void> _getResponse(String query) async {
    try {
      // Send the query and the language code separately, let the service handle the proper formatting
      final response = await _apiService.generateContent(query, _currentLanguage);
      
      if (mounted) {
        _addMessage(text: response, isUser: false);
      }
    } catch (e) {
      print("Error getting response: $e");
      if (mounted) {
        // Check if the error contains a quota exhaustion message
        if (e.toString().contains("429") || 
            e.toString().toLowerCase().contains("quota") || 
            e.toString().toLowerCase().contains("exhausted") ||
            e.toString().toLowerCase().contains("resource_exhausted")) {
          
          _addMessage(
            text: _getLocalizedText({
              'en': "I'm currently receiving too many requests. Please try again in a few minutes. This may be due to API quota limitations.",
              'es': "Actualmente estoy recibiendo demasiadas solicitudes. Por favor, inténtalo de nuevo en unos minutos. Esto puede deberse a limitaciones de cuota de la API.",
              'fr': "Je reçois actuellement trop de requêtes. Veuillez réessayer dans quelques minutes. Cela peut être dû aux limitations de quota de l'API.",
              'de': "Ich erhalte derzeit zu viele Anfragen. Bitte versuchen Sie es in einigen Minuten erneut. Dies kann an API-Quota-Beschränkungen liegen.",
              'hi': "मैं वर्तमान में बहुत अधिक अनुरोध प्राप्त कर रहा हूं। कृपया कुछ मिनटों में पुनः प्रयास करें। यह API कोटा सीमाओं के कारण हो सकता है।",
              'te': "నేను ప్రస్తుతం చాలా అభ్యర్థనలను స్వీకరిస్తున్నాను. దయచేసి కొన్ని నిమిషాల్లో మళ్లీ ప్రయత్నించండి. ఇది API కోటా పరిమితుల కారణంగా ఉండవచ్చు.",
              'kn': "ನಾನು ಪ್ರಸ್ತುತ ಹೆಚ್ಚಿನ ವಿನಂತಿಗಳನ್ನು ಸ್ವೀಕರಿಸುತ್ತಿದ್ದೇನೆ. ದಯವಿಟ್ಟು ಕೆಲವು ನಿಮಿಷಗಳಲ್ಲಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ. ಇದು API ಕೋಟಾ ಮಿತಿಗಳಿಂದಾಗಿರಬಹುದು.",
            }),
            isUser: false
          );
        } else {
          _addMessage(
            text: _getLocalizedText({
              'en': "I couldn't process your request. Please try again later.",
              'es': "No pude procesar tu solicitud. Por favor, inténtalo de nuevo más tarde.",
              'fr': "Je n'ai pas pu traiter votre demande. Veuillez réessayer plus tard.",
              'de': "Ich konnte Ihre Anfrage nicht verarbeiten. Bitte versuchen Sie es später erneut.",
              'hi': "मैं आपके अनुरोध को प्रोसेस नहीं कर सका। कृपया बाद में पुनः प्रयास करें।",
              'te': "నేను మీ అభ్యర్థనను ప్రాసెస్ చేయలేకపోయాను. దయచేసి తర్వాత మళ్ళీ ప్రయత్నించండి.",
              'kn': "ನಾನು ನಿಮ್ಮ ವಿನಂತಿಯನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.",
            }),
            isUser: false
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLocalizedText(Map<String, String> textMap) {
    return textMap[_currentLanguage] ?? textMap['en'] ?? "Text not found";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[_messages.length - 1 - index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser 
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[900] 
          : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _getLocalizedText({
                  'en': 'Type a message...',
                  'es': 'Escribe un mensaje...',
                  'fr': 'Écrivez un message...',
                  'de': 'Nachricht eingeben...',
                  'hi': 'संदेश लिखें...',
                  'te': 'సందేశాన్ని టైప్ చేయండి...',
                  'kn': 'ಸಂದೇಶವನ್ನು ಟೈಪ್ ಮಾಡಿ...',
                }),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[800] 
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              onSubmitted: _isLoading ? null : _handleSubmitted,
              enabled: !_isLoading,
            ),
          ),
          SizedBox(width: 8.0),
          Material(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: _isLoading ? null : () => _handleSubmitted(_textController.text),
              child: Container(
                width: 48.0,
                height: 48.0,
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
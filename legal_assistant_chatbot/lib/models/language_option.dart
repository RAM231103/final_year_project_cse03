// models/language_option.dart
class LanguageOption {
  final String code;
  final String name;
  final String welcomeMessage;

  const LanguageOption({
    required this.code, 
    required this.name,
    required this.welcomeMessage,
  });
}

// Global language options that can be accessed throughout the app
final List<LanguageOption> appLanguages = [
  LanguageOption(
    code: 'en',
    name: 'English',
    welcomeMessage: "Hello! I'm a legal assistant. How can I help you today?",
  ),
  LanguageOption(
    code: 'es',
    name: 'Español',
    welcomeMessage: "¡Hola! Soy un asistente legal. ¿Cómo puedo ayudarte hoy?",
  ),
  LanguageOption(
    code: 'fr',
    name: 'Français',
    welcomeMessage: "Bonjour! Je suis un assistant juridique. Comment puis-je vous aider aujourd'hui?",
  ),
  LanguageOption(
    code: 'de',
    name: 'Deutsch',
    welcomeMessage: "Hallo! Ich bin ein Rechtsassistent. Wie kann ich Ihnen heute helfen?",
  ),
  LanguageOption(
    code: 'hi',
    name: 'हिंदी',
    welcomeMessage: "नमस्ते! मैं एक कानूनी सहायक हूँ। आज मैं आपकी कैसे मदद कर सकता हूँ?",
  ),
  LanguageOption(
    code: 'te',
    name: 'తెలుగు',
    welcomeMessage: "నమస్కారం! నేను చట్ట సహాయకుడిని. నేను మీకు ఈరోజు ఎలా సహాయం చేయగలను?",
  ),
  LanguageOption(
    code: 'kn',
    name: 'ಕನ್ನಡ',
    welcomeMessage: "ನಮಸ್ಕಾರ! ನಾನು ಕಾನೂನು ಸಹಾಯಕ. ನಾನು ನಿಮಗೆ ಇಂದು ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?",
  ),
];
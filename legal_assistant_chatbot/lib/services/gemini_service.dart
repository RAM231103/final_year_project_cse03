// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class GeminiService {
//   final String _baseUrl = 'https://generativelanguage.googleapis.com/v1';
//   late String _apiKey;
  
//   GeminiService() {
//     _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
//     if (_apiKey.isEmpty) {
//       throw Exception('Gemini API key not found. Please add it to your .env file.');
//     }
//   }

//   Future<String> getLegalResponse(String userQuery, {String language = 'en'}) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl?key=$_apiKey'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [
//             {
//               "role": "user",
//               "parts": [
//                 {
//                   "text": """
//                     You are a legal assistant. Provide concise, easy-to-understand information about the following legal query:
//                     $userQuery
                    
//                     Please respond in $language language. Focus on providing practical information and avoid legal jargon where possible.
//                     Keep answers under 300 words and organize with bullet points for complex information.
//                     """
//                 }
//               ]
//             }
//           ],
//           "generationConfig": {
//             "temperature": 0.2,
//             "topK": 40,
//             "topP": 0.95,
//             "maxOutputTokens": 800,
//           }
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['candidates'][0]['content']['parts'][0]['text'];
//       } else {
//         throw Exception('Failed to get response from Gemini API: ${response.statusCode}');
//       }
//     } catch (e) {
//       return 'Error: $e';
//     }
//   }

//   Future<List<Map<String, String>>> getLegalTopics({String language = 'en'}) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl?key=$_apiKey'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [
//             {
//               "role": "user",
//               "parts": [
//                 {
//                   "text": """
//                     Generate a structured JSON array of 10 common legal topics including family law, property law, labor law, and criminal law.
//                     Each object should have:
//                     1. "id": A unique identifier string
//                     2. "title": The title of the legal topic in $language
//                     3. "description": A brief 25-word description in $language
//                     4. "icon": A suggested Material icon name that represents the topic

//                     Return only the valid JSON array with no additional text.
//                     """
//                 }
//               ]
//             }
//           ],
//           "generationConfig": {
//             "temperature": 0.1,
//             "maxOutputTokens": 1024,
//           }
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final jsonString = data['candidates'][0]['content']['parts'][0]['text'];
        
//         // Extract the JSON array from the response text
//         final jsonRegExp = RegExp(r'\[.*\]', dotAll: true);
//         final match = jsonRegExp.firstMatch(jsonString);
        
//         if (match != null) {
//           final jsonArray = jsonDecode(match.group(0)!);
//           return List<Map<String, String>>.from(
//             jsonArray.map((topic) => Map<String, String>.from(topic))
//           );
//         } else {
//           throw Exception('Could not extract valid JSON from response');
//         }
//       } else {
//         throw Exception('Failed to get topics from Gemini API: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching legal topics: $e');
//       // Return basic fallback topics if API fails
//       return [
//         {'id': 'family', 'title': 'Family Law', 'description': 'Marriage, divorce, and child custody', 'icon': 'family_restroom'},
//         {'id': 'property', 'title': 'Property Law', 'description': 'Real estate and ownership rights', 'icon': 'home'},
//         {'id': 'labor', 'title': 'Labor Law', 'description': 'Employment rights and regulations', 'icon': 'work'},
//         {'id': 'criminal', 'title': 'Criminal Law', 'description': 'Criminal offenses and procedures', 'icon': 'gavel'},
//       ];
//     }
//   }
// }
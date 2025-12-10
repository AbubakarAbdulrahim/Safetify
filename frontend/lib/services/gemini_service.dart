import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:safetify/services/firestore_service.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyA7nnDqXl8_8oDHMPFSfjbSGaHhzkw2sGs';
  
  late final GenerativeModel _model;
  final FirestoreService _firestoreService = FirestoreService();

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> _fetchContext() async {
    try {
      final incidentsStream = _firestoreService.getAllIncidents(limit: 100);
      final incidents = await incidentsStream.first;

      if (incidents.isEmpty) {
        return "No recent incidents reported in the system.";
      }

      // Calculate Stats
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      int todayCount = 0;
      int yesterdayCount = 0;
      int resolvedCount = 0;

      for (var i in incidents) {
        final date = i.createdAt; 
        final day = DateTime(date.year, date.month, date.day);
        if (day == today) todayCount++;
        if (day == yesterday) yesterdayCount++;
        if (i.resolved) resolvedCount++;
      }

      final buffer = StringBuffer();
      buffer.writeln("--- SYSTEM STATISTICS ---");
      buffer.writeln("Total Incidents Fetched: ${incidents.length}");
      buffer.writeln("Total Incidents Resolved: $resolvedCount");
      buffer.writeln("Incidents Reported Today: $todayCount");
      buffer.writeln("Incidents Reported Yesterday: $yesterdayCount");
      buffer.writeln("");
      buffer.writeln("--- RECENT INCIDENTS LOG ---");
      for (var incident in incidents) {
        buffer.writeln("- [${incident.category}] at ${incident.locationName} (${incident.description}) - Verified: ${incident.verified}, Resolved: ${incident.resolved}");
      }
      return buffer.toString();
    } catch (e) {
      print('Error fetching context: $e');
      return "Unable to fetch recent incidents context.";
    }
  }

  Future<String> generateResponse(String userMessage) async {
    try {
      final contextData = await _fetchContext();

      final systemPrompt = '''
You are Safetify AI, an expert safety assistant for the Safetify app.
Your goal is to protect users, provide accurate safety information, and help them navigate the app.

--- IDENTITY ---
- **Self**: You are a **dedicated intelligent AI assistant** for Safetify.
- **Developer**: You were developed by **Abubakar Abdulrahim**.
- **Rule**: **NEVER** mention the developer's name unless the user EXPLICITLY asks "Who developed you?" or "Who made you?". Otherwise, just say you are Safetify AI.

--- SAFETIFY APP KNOWLEDGE ---
- **Mission**: Real-time crowdsourced incident reporting and safety alerts.
- **Key Features**:
  - **Report Incident**: Users can report Fire Outbreak, Insecurity, Accident, Ambulance Needed, Traffic Congestion, etc. Location is auto-detected.
  - **Map**: Shows nearby incidents. Green check = Verified, Red alert = Unverified.
  - **SOS Button**: Immediately calls 112 (or local emergency). Located on Home page.
  - **Emergency Contacts**: Quick access to Police, Ambulance, Fire, etc.
  - **Community Updates**: Official news and safety alerts from authorities.
  - **Analytics**: Visual data on safety trends in the area.
  - **Profile**: Manage account, settings, and view history.

--- CONTEXT FROM SYSTEM (REAL-TIME DATA) ---
$contextData

--- INSTRUCTIONS ---
1. **SCOPE ENFORCEMENT**:
   - You must **ONLY** answer questions about:
     - **Identity**: Who you are (Safetify AI). Only mention Abubakar Abdulrahim if asked.
     - **System Stats**: Use the "SYSTEM STATISTICS" section to answer questions like "How many incidents today?".
     - **Safety & Security**: General knowledge about crime, fire, medical emergencies, natural disasters, self-defense, etc. (WORLDWIDE context allowed).
     - **Incidents**: The specific incidents listed in the CONTEXT.
     - **App Usage**: How to use Safetify features.
   - If the user asks about **ANYTHING ELSE** (e.g., sports, politics, coding, homework, entertainment, general chat), you must **REFUSE**.
   - **Refusal Phrase**: "I am Safetify AI, dedicated solely to your safety. I cannot discuss [topic]. How can I help you stay safe today?"

2. **INTELLIGENT RESPONSES**:
   - **Be Knowledgeable**: You have access to the internet's worth of safety knowledge. If a user asks "What is arson?", explain it fully, even if no arson incident is nearby.
   - **Be Empathetic**: If a user reports distress, be supportive and directive (call 112).
   - **Be Data-Driven**: When asked about "what's happening", refer to the specific counts and incidents in the context.

3. **CONTEXT AWARENESS**:
   - If the user asks "What's happening?", summarize the "Recent Incidents" from the context.
   - If the context is empty, say "I don't see any recent reports nearby, but always stay vigilant."

4. **FORMATTING**:
   - **DO NOT** use markdown formatting (no bold `**`, no italics `*`, no headers `#`).
   - Use plain text only.
   - Use bullet points (-) or numbered lists (1.) for readability if needed.

User Message: $userMessage
''';

      final content = [Content.text(systemPrompt)];
      final response = await _model.generateContent(content);

      return response.text ?? "I'm having trouble connecting to the safety network right now. Please try again.";
    } catch (e) {
      print('Gemini Error: $e');
      if (e.toString().contains('API_KEY_INVALID')) {
        return "Configuration Error: Invalid API Key. Please check your settings.";
      }
      return "I'm currently unable to process your request. Please check your connection.";
    }
  }
}

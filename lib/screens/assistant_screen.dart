import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late GenerativeModel _model;
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // Add initial greeting
    _messages.add({
      'role': 'model',
      'text': 'Hi! I am your VenueVantage Assistant. I know your seat location and live stadium stats. How can I help you today?',
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initModel();
    });
  }

  void _initModel() {
    final appState = context.read<AppState>();
    final stats = appState.venueStats;
    
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    debugPrint("AI Assistant: API Key loaded (length: ${apiKey.length})");
    
    if (apiKey.isEmpty) {
      setState(() {
        _messages.add({
          'role': 'model',
          'text': '⚠️ Note: GEMINI_API_KEY is not defined. I am running in mock mode. Please set the API key to unleash my full potential.',
        });
      });
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: _getSystemInstruction(),
    );
    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      // Mock Response
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'model',
            'text': 'This is a mock response. In a real environment with the API key, I would dynamically process your request about "$text" based on your current seat in Section ${context.read<AppState>().section}.',
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
      return;
    }

    try {
      final response = await _chat.sendMessage(Content.text(text));
      if (mounted) {
        setState(() {
          _messages.add({'role': 'model', 'text': response.text ?? 'I could not process that.'});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("AI Assistant Error: $e");
      // Fallback mechanism if the model is not found (e.g. region or key limitations)
      if (e.toString().contains('not found') || e.toString().contains('not supported')) {
        try {
          final fallbackModel = GenerativeModel(
            model: 'gemini-1.5-pro',
            apiKey: apiKey,
            systemInstruction: _getSystemInstruction(),
          );
          final fallbackChat = fallbackModel.startChat(history: _chat.history.toList());
          final response = await fallbackChat.sendMessage(Content.text(text));
          
          if (mounted) {
            setState(() {
              _model = fallbackModel; // Switch to fallback for future messages
              _chat = fallbackChat;
              _messages.add({'role': 'model', 'text': response.text ?? 'I could not process that.'});
              _isLoading = false;
            });
            _scrollToBottom();
          }
          return;
        } catch (fallbackErr) {
           _showError(fallbackErr);
           return;
        }
      }
      _showError(e);
    }
  }

  void _showError(dynamic error) {
    if (mounted) {
      setState(() {
        _messages.add({'role': 'model', 'text': 'Oops! Something went wrong connecting to the AI. ($error)'});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerHigh,
        elevation: 0,
        title: Text(
          'Venue Assistant',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.onSurface),
        ),
        iconTheme: const IconThemeData(color: AppTheme.onSurface),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['text'] ?? '', isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                ),
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: isUser ? AppTheme.onPrimary : AppTheme.onSurface,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      color: AppTheme.surfaceContainer,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: GoogleFonts.inter(color: AppTheme.onSurface),
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask about food, wait times, exits...',
                hintStyle: GoogleFonts.inter(color: AppTheme.outline),
                filled: true,
                fillColor: AppTheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Content _getSystemInstruction() {
    final appState = context.read<AppState>();
    final stats = appState.venueStats;
    return Content.system('''
You are the VenueVantage Smart Assistant, an AI guide for users at a large sporting event.
Current Context:
- User Seat: Section ${appState.section}, Row ${appState.row}, Seat ${appState.seat}
- Global Wait Time: ${stats.avgWaitMin} mins
- Congestion Level: ${stats.capacityPct}%
- Safest Exit Route: Route B

Keep answers concise, helpful, and friendly. Guide them gracefully to their destination or to food.
      ''');
  }
}

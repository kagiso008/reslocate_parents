import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:reslocate/api/api.dart';
import 'package:reslocate/pages/bookmarks.dart';
import 'package:reslocate/pages/homepage.dart';
import 'package:reslocate/pages/profile_page.dart';
import 'package:reslocate/widgets/navBar.dart';
import 'package:provider/provider.dart';
import '../utils/connectivity_provider.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}

class MathMessageFormatter {
  static String formatMessage(String text) {
    if (text.isEmpty) return text;

    // First clean up any italics formatting
    text = _cleanItalics(text);

    // Then check if it's LaTeX
    if (_hasLatex(text)) {
      return text; // Return LaTeX unchanged
    }

    // Then check for simple math
    String formatted = _standardizeMathExpression(text);
    if (_isMathExpression(formatted)) {
      return _calculateMathResult(formatted);
    }

    return text;
  }

  static String _cleanItalics(String text) {
    // Handle all variations of italics formatting
    return text
        .replaceAllMapped(
          RegExp(r'\\textit\s*\{([^}]*)\}'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\\emph\s*\{([^}]*)\}'),
          (match) => match.group(1) ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\\it\s*\{([^}]*)\}'),
          (match) => match.group(1) ?? '',
        );
  }

  static bool _hasLatex(String text) {
    // Clean italics first
    text = _cleanItalics(text);

    // Check for actual math LaTeX commands
    final latexPatterns = [
      r'\[', r'\]', // Display math delimiters
      r'\frac', r'\sqrt', // Common functions
      r'\Delta', // Symbols
      r'\pm', r'\cdot', // Operators
      r'\^', // Superscript
      r'_', // Subscript
      r'=', // Equality
    ];

    return latexPatterns.any((pattern) => text.contains(pattern));
  }

  static String _standardizeMathExpression(String text) {
    // First clean italics
    text = _cleanItalics(text);

    // Convert word-based operations to symbols
    String formatted = text
        .toLowerCase()
        .replaceAll('divided by', '÷')
        .replaceAll('times', '×')
        .replaceAll('multiplied by', '×')
        .replaceAll('plus', '+')
        .replaceAll('minus', '-')
        .replaceAll('/[', '')
        .replaceAll('add', '+')
        .replaceAll('subtract', '-')
        .replaceAll('multiply', '×')
        .replaceAll('divide', '÷');

    // Standardize operators
    formatted = formatted
        .replaceAll('*', '×')
        .replaceAll('x', '×')
        .replaceAll('X', '×')
        .replaceAll('/', '÷');

    // Clean up spaces
    return formatted.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _isMathExpression(String text) {
    // Clean italics first
    text = _cleanItalics(text);

    final mathPattern =
        RegExp(r'^\s*(\d+)\s*[×÷+\-]\s*(\d+)\s*$', unicode: true);
    return mathPattern.hasMatch(text);
  }

  static String _calculateMathResult(String expression) {
    // Clean italics first
    expression = _cleanItalics(expression);

    final mathPattern =
        RegExp(r'^\s*(\d+)\s*([×÷+\-])\s*(\d+)\s*$', unicode: true);
    final match = mathPattern.firstMatch(expression);

    if (match != null) {
      final num1 = int.parse(match.group(1) ?? '0');
      final num2 = int.parse(match.group(3) ?? '0');
      final operator = match.group(2);

      switch (operator) {
        case '×':
          return (num1 * num2).toString();
        case '÷':
          if (num2 == 0) return 'Cannot divide by zero';
          return (num1 / num2).toString();
        case '+':
          return (num1 + num2).toString();
        case '-':
          return (num1 - num2).toString();
        default:
          return expression;
      }
    }

    return expression;
  }

  static bool containsMath(String text) {
    // Clean italics first
    text = _cleanItalics(text);

    // Remove \text{} commands as they're not actually math
    text = text.replaceAll(RegExp(r'\\text\{[^}]*\}'), '');

    final mathPattern = RegExp(
      r'[×÷+\-*/xX]|divided by|times|multiplied by|plus|minus|add|subtract|multiply|divide|\[|\]|\\frac|\\sqrt|\\Delta|\\cdot|\\pm',
      caseSensitive: false,
    );
    return mathPattern.hasMatch(text);
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  bool get hasMath => MathMessageFormatter.containsMath(text);
  bool get hasImage => text.contains('<img');
  bool get hasHtml => text.contains('<') && text.contains('>') && !hasMath;

  String get formattedText => MathMessageFormatter.formatMessage(text);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIAssistantAPI chatGPT = AIAssistantAPI();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final int _selectedIndex = 1;
  bool _isTyping = false;
  final StreamController<String> _typingController =
      StreamController<String>.broadcast();

  Future<void> _refreshChat() async {
    // Implement any refresh logic here
    setState(() {
      // Clear error messages or retry failed operations
    });
  }

  @override
  void initState() {
    super.initState();
    _typingController.stream.listen((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D47A1)),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            SvgPicture.asset(
              'assets/images/reslocate_logo.svg',
              height: 50,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Tutor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Text(
                  'Ask Me Anything!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF00E4BA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ConnectivityProvider>(
        builder: (context, connectivity, child) {
          return Column(
            children: [
              if (!connectivity.isOnline)
                Container(
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'You are offline',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFE3F2FA).withOpacity(0.4),
                  child: Scrollbar(
                    controller:
                        _scrollController, // Connect the scrollbar to the scroll controller
                    thumbVisibility: true, // Make the thumb always visible
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageItem(_messages[index]);
                      },
                    ),
                  ),
                ),
              ),
              _buildInputArea(),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Modify your _handleSubmitted method to check connectivity
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final isOnline = context.read<ConnectivityProvider>().isOnline;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _textController.clear();

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // Check if it's a math expression
      String formattedText = MathMessageFormatter.formatMessage(text);
      if (MathMessageFormatter._isMathExpression(
          MathMessageFormatter._standardizeMathExpression(text))) {
        // If it's math, use the result directly
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              text: formattedText,
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isTyping = false;
          });
          _scrollToBottom();
        }
      } else {
        // If not math, proceed with API call
        String response = await chatGPT.getResponse(text);
        if (mounted) {
          _startTypingAnimation(response);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _startTypingAnimation(String response) async {
    List<String> words = response.split(' ');
    String currentText = '';

    for (String word in words) {
      await Future.delayed(
          const Duration(milliseconds: 200)); // Adjust delay as needed
      currentText += '$word ';
      _typingController.add(currentText.trim());
      _scrollToBottom(); // Scroll after adding each word
    }

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(
        // Reduced padding to allow for wider content
        top: 8,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Card(
            color: message.isUser ? const Color(0xFF0D47A1) : Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 16),
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width *
                    0.90, // 85% of screen width
                minWidth: 100, // Minimum width to prevent too narrow messages
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildMessageContent(message),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    // First, clean up any italics formatting in the text
    String cleanText = message.text.replaceAllMapped(
      RegExp(r'\\(?:textit|emph)\{(.*?)\}'),
      (match) => match.group(1) ?? '',
    );

    if (message.isUser) {
      return SelectableText(
        cleanText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      );
    }

    if (message.hasMath) {
      // Extract equations between \[ and \]
      final equations = cleanText.split(r'\[');
      if (equations.length > 1) {
        List<Widget> children = [];

        for (var part in equations) {
          if (part.isEmpty) continue;

          if (part.contains(r'\]')) {
            final eqParts = part.split(r'\]');
            if (eqParts.isNotEmpty) {
              // Clean up any remaining italics in the equation part
              String cleanEq = eqParts[0]
                  .replaceAll(r'\(', '(')
                  .replaceAll(r'\)', ')')
                  .replaceAllMapped(
                    RegExp(r'\\(?:textit|emph)\{(.*?)\}'),
                    (match) => match.group(1) ?? '',
                  );

              // Render the equation part
              children.add(
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    cleanEq,
                    textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    mathStyle: MathStyle.display,
                  ),
                ),
              );

              // Add any remaining text, cleaning up italics
              if (eqParts.length > 1 && eqParts[1].trim().isNotEmpty) {
                String cleanRemaining = eqParts[1].trim().replaceAllMapped(
                      RegExp(r'\\(?:textit|emph)\{(.*?)\}'),
                      (match) => match.group(1) ?? '',
                    );
                children.add(
                  SelectableText(
                    cleanRemaining,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                );
              }
            }
          } else {
            // Regular text, clean up any italics
            String cleanPart = part.replaceAllMapped(
              RegExp(r'\\(?:textit|emph)\{(.*?)\}'),
              (match) => match.group(1) ?? '',
            );
            children.add(
              SelectableText(
                cleanPart,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            );
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }
    }

    // For non-math messages, return cleaned text
    return SelectableText(
      cleanText,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: const Color(0xFFE3F2FA).withOpacity(0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _handleSubmitted(_textController.text),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: _isTyping
                    ? null
                    : () => _handleSubmitted(_textController.text),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: _isTyping
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 64, top: 8, bottom: 8),
      child: StreamBuilder<String>(
        stream: _typingController.stream,
        builder: (context, snapshot) {
          return Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: const Radius.circular(4),
                bottomRight: const Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SelectableText(
                snapshot.data ?? '',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookmarksPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _typingController.close();
    super.dispose();
  }
}

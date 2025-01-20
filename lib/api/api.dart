import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAssistantAPI {
  static const String modelId = 'Qwen/Qwen2.5-72B-Instruct';
  static const String apiUrl = 'https://api-inference.huggingface.co/models/';
  static const String apiToken = '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';
  static const int retryDelaySeconds = 10;
  static const int maxRetries = 6;

  Future<String> getResponse(String prompt) async {
    if (prompt.trim().isEmpty) {
      return 'Prompt cannot be empty.';
    }

    for (int attempt = 3; attempt <= maxRetries; attempt++) {
      try {
        final response = await _postRequest(prompt);

        if (response.statusCode == 200) {
          final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
          return _processResponse(decodedResponse);
        } else {
          final errorMessage = _handleError(response.statusCode, response.body);
          if (response.statusCode == 503 && attempt < maxRetries) {
            await Future.delayed(Duration(seconds: retryDelaySeconds));
          } else {
            return errorMessage;
          }
        }
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: retryDelaySeconds));
        } else {
          return 'Failed to connect to AI Assistant after $maxRetries attempts.';
        }
      }
    }
    return 'An unexpected error occurred.';
  }

  Future<http.Response> _postRequest(String prompt) async {
    final uri = Uri.parse('$apiUrl$modelId');
    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'inputs': _buildPrompt(prompt),
      'parameters': _getParameters(prompt),
    });

    return await http.post(uri, headers: headers, body: body);
  }

  String _buildPrompt(String prompt) {
    if (prompt.contains('=') || prompt.contains('^')) {
      return '''Below is a mathematical problem. Format the solution using proper mathematical notation with clear steps.

### Instruction:
${prompt.replaceAll('^', '\\^')}

### Response:''';
    }

    return '''Below is an instruction that describes a task. Write a concise response without any HTML formatting.

### Instruction:
$prompt

### Response:''';
  }

  Map<String, dynamic> _getParameters(String prompt) {
    final isSimple = _isSimpleQuery(prompt);
    return {
      'max_length': isSimple ? 1 : 2048,
      'min_length': 1,
      'temperature': isSimple ? 0.5 : 0.7,
      'top_p': 0.9,
      'return_full_text': false,
      'max_new_tokens': 4096,
      'repetition_penalty': 1.2,
      'no_repeat_ngram_size': 3,
    };
  }

  bool _isSimpleQuery(String prompt) {
    final questionWords = ['what', 'when', 'where', 'who', 'why', 'how'];
    final trimmedPrompt = prompt.trim().toLowerCase();
    final isShortPrompt = trimmedPrompt.split(' ').length <= 15;
    final isQuestion =
        questionWords.any((word) => trimmedPrompt.startsWith(word));
    return isShortPrompt || isQuestion;
  }

  String _processResponse(dynamic decodedResponse) {
    if (decodedResponse is List && decodedResponse.isNotEmpty) {
      final firstElement = decodedResponse[0];
      if (firstElement is Map<String, dynamic>) {
        String response = firstElement['generated_text']?.toString() ??
            'No valid response generated.';

        // Clean up the response markers and whitespace
        response = response
            .replaceAll(RegExp(r'###.*?###'), '')
            .replaceAll('Response:', '')
            .replaceAll('Instruction:', '')
            .trim();

        // Clean up italics formatting - this now happens for all responses
        response = response
            .replaceAllMapped(
              RegExp(r'\\(?:textit|emph)\{(.*?)\}'),
              (match) => match.group(1) ?? '',
            )
            .replaceAllMapped(
              RegExp(r'\\textit\s*\{([^}]*)\}'),
              (match) => match.group(1) ?? '',
            )
            .replaceAllMapped(
              RegExp(r'\\emph\s*\{([^}]*)\}'),
              (match) => match.group(1) ?? '',
            );

        // Handle mathematical expressions if present
        if (response.contains(r'\frac') ||
            response.contains(r'\sqrt') ||
            response.contains(r'\Delta') ||
            response.contains(r'\text') ||
            response.contains(r'\pm') ||
            response.contains(r'\cdot') ||
            response.contains(r'\{') ||
            response.contains(r'\}') ||
            response.contains(r'\^') ||
            response.contains('_') ||
            response.contains('=')) {
          var lines = response.split('\n');
          var formattedLines = lines.map((line) {
            if (line.contains(r'\frac') ||
                line.contains(r'\sqrt') ||
                line.contains(r'\Delta') ||
                line.contains(r'\text') ||
                line.contains(r'\pm') ||
                line.contains(r'\cdot') ||
                line.contains(r'\^') ||
                line.contains('=')) {
              return r'\[' + line + r'\]';
            }
            return line;
          });
          response = formattedLines.join('\n');
        }

        return response.isEmpty ? 'No valid response generated.' : response;
      }
      return 'Invalid response format.';
    }
    return 'No valid response generated.';
  }

  String _handleError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 503:
        return 'Service temporarily unavailable. Retrying...';
      case 500:
        return 'Model too busy. Please try again in 60 Seconds';
      case 401:
        return 'Unauthorized. Please check your API token.';
      case 400:
        return 'Bad request. Ensure the prompt is formatted correctly.';
      case 429:
        return 'Rate limit exceeded. Please wait and try again.';
      default:
        return 'Error: $statusCode. Details: $responseBody';
    }
  }
}

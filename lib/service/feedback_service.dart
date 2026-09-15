import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:js_trions/config.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';

/// Maximum time to wait for a single feedback endpoint attempt
const _kFeedbackTimeout = Duration(seconds: 15);

/// Outcome of a single feedback endpoint attempt
enum FeedbackAttemptResult {
  none,

  /// The backend confirmed the feedback was created
  success,

  /// The backend was reached, or the outcome cannot be proven, the request must not be retried elsewhere
  failed,

  /// The request provably never reached the feedback backend, retrying elsewhere is safe
  unreachable,
}

/// Send feedback to the primary endpoint, fall back to the legacy endpoint only when the primary provably never processed the request
Future<bool> sendFeedback({required String version, required String name, required String email, required String subject, required String message}) async {
  final parameters = <String, String>{
    'app': 'js_trions',
    'version': version,
    'platform': Platform.operatingSystem.toLowerCase(),
    'name': name,
    'email': email,
    'subject': subject,
    'message': message,
  };

  final primaryResult = await _sendFeedbackTo(kFeedbackUrl, parameters);

  /// createFeedback is not idempotent, it writes the document and sends the admin email before responding,
  /// so retry the legacy endpoint only when the primary attempt proves nothing was processed
  if (primaryResult != FeedbackAttemptResult.unreachable) {
    return primaryResult == FeedbackAttemptResult.success;
  }

  final fallbackResult = await _sendFeedbackTo(kFeedbackFallbackUrl, parameters);

  return fallbackResult == FeedbackAttemptResult.success;
}

/// Send feedback to one concrete endpoint and classify how it ended
Future<FeedbackAttemptResult> _sendFeedbackTo(String url, Map<String, String> parameters) async {
  http.Response response;

  try {
    response = await http.get(Uri.parse(url).replace(queryParameters: parameters)).timeout(_kFeedbackTimeout);
  } on SocketException catch (e, t) {
    /// Connection refused or DNS failure, the request never left the device
    debugPrint('TCH_e $e');
    debugPrintStack(stackTrace: t);

    return FeedbackAttemptResult.unreachable;
  } on http.ClientException catch (e, t) {
    /// Connection could not be established or was dropped before a response
    debugPrint('TCH_e $e');
    debugPrintStack(stackTrace: t);

    return FeedbackAttemptResult.unreachable;
  } catch (e, t) {
    /// Timeouts and any other transport error may still have been processed by the backend
    debugPrint('TCH_e $e');
    debugPrintStack(stackTrace: t);

    return FeedbackAttemptResult.failed;
  }

  final Map<String, dynamic>? json = _decodeApiResponse(response);

  if (json == null) {
    /// The SPA catch-all answers any unmatched /api/* path with HTML and status 200, so a non JSON body below 500
    /// means the request never reached the feedback backend, above it the response may come from a proxy after processing
    return response.statusCode >= 500 ? FeedbackAttemptResult.failed : FeedbackAttemptResult.unreachable;
  }

  if (response.statusCode >= 400 || json['success'] == null) {
    return FeedbackAttemptResult.failed;
  }

  return FeedbackAttemptResult.success;
}

/// Decode the response as the api JSON envelope, null when the response is not a JSON envelope of the feedback backend
Map<String, dynamic>? _decodeApiResponse(http.Response response) {
  final contentType = response.headers['content-type'];

  if (contentType == null || !contentType.toLowerCase().contains('application/json')) {
    return null;
  }

  try {
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || (!decoded.containsKey('success') && !decoded.containsKey('error'))) {
      return null;
    }

    return decoded;
  } catch (e, t) {
    debugPrint('TCH_e $e');
    debugPrintStack(stackTrace: t);

    return null;
  }
}

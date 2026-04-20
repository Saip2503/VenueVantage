class ErrorUtils {
  /// Maps technical error messages to user-friendly ones.
  static String getFriendlyMessage(dynamic error) {
    final errStr = error.toString().toLowerCase();

    if (errStr.contains('network') || errStr.contains('connectivity') || errStr.contains('socketexception')) {
      return 'Connection issues. Please check your signal and try again.';
    }
    
    if (errStr.contains('permission-denied') || errStr.contains('access-denied')) {
      return 'Access restricted. Please sign in again.';
    }

    if (errStr.contains('user-not-found') || errStr.contains('wrong-password')) {
      return 'Invalid credentials. Please try again.';
    }

    if (errStr.contains('quota') || errStr.contains('limit')) {
      return 'High traffic detected. Please wait a moment and try again.';
    }

    if (errStr.contains('not found')) {
      return 'The requested resource is currently unavailable.';
    }

    // Default generic message for everything else
    return 'Something went wrong. Our team is looking into it.';
  }
}

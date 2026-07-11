class RouterOsApiException implements Exception {
  const RouterOsApiException(this.message, {this.category, this.cause});

  final String message;
  final String? category;
  final Object? cause;

  @override
  String toString() {
    final categoryText = category == null ? '' : ' [$category]';
    return 'RouterOsApiException$categoryText: $message';
  }
}

class RouterOsTrapException extends RouterOsApiException {
  const RouterOsTrapException(super.message, {super.category, super.cause});
}

class RouterOsConnectionException extends RouterOsApiException {
  const RouterOsConnectionException(super.message, {super.cause})
      : super(category: 'connection');
}

class RouterOsAuthenticationException extends RouterOsApiException {
  const RouterOsAuthenticationException(super.message, {super.cause})
      : super(category: 'authentication');
}

class RouterOsVpnRequiredException extends RouterOsApiException {
  const RouterOsVpnRequiredException(super.message)
      : super(category: 'vpn_required');
}

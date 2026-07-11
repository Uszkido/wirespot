sealed class NetworkResult<T> {
  const NetworkResult();
}

class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data);

  final T data;
}

class NetworkFailure<T> extends NetworkResult<T> {
  const NetworkFailure(this.message, {this.cause});

  final String message;
  final Object? cause;
}

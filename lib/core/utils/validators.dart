class Validators {
  const Validators._();

  static String? requiredText(String? value, {String label = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }
}

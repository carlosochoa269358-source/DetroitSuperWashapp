class Validators {
  Validators._();

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^3\d{9}$');
    if (!regex.hasMatch(value)) {
      return 'Formato de teléfono inválido (ej: 3001234567)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Correo electrónico inválido';
    }
    return null;
  }

  static String? validatePlate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[a-zA-Z]{3}[0-9]{2}[a-zA-Z0-9]{1}$');
    if (!regex.hasMatch(value)) {
      return 'Placa inválida (ej: ABC123, ABC12D)';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(cleanValue);
    if (amount == null || amount <= 0) {
      return 'Monto inválido';
    }
    return null;
  }
}

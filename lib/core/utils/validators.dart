// class Validators {
//   Validators._();

//   static bool isStrongPassword(String password) {
//     if (password.length < 8) return false;
//     final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);
//     return hasSpecialChar;
//   }

//   static String? passwordErrorMessage(String password) {
//     if (password.length < 8) return 'Password must be at least 8 characters';
//     if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
//       return 'Password must include at least one special character';
//     }
//     return null;
//   }

//   static bool isValidEmail(String email) {
//     final e = email.trim().toLowerCase();
//     return RegExp(r'^[\w.+-]+@(gmail|ymail|hotmail)\.com$').hasMatch(e);
//   }

//   static bool isValidPhone(String phone) {
//     final p = phone.trim();
//     final local = RegExp(r'^03\d{9}$'); // 03000000000
//     final intl = RegExp(r'^\+92 \d{3} \d{7}$'); // +92 300 0000000
//     return local.hasMatch(p) || intl.hasMatch(p);
// } 

//   static bool isValidCnic(String cnic) {
//     final c = cnic.trim();
//     return RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(c);
//   }
// }

class Validators {
  Validators._();

  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);
    return hasSpecialChar;
  }

  static String? passwordErrorMessage(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
      return 'Password must include at least one special character';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    final e = email.trim().toLowerCase();
    return RegExp(r'^[\w.+-]+@(gmail|ymail|hotmail)\.com$').hasMatch(e);
  }

  static String? emailErrorMessage(String email) {
    if (email.trim().isEmpty) return 'Email is required';
    if (!isValidEmail(email)) {
      return 'Only gmail.com, ymail.com, hotmail.com emails are allowed';
    }
    return null;
  }

  static bool isValidPhone(String phone) {
    final p = phone.trim();
    final local = RegExp(r'^03\d{9}$'); // 03000000000
    final intl = RegExp(r'^\+92 \d{3} \d{7}$'); // +92 300 0000000
    return local.hasMatch(p) || intl.hasMatch(p);
  }

  static String? phoneErrorMessage(String phone) {
    if (phone.trim().isEmpty) return 'Phone number is required';
    if (!isValidPhone(phone)) {
      return 'Enter a valid number: 03XXXXXXXXX or +92 3XX XXXXXXX';
    }
    return null;
  }

  static bool isValidCnic(String cnic) {
    final c = cnic.trim();
    return RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(c);
  }
}
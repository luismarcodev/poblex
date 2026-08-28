class ForgotPasswordRequestModel {
  const ForgotPasswordRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email.trim()};
}

class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;

  Map<String, dynamic> toJson() => {
    'token': token.trim(),
    'newPassword': newPassword,
  };
}

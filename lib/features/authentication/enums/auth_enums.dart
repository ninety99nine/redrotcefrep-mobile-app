/// Do not change the order of these values. They are required 
/// to set the stages whenever the form is saved on the device
enum SigninStage {
  enterMobileNumber,
  enterPassword,
  setNewPassword,
  enterVerificationCode
}

/// Do not change the order of these values. They are required 
/// to set the stages whenever the form is saved on the device
enum SignupStage {
  enterInfo,
  enterVerificationCode
}

/// Do not change the order of these values. They are required 
/// to set the stages whenever the form is saved on the device
enum ForgotPasswordStage {
  setNewPassword,
  enterVerificationCode
}

enum AuthFormType {
  signin,
  signup,
  resetPassword
}

enum LogoutType {
  everyone,
  others
}
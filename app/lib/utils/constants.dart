import 'dart:ui' as ui;

class Constants {
  static const EMAIL_REGEX =
      "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
  static const USERNAME_REGEX = r"^(?=.{3,12}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$";

  // static const PASSWORD_REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*d)(?=.*[@\$!%*?&])[A-Za-zd@\$!%*?&]{8,16}\$";
  static const PASSWORD_REGEX = r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&,.])[A-Za-z\d@$!%*#?&,.]{8,16}$";
  static const URL_REGEX = r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\-\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)";

  // static const URL_REGEX = r"((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)g";
  // static const URL_REGEX =  r"((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?)";

  static const RESOURCE_NOT_FOUND = 10003;
  static const INVALID_USERNAME_AND_PASSWORD = 20001;
  static const INVALID_VALIDATION_CODE = 20003;
  static const USERNAME_ALREADY_REGISTERED = 20008;
  static const EMAIL_ALREADY_VALIDATED = 20009;
  static const EDIT_NAME_TOO_OFTEN = 20016;
  static const POST_NOT_IN_WAITING_LIST = 30001;
  static const INSUFFICIENT_FUNDS = 40000;
  static const double SECTION_BUTTON_WIDTH = 80;
  static const double SECTION_BUTTON_HEIGHT = 32;
}

//region global variants
late ui.Image scaleButtonImage;
//endregion

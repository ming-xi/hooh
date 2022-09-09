class Constants {
  static const EMAIL_REGEX =
      "(?:[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
  static const USERNAME_REGEX = r"^(?=.{3,12}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$";

  // static const PASSWORD_REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*d)(?=.*[@\$!%*?&])[A-Za-zd@\$!%*?&]{8,16}\$";
  static const PASSWORD_REGEX = r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&,.])[A-Za-z\d@$!%*#?&,.]{8,16}$";
  static const URL_REGEX = r"((https?|http):\/\/)?(www.)?[a-z0-9]+\.[a-z]+(\/[a-zA-Z0-9#]+\/?)*";

  static const RESOURCE_NOT_FOUND = 10003;
  static const INVALID_USERNAME_AND_PASSWORD = 20001;
  static const INVALID_VALIDATION_CODE = 20003;
  static const USERNAME_ALREADY_REGISTERED = 20008;
  static const EMAIL_ALREADY_VALIDATED = 20009;
  static const EDIT_NAME_TOO_OFTEN = 20016;
  static const USER_IS_NOT_ADMIN = 20017;
  static const INSUFFICIENT_FUNDS = 40000;
  static const double SECTION_BUTTON_WIDTH = 80;
  static const double SECTION_BUTTON_HEIGHT = 32;

  static const PAGE_ID_TEMPLATES = 0;
  static const PAGE_NAME_TEMPLATES = "模板管理";
  static const PAGE_ID_USERS = 1;
  static const PAGE_NAME_USERS = "用户管理";
  static const PAGE_ID_POSTS = 2;
  static const PAGE_NAME_POSTS = "帖子管理";
  static const PAGE_ID_CONFIGS = 3;
  static const PAGE_NAME_CONFIGS = "参数设置";
  static const PAGE_ID_STATISTICS = 4;
  static const PAGE_NAME_STATISTICS = "数据统计";
}

//region global variants
// late ui.Image scaleButtonImage;
//endregion

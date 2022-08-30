import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/post_detail.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/templates.dart';
import 'package:app/ui/pages/home/templates_view_model.dart';
import 'package:app/ui/pages/me/badges.dart';
import 'package:app/ui/pages/user/user_profile.dart';
import 'package:app/ui/widgets/template_detail_view.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/ui_utils.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _LINK_PREFIX = "$_LINK_SCHEME://$_LINK_HOST";
const _LINK_SCHEME = "hoohlanding";
const _LINK_HOST = "lz.hooh.zone";
const _LINK_POSTS = "posts";
const _LINK_USERS = "users";
const _LINK_TEMPLATES = "templates";
const _LINK_BADGES = "badges";
const String _UUID_REGEX = "[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}";

String getTemplateAppLink(String id) {
  return "$_LINK_PREFIX/$_LINK_TEMPLATES/$id";
}

String getUserAppLink(String id) {
  return "$_LINK_PREFIX/$_LINK_USERS/$id";
}

void openAppLink(BuildContext context, String? link, {WidgetRef? ref}) {
  debugPrint("openAppLink link=$link");
  if (link == null) {
    return;
  }
  if (!_checkHost(link)) {
    // simple url
    openLink(context, link);
    return;
  }
  if (_isPostLink(link)) {
    String uuid = _getSingleUuid(link);
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postId: uuid)));
  } else if (_isUserLink(link)) {
    String uuid = _getSingleUuid(link);
    if (_isUserBadgeLink(link)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BadgesScreen(userId: uuid)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: uuid)));
    }
  } else if (_isTemplateLink(link)) {
    Uri? uri = Uri.tryParse(link);
    if (uri != null) {
      bool hit = false;
      if (ref != null) {
        List<TemplateTagItem> tags = ref.read(galleryTemplatesProvider).tags;
        int? index;
        int? type = int.tryParse(uri.queryParameters['type'] ?? "");
        String? tag = uri.queryParameters['tag'];
        if (type != null) {
          for (int i = 0; i < tags.length; i++) {
            TemplateTagItem item = tags[i];
            if (item.type == type) {
              index = i;
              hit = true;
              break;
            }
          }
        }
        if (tag != null) {
          for (int i = 0; i < tags.length; i++) {
            TemplateTagItem item = tags[i];
            if (item.tag == tag) {
              index = i;
              hit = true;
              break;
            }
          }
        }
        if (index != null) {
          ref.read(homePageProvider.notifier).updateTabIndex(1);
          ref.read(galleryTemplatesProvider.notifier).setSelectedTag(index);
          popToHomeScreen(context);
        }
        if (!hit) {
          String uuid = _getSingleUuid(link);
          network.requestAsync<Template>(network.getTemplateInfo(uuid), (data) {
            TemplateDetailView.showTemplateDialog(context, ref, data);
          }, (error) {
            if (error.errorCode == Constants.RESOURCE_NOT_FOUND) {
              showHoohDialog(
                  context: context,
                  builder: (popContext) => AlertDialog(
                        title: Text(globalLocalizations.error_view_template_not_found),
                      ));
            } else {
              showCommonRequestErrorDialog(ref, context, error);
            }
          });
        }
        // Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postId: uuid)));
      }
    }
  }
}

List<String> _getUuids(String link) {
  return RegExp(_UUID_REGEX).allMatches(link).map((e) => link.substring(e.start, e.end)).toList();
}

String _getSingleUuid(String link) {
  List<String> uuids = _getUuids(link);
  return uuids.first;
}

bool _checkHost(String link) {
  return link.startsWith(_LINK_PREFIX);
}

bool _isPostLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_POSTS/$_UUID_REGEX");
  var result = regExp.matchAsPrefix(link) != null;
  debugPrint("_isPostLink=$result");
  return result;
}

bool _isUserLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_USERS/$_UUID_REGEX");
  var result = regExp.matchAsPrefix(link) != null;
  debugPrint("_isUserLink=$result");
  return result;
}

bool _isTemplateLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_TEMPLATES");
  var result = regExp.matchAsPrefix(link) != null;
  debugPrint("_isTemplateLink=$result");
  return result;
}

bool _isUserBadgeLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_USERS/$_UUID_REGEX/$_LINK_BADGES");
  var result = regExp.matchAsPrefix(link) != null;
  debugPrint("_isUserBadgeLink=$result");
  return result;
}

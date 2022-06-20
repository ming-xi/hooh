import 'package:app/global.dart';
import 'package:app/ui/pages/feeds/post_detail.dart';
import 'package:app/ui/pages/home/home.dart';
import 'package:app/ui/pages/home/templates.dart';
import 'package:app/ui/pages/home/templates_view_model.dart';
import 'package:app/ui/pages/me/badges.dart';
import 'package:app/ui/pages/user/templates.dart';
import 'package:app/ui/pages/user/user_profile.dart';
import 'package:app/ui/widgets/template_detail_view.dart';
import 'package:common/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _LINK_PREFIX = "$_LINK_SCHEME://$_LINK_HOST";
const _LINK_SCHEME = "https";
const _LINK_HOST = "landing.hooh.zone";
const _LINK_POSTS = "posts";
const _LINK_USERS = "users";
const _LINK_TEMPLATES = "templates";
const _LINK_BADGES = "badges";
const String _UUID_REGEX = "[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}";

String getTemplateAppLink(String id) {
  return "$_LINK_PREFIX/$_LINK_TEMPLATES/$id";
}

void openAppLink(BuildContext context, String? link, {WidgetRef? ref}) {
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: uuid)));
    if (_isUserBadgeLink(link)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BadgesScreen(userId: uuid)));
    }
  } else if (_isTemplateLink(link)) {
    Uri? uri = Uri.tryParse(link);
    if (uri != null) {
      bool hit = false;
      if (ref != null) {
        List<TemplateTagItem> tags = ref.read(homeTemplatesProvider).tags;
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
          ref.read(homeTemplatesProvider.notifier).setSelectedTag(index);
          popToHomeScreen(context);
        }
        if (!hit) {
          String uuid = _getSingleUuid(link);
          debugPrint("uuid=$uuid");
          network.getTemplateInfo(uuid).then((value) {
            TemplateDetailView.showTemplateDialog(context, ref, value);
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
  return regExp.matchAsPrefix(link) != null;
}

bool _isUserLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_USERS/$_UUID_REGEX");
  return regExp.matchAsPrefix(link) != null;
}

bool _isTemplateLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_TEMPLATES");
  return regExp.matchAsPrefix(link) != null;
}

bool _isUserBadgeLink(String link) {
  RegExp regExp = RegExp("$_LINK_PREFIX/$_LINK_USERS/$_UUID_REGEX/$_LINK_BADGES");
  return regExp.matchAsPrefix(link) != null;
}

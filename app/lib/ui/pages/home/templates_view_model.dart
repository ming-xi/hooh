import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:collection/collection.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'templates_view_model.g.dart';

@CopyWith()
class TemplatesPageModelState {
  final List<Template> templates;
  final List<String> contents;
  final List<PostImageSetting> postImageSettings;
  final int page;
  final PageState templatesPageState;
  final PageState tagsPageState;
  final HoohApiErrorResponse? error;
  final List<TemplateTagItem> tags;
  final DateTime? lastTimestamp;
  final bool agreementChecked;
  final bool noRewardsChecked;

  TemplatesPageModelState({
    required this.templates,
    required this.postImageSettings,
    required this.contents,
    required this.templatesPageState,
    required this.tagsPageState,
    required this.error,
    required this.tags,
    required this.page,
    required this.lastTimestamp,
    required this.agreementChecked,
    required this.noRewardsChecked,
  });

  TemplateTagItem? selectedTag() => tags.singleWhereOrNull((element) => element.selected);

  factory TemplatesPageModelState.init({List<String> contents = const []}) => TemplatesPageModelState(
      templates: [],
      postImageSettings: [],
      contents: contents,
      templatesPageState: PageState.inited,
      tagsPageState: PageState.inited,
      error: null,
      tags: [],
      page: 1,
      lastTimestamp: null,
      agreementChecked: preferences.getBool(Preferences.KEY_UPLOAD_TEMPLATE_AGREEMENT_CHECKED) ?? false,
      noRewardsChecked: preferences.getBool(Preferences.KEY_USE_LOCAL_IMAGE_NO_REWARDS_CHECKED) ?? false);
}

class TemplatesPageViewModel extends StateNotifier<TemplatesPageModelState> {
  TemplatesPageViewModel(TemplatesPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getRecommendedTags();
  }

  Future<void> getRecommendedTags() async {
    if (state.tagsPageState == PageState.loading) {
      return;
    } else {
      if (state.tagsPageState == PageState.dataLoaded) {
        return;
      }
    }
    updateState(state.copyWith(tagsPageState: PageState.loading));
    network.requestAsync<List<RecommendedTag>>(network.getRecommendedTags(), (data) {
      var list = data.map((e) => TemplateTagItem(e.name, e.type, false)).toList();
      if (list.isNotEmpty) {
        list[0].selected = true;
      }
      updateState(state.copyWith(
        tagsPageState: PageState.dataLoaded,
        tags: list,
      ));
      getImageList((succeed) => null);
    }, (error) {
      updateState(state.copyWith(
        error: error,
        tagsPageState: PageState.inited,
      ));
      // debugPrint("error");
    });
  }

  void getImageList(Function(PageState)? callback, {bool isRefresh = true}) {
    if (!state.tags.any((element) => element.selected)) {
      return;
    }
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null, page: 1));
      if (state.templatesPageState == PageState.loading) {
        if (callback != null) {
          callback(state.templatesPageState);
        }
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.templatesPageState)) {
        if (callback != null) {
          callback(state.templatesPageState);
        }
        return;
      }
    }
    updateState(state.copyWith(templatesPageState: PageState.loading));
    // if (state.selectedCategory == null) {
    //   if (callback != null) {
    //     callback(state.templatesPageState);
    //   }
    //   return;
    // }

    TemplateTagItem selected = state.tags.firstWhere((element) => element.selected);
    Future<List<Template>> searchFunction;
    DateTime date = state.lastTimestamp ?? DateUtil.getCurrentUtcDate();
    if (selected.type == null) {
      searchFunction = network.searchTemplatesByTag(
        selected.tag,
        date,
      );
    } else {
      searchFunction = network.searchTemplatesByType(selected.type!, date: date, page: state.page);
    }
    network.requestAsync<List<Template>>(searchFunction, (newData) {
      if (newData.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(templatesPageState: isRefresh ? PageState.empty : PageState.noMore, templates: [], postImageSettings: []));
        } else {
          updateState(state.copyWith(templatesPageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.templatesPageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(
              templatesPageState: PageState.dataLoaded,
              lastTimestamp: newData.last.featuredAt,
              templates: newData,
              postImageSettings: state.contents.isEmpty ? [] : newData.map((e) => PostImageSetting.withTemplate(e, text: state.contents[0])).toList(),
              page: state.page + 1));
        } else {
          updateState(state.copyWith(
              templatesPageState: PageState.dataLoaded,
              lastTimestamp: newData.last.featuredAt,
              templates: [...state.templates, ...newData],
              postImageSettings: state.contents.isEmpty
                  ? []
                  : [...state.postImageSettings, ...newData.map((e) => PostImageSetting.withTemplate(e, text: state.contents[0])).toList()],
              page: state.page + 1));
        }
      }
      if (callback != null) {
        callback(state.templatesPageState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        templatesPageState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.templatesPageState);
      }
    });
  }

  void setAgreementChecked(bool checked) {
    updateState(state.copyWith(agreementChecked: checked));
  }

  void setContents(List<String> contents) {
    updateState(state.copyWith(contents: contents));
  }

  void setNoRewardsChecked(bool checked) {
    updateState(state.copyWith(noRewardsChecked: checked));
  }

  void setSelectedTag(int index) {
    List<TemplateTagItem> tags = state.tags;
    for (var item in tags) {
      item.selected = false;
    }
    tags[index].selected = true;
    updateState(state.copyWith(tags: [...tags]));
    getImageList((state) => null);
  }

  void setFavorite(int itemIndex, bool favorite) {
    // Future<void> request = favorite ? network.favoriteTemplate(state.templates[itemIndex].id) : network.cancelFavoriteTemplate(state.templates[itemIndex].id);
    // network.requestAsync(request, (data) {
    //   debugPrint("setFavorite 1");
    //   state.templates[itemIndex].favorited = favorite;
    //   if (state.selectedTag()?.type == Network.SEARCH_TEMPLATE_TYPE_FAVORITED) {
    //     debugPrint("Favorite");
    //     state.templates.removeAt(itemIndex);
    //   }
    //   updateState(state.copyWith(templates: [...state.templates]));
    // }, (error) {
    //   debugPrint("setFavorite 2");
    //   state.templates[itemIndex].favorited = !favorite;
    //   updateState(state.copyWith(templates: [...state.templates]));
    // });

    if (favorite) {
      network.requestAsync(network.favoriteTemplate(state.templates[itemIndex].id), (data) {
        // debugPrint("setFavorite 1");
        state.templates[itemIndex].favorited = favorite;
        if (state.selectedTag()?.type == Network.SEARCH_TEMPLATE_TYPE_FAVORITED) {
          // debugPrint("Favorite");
          state.templates.removeAt(itemIndex);
        }
        updateState(state.copyWith(templates: [...state.templates]));
      }, (error) {
        // debugPrint("setFavorite 2");
        state.templates[itemIndex].favorited = !favorite;
        updateState(state.copyWith(templates: [...state.templates]));
      });
    } else {
      network.requestAsync(network.cancelFavoriteTemplate(state.templates[itemIndex].id), (data) {
        // debugPrint("setFavorite 3");
        state.templates[itemIndex].favorited = favorite;
        if (state.selectedTag()?.type == Network.SEARCH_TEMPLATE_TYPE_FAVORITED) {
          // debugPrint("Favorite");
          state.templates.removeAt(itemIndex);
        }
        updateState(state.copyWith(templates: [...state.templates]));
      }, (error) {
        // debugPrint("setFavorite 4");
        state.templates[itemIndex].favorited = !favorite;
        updateState(state.copyWith(templates: [...state.templates]));
      });
    }
  }
}

class TemplateTagItem {
  static const SEARCH_TYPE_RECENT = 0;
  static const SEARCH_TYPE_TRENDING = 1;
  static const SEARCH_TYPE_FAVORITES = 2;

  final String tag;
  final int? type;
  bool selected;

  TemplateTagItem(this.tag, this.type, this.selected);
}

import 'package:app/ui/pages/creation/edit_post_view_model.dart';
import 'package:app/utils/creation_strategy.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'recommended_templates_view_model.g.dart';

@CopyWith()
class RecommendedTemplatesScreenModelState {
  final List<Template> templates;
  final List<PostImageSetting> postImageSettings;
  final List<String> contents;
  final PageState pageState;

  RecommendedTemplatesScreenModelState({
    required this.templates,
    required this.postImageSettings,
    required this.contents,
    required this.pageState,
  });

  factory RecommendedTemplatesScreenModelState.init(List<String> contents) =>
      RecommendedTemplatesScreenModelState(templates: [], postImageSettings: [], contents: contents, pageState: PageState.inited);
}

class RecommendedTemplatesScreenViewModel extends StateNotifier<RecommendedTemplatesScreenModelState> {
  RecommendedTemplatesScreenViewModel(RecommendedTemplatesScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
  }

  void getRecommendedTemplates({required void Function() onComplete, required void Function(HoohApiErrorResponse ex) onError}) {
    if (state.pageState == PageState.loading) {
      return;
    }
    updateState(state.copyWith(pageState: PageState.loading));
    network.requestAsync<List<Template>>(network.getRecommendedTemplates(state.contents), (data) {
      updateState(state.copyWith(
        templates: data,
        postImageSettings: data.map((e) => PostImageSetting.withTemplate(e, text: state.contents[0])).toList(),
        // templates: data.sublist(0, CreationStrategy.FONT_FOR_RANDOM.length * CreationStrategy.getStopsCount()),
        // postImageSettings: data
        //     .sublist(0, CreationStrategy.FONT_FOR_RANDOM.length * CreationStrategy.getStopsCount())
        //     .map((e) => PostImageSetting.withTemplate(data[0],
        //         font: CreationStrategy.FONT_FOR_RANDOM[(data.indexOf(e) ~/ textList.length) % CreationStrategy.FONT_FOR_RANDOM.length],
        //         text: textList[data.indexOf(e) % textList.length]))
        //     .toList(),
        pageState: PageState.dataLoaded,
      ));
      onComplete();
    }, (error) {
      updateState(state.copyWith(
        pageState: PageState.dataLoaded,
      ));
      onError(error);
    });
  }

  void setFavorite(int itemIndex, bool favorite) {
    if (favorite) {
      network.requestAsync(network.favoriteTemplate(state.templates[itemIndex].id), (data) {
        state.templates[itemIndex].favorited = favorite;
        updateState(state.copyWith(
          templates: [...state.templates],
        ));
      }, (error) {
        state.templates[itemIndex].favorited = !favorite;
        updateState(state.copyWith(templates: [...state.templates]));
      });
    } else {
      network.requestAsync(network.cancelFavoriteTemplate(state.templates[itemIndex].id), (data) {
        state.templates[itemIndex].favorited = favorite;
        updateState(state.copyWith(templates: [...state.templates]));
      }, (error) {
        state.templates[itemIndex].favorited = !favorite;
        updateState(state.copyWith(templates: [...state.templates]));
      });
    }
  }

  // var textList=[
  //   "Hi",
  //   "Great!",
  //   "This is good idea!",
  //   "Sometimes I really want to be a good man, but I can't.",
  //   "So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then?",
  //   "So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go ",
  // ];

  // static const _FONT_LEN_STOP1 = 6~/2;
  // static const _FONT_LEN_STOP2 = 16~/2;
  // static const _FONT_LEN_STOP3 = 40~/2;
  // static const _FONT_LEN_STOP4 = 100~/2;
  // static const _FONT_LEN_STOP5 = 200~/2;
  var textList = [
    "原神",
    "白皑中的冥想",
    "玩家将扮演一位名为“旅行者”的神秘角色",
    "游戏发生在一个被称作“提瓦特”的幻想世界，在这里，被神选中的人将被授予“神之眼”，导引元素之力。",
    "2022年，米哈游原神音乐团队参与了第二十四届冬奥会音乐库的组建，《璃月》《白皑中的冥想》《疾如猛火》等曲目入选，音乐同步应用于相关的体育展示环节 [178-180]  。",
    "《原神》是由上海米哈游网络科技股份有限公司制作发行的一款开放世界冒险游戏，于2017年1月底立项 [28]  ，原初测试于2019年6月21日开启 [1]  ，再临测试于2020年3月19日开启 [2]  ，启程测试于2020年6月11日开启 [3]  ，PC版技术性开放测试于9月15日开启，公测于2020年9月28日开启 [4]  。",
    // "Hi",
    // "Great!",
    // "What a good idea!",
    // "Sometimes I really want to be a good man, but no",
    // "So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go!",
    // "So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go and take a look!So, what is your problem, then? Let's go ",
  ];
}

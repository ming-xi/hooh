import 'dart:math';

import 'package:app/ui/pages/test_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//test provider and view model
class TestViewModelScreen extends ConsumerStatefulWidget {
  final StateNotifierProviderFamily<TestPageViewModel, TestPageModelState, int> postsProvider =
      StateNotifierProvider.family<TestPageViewModel, TestPageModelState, int>((ref, width) => TestPageViewModel(TestPageModelState.init(width, true)));

  TestViewModelScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestViewModelScreen> {
  @override
  Widget build(BuildContext context) {
    StateNotifierProvider<TestPageViewModel, TestPageModelState> provider = widget.postsProvider(1);
    TestPageModelState modelState = ref.watch(provider);
    TestPageViewModel viewModel = ref.watch(provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: Center(
        child: Text(modelState.keyword),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text(modelState.pageIndex.toString()),
        onPressed: () {
          viewModel.update(modelState.copyWith(pageIndex: modelState.pageIndex + 1, keyword: Random().nextInt(1000).toString()));
        },
      ),
    );
  }
}

class TestTintScreen extends ConsumerStatefulWidget {
  const TestTintScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestTintPageState();
}

class _TestTintPageState extends ConsumerState<TestTintScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("tint")),
      body: Center(
        child: Stack(children: [
          Image.asset('assets/images/test_3.png',
              colorBlendMode: BlendMode.srcATop, color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6)),
        ]),
      ),
    );
  }
}

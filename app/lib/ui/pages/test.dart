import 'dart:math' ;

import 'package:app/ui/pages/test_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//test provider and view model
class TestPage extends ConsumerStatefulWidget {
  final StateNotifierProviderFamily<TestPageViewModel, TestPageModelState, int> postsProvider =
  StateNotifierProvider.family<TestPageViewModel, TestPageModelState, int>((ref, width) => TestPageViewModel(TestPageModelState.init(width, true)));

  TestPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {

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
          viewModel.update(modelState.copyWith(pageIndex: modelState.pageIndex + 1,keyword: Random().nextInt(1000).toString()));
        },
      ),
    );
  }
}

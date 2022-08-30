import 'package:app/ui/pages/user/register/styles.dart';
import 'package:app/utils/constants.dart';
import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestRegexScreen extends ConsumerStatefulWidget {
  const TestRegexScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _TestRegexScreenState();
}

class _TestRegexScreenState extends ConsumerState<TestRegexScreen> {
  TextEditingController regexController = TextEditingController(text: Constants.URL_REGEX);
  TextEditingController textController = TextEditingController(text: "https://store.steampowered.com/app/1640820");
  String result = "";

  @override
  void initState() {
    super.initState();
    match();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Regex")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: TextField(
              decoration: RegisterStyles.commonInputDecoration("regex", ref).copyWith(contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              maxLines: 10,
              controller: regexController,
              onChanged: (value) {
                match();
              },
            )),
            SizedBox(
              height: 24,
            ),
            Expanded(
                child: TextField(
              decoration: RegisterStyles.commonInputDecoration("text", ref).copyWith(contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              maxLines: 10,
              controller: textController,
              onChanged: (value) {
                match();
              },
            )),
            SizedBox(
              height: 24,
            ),
            Expanded(
                child: Text(
              result,
              maxLines: 10,
              style: TextStyle(color: designColors.dark_01.auto(ref)),
            )),
          ],
        ),
      ),
    );
  }

  void match() {
    RegExp regExp = RegExp(regexController.text.trim());
    String text = textController.text.trim();
    setState(() {
      Iterable<RegExpMatch> allMatches = regExp.allMatches(text);
      debugPrint("allMatches=${allMatches.length}");
      result = allMatches.map((e) {
        return text.substring(e.start, e.end);
      }).join("\n");
    });
  }
}

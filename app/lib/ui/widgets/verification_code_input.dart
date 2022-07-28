import 'package:app/utils/design_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationCodeInput2 extends ConsumerStatefulWidget {
  final Function(String code) onComplete;
  final TextEditingController textEditingController;

  const VerificationCodeInput2({
    required this.textEditingController,
    required this.onComplete,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _VerificationCodeInput2State();
}

class _VerificationCodeInput2State extends ConsumerState<VerificationCodeInput2> {
  List<FilteringTextInputFormatter> formatters = [FilteringTextInputFormatter.allow(RegExp("[0-9]"))];
  double frameHeight = 64;
  double frameSpacing = 8;
  int numberCount = 6;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: numberCount,
      obscureText: false,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(18),
          fieldHeight: frameHeight,
          // fieldOuterPadding: EdgeInsets.symmetric(horizontal: frameSpacing / 2),
          fieldWidth: 48,
          borderWidth: 1,
          activeFillColor: designColors.light_01.auto(ref),
          inactiveFillColor: designColors.light_01.auto(ref),
          selectedFillColor: designColors.light_01.auto(ref),
          activeColor: designColors.light_02.auto(ref),
          inactiveColor: designColors.light_02.auto(ref),
          selectedColor: designColors.feiyu_blue.auto(ref),
          errorBorderColor: designColors.orange.auto(ref)),
      animationDuration: Duration(milliseconds: 300),
      enableActiveFill: true,
      cursorColor: designColors.feiyu_blue.auto(ref),
      cursorHeight: 20,
      textStyle: TextStyle(fontSize: 20.0, color: designColors.dark_01.auto(ref)),
      // errorAnimationController: errorController,
      controller: widget.textEditingController,
      inputFormatters: formatters,
      onCompleted: (text) {
        widget.onComplete(text);
      },
      onChanged: (text) {},
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      },
    );
  }
}

class VerificationCodeInput extends ConsumerStatefulWidget {
  final double frameHeight;
  final TextStyle? textStyle;
  final TextInputType? keyboardType;
  final InputDecoration? inputDecoration;
  final double frameSpacing;
  final int numberCount;
  final VerificationCodeInputController controller;
  final Function(String code) onComplete;

  const VerificationCodeInput({
    this.textStyle,
    this.keyboardType = TextInputType.number,
    this.inputDecoration = const InputDecoration(hoverColor: Colors.blue),
    this.frameHeight = 64,
    this.frameSpacing = 8,
    this.numberCount = 6,
    required this.onComplete,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends ConsumerState<VerificationCodeInput> {
  late List<TextEditingController> textEditingControllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    List<int> list = List.generate(widget.numberCount, (index) => index);
    textEditingControllers = list.map((e) => TextEditingController()).toList();
    focusNodes = list.map((e) {
      FocusNode node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          textEditingControllers[e].selection = TextSelection(baseOffset: 0, extentOffset: textEditingControllers[e].text.length);
        }
      });
      return node;
    }).toList();
    widget.controller.textEditingControllers = textEditingControllers;
    widget.controller.focusNodes = focusNodes;
  }

  @override
  Widget build(BuildContext context) {
    List<int> list = List.generate(widget.numberCount, (index) => index);
    List<FilteringTextInputFormatter>? formatters;
    if (widget.keyboardType == TextInputType.number) {
      formatters = [FilteringTextInputFormatter.allow(RegExp("[0-9]"))];
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: list
          .map((index) => [
                Expanded(
                    child: RawKeyboardListener(
                  // focusNode: focusNodes[index],
                  focusNode: FocusNode(canRequestFocus: false),
                  onKey: (event) {
                    if (event is RawKeyDownEvent) {
                      return;
                    }
                    debugPrint("event=${event.logicalKey.debugName}");
                    if (event.logicalKey != LogicalKeyboardKey.backspace) {
                      setState(() {
                        textEditingControllers[index].text = event.data.keyLabel;
                        if (index != widget.numberCount - 1) {
                          FocusManager.instance.primaryFocus?.nextFocus();
                        } else {
                          widget.onComplete(textEditingControllers.map((e) => e.text).join());
                        }
                      });
                    } else {
                      if (textEditingControllers[index].text.isEmpty) {
                        if (index != 0) {
                          FocusManager.instance.primaryFocus?.previousFocus();
                        }
                      }
                    }
                  },
                  child: TextField(
                      decoration: widget.inputDecoration,
                      controller: textEditingControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      maxLines: 1,
                      keyboardType: widget.keyboardType,
                      inputFormatters: formatters,
                      onChanged: (text) {},
                      buildCounter: (context, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
                      style: widget.textStyle),
                )),
                SizedBox(
                  width: widget.frameSpacing,
                )
              ])
          .expand((element) => element)
          .toList()
        ..removeLast(),
    );
  }
}

class VerificationCodeInputController {
  late List<TextEditingController> _textEditingControllers;
  late List<FocusNode> _focusNodes;

  set textEditingControllers(List<TextEditingController> value) {
    _textEditingControllers = value;
  }

  set focusNodes(List<FocusNode> value) {
    _focusNodes = value;
  }

  void clearAll() {
    for (int i = 0; i < _textEditingControllers.length; i++) {
      _textEditingControllers[i].text = "";
    }
    _focusNodes[0].requestFocus();
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/meme_text_on_canvas.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';

class FontSettingBottomSheet extends StatefulWidget {
  final MemeText memeText;

  const FontSettingBottomSheet({
    Key? key,
    required this.memeText,
  }) : super(key: key);

  @override
  State<FontSettingBottomSheet> createState() => _FontSettingBottomSheetState();
}

class _FontSettingBottomSheetState extends State<FontSettingBottomSheet> {
  late double fontSize;
  late Color color;
  late FontWeight fontWeight;

  @override
  void initState() {
    super.initState();
    fontSize = widget.memeText.fontSize;
    color = widget.memeText.color;
    fontWeight = widget.memeText.fontWeight;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 8,
          ),
          Center(
            child: Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          MemeTextOnCanvas(
            parentConstraints: BoxConstraints.expand(),
            padding: 8,
            selected: true,
            text: widget.memeText.text,
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
          SizedBox(
            height: 48,
          ),
          FontSizeSlider(
              initialFontSize: fontSize,
              changeFontSize: (value) {
                setState(
                  () {
                    this.fontSize = value;
                  },
                );
              }),
          SizedBox(
            height: 16,
          ),
          ColorSelection(
            changeColor: (color) {
              setState(() {
                this.color = color;
              });
            },
          ),
          SizedBox(
            height: 16,
          ),
          FontWeightSlider(
              initialFontWeight: fontWeight,
              changeFontWeight: (value) {
                setState(
                  () {
                    this.fontWeight = value;
                  },
                );
              }),
          SizedBox(
            width: 36,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Buttons(
              textId: widget.memeText.id,
              onPositiveButtonAction: () {
                bloc.changeFontSettings(
                  widget.memeText.id,
                  color,
                  fontSize,
                  fontWeight,
                );
              },
            ),
          ),
          SizedBox(
            width: 24,
          ),
        ],
      ),
    );
  }
}

class ColorSelection extends StatelessWidget {
  final ValueChanged<Color> changeColor;

  const ColorSelection({
    Key? key,
    required this.changeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Color:',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(
          width: 16,
        ),
        ColorSelectionBox(
          changeColor: changeColor,
          color: Colors.white,
        ),
        SizedBox(
          width: 16,
        ),
        ColorSelectionBox(
          changeColor: changeColor,
          color: Colors.black,
        ),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  final String textId;
  final VoidCallback onPositiveButtonAction;

  const Buttons({
    Key? key,
    required this.textId,
    required this.onPositiveButtonAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onTap: () => Navigator.of(context).pop(),
          text: 'Отмена',
          color: AppColors.darkGrey,
        ),
        SizedBox(
          width: 24,
        ),
        AppButton(
          onTap: () {
            onPositiveButtonAction();
            Navigator.of(context).pop();
          },
          text: 'Сохранить',
        ),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  const ColorSelectionBox({
    Key? key,
    required this.changeColor,
    required this.color,
  }) : super(key: key);

  final ValueChanged<Color> changeColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changeColor(color),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: Colors.black,
              width: 1,
            )),
      ),
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  const FontSizeSlider({
    Key? key,
    required this.changeFontSize,
    required this.initialFontSize,
  }) : super(key: key);

  final ValueChanged<double> changeFontSize;
  final double initialFontSize;

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontSize;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Size:',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: 16,
              max: 32,
              divisions: 10,
              value: fontSize,
              label: fontSize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  fontSize = value;
                  widget.changeFontSize(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FontWeightSlider extends StatefulWidget {
  const FontWeightSlider({
    Key? key,
    required this.changeFontWeight,
    required this.initialFontWeight,
  }) : super(key: key);

  final ValueChanged<FontWeight> changeFontWeight;
  final FontWeight initialFontWeight;

  @override
  State<FontWeightSlider> createState() => _FontWeightSliderState();
}

class _FontWeightSliderState extends State<FontWeightSlider> {
  late FontWeight fontWeight;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fontWeight = widget.initialFontWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Font Weight:',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              min: FontWeight.w100.index.toDouble(),
              max: FontWeight.w900.index.toDouble(),
              divisions: FontWeight.w900.index - FontWeight.w100.index,
              value: fontWeight.index.toDouble(),
              onChanged: (double value) {
                setState(() {
                  fontWeight = FontWeight.values.firstWhere(
                      (fontWeight) => fontWeight.index == value.toInt());
                  widget.changeFontWeight(fontWeight);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

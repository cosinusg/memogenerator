import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class CreateMemePage extends StatefulWidget {
  CreateMemePage({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: Text(
            'Создаем мем',
            style:
                GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          bottom: EditTextBar(),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CreateMemePageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data! : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            return TextField(
              enabled: selectedMemeText != null,
              controller: controller,
              onChanged: (text) {
                if (selectedMemeText != null) {
                  bloc.changeMemeText(selectedMemeText.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              decoration: InputDecoration(
                filled: true,
                fillColor: (selectedMemeText != null)
                    ? AppColors.fuchsia16
                    : AppColors.darkGrey6,
                hintText: (selectedMemeText != null && controller.text == '')
                    ? 'Ввести текст'
                    : '',
                hintStyle: TextStyle(
                  color: AppColors.darkGrey38,
                  fontSize: 16,
                ),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: AppColors.darkGrey38,
                )),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: AppColors.fuchsia38,
                )),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.fuchsia38, width: 2)),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  @override
  State<CreateMemePageContent> createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return StreamBuilder<List<MemeText>>(
        stream: bloc.observeMemeTexts(),
        initialData: <MemeText>[],
        builder: (context, snapshot) {
          final memeTexts =
              snapshot.hasData ? snapshot.data! : const <MemeText>[];
          int ind = 0;
          return Column(
            children: [
              Expanded(flex: 2, child: MemeCanvasWidget()),
              Container(
                height: 1,
                width: double.infinity,
                color: AppColors.darkGrey,
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        AddNewMemeTextButton(),
                        ...memeTexts.map((memeText) {
                          return Column(
                            children: [
                              if (ind++ != 0)
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 16,
                                  ),
                                  height: 1,
                                  color: AppColors.darkGrey,
                                ),
                              StreamBuilder<MemeText?>(
                                  stream: bloc.observeSelectedMemeText(),
                                  builder: (context, snapshot) {
                                    return Container(
                                      height: 48,
                                      color: (memeText == snapshot.data)
                                          ? AppColors.darkGrey16
                                          : null,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        memeText.text,
                                        style: GoogleFonts.roboto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.darkGrey),
                                      ),
                                    );
                                  }),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  )),
            ],
          );
        });
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onTap: () {
              bloc.deselectMemeText();
            },
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<MemeText>>(
                  initialData: <MemeText>[],
                  stream: bloc.observeMemeTexts(),
                  builder: (context, snapshot) {
                    final memeTexts =
                        snapshot.hasData ? snapshot.data! : const <MemeText>[];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: memeTexts.map((memeText) {
                            return DraggableMemeText(
                              memeText: memeText,
                              parentConstraints: constraints,
                            );
                          }).toList(),
                        );
                      },
                    );
                  }),
            ),
          )),
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeText memeText;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.memeText,
    required this.parentConstraints,
  }) : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState(parentConstraints);
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  final BoxConstraints _parentConstraints;
  _DraggableMemeTextState(this._parentConstraints);

  late double top = _parentConstraints.maxHeight / 2;
  late double left = _parentConstraints.maxWidth / 3;
  bool needDecoration = false;
  final double padding = 8;
  final BoxDecoration selectedTextDecoration = BoxDecoration(
      color: AppColors.darkGrey16,
      border: Border.all(color: AppColors.fuchsia));

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return StreamBuilder<MemeText?>(
        stream: bloc.observeSelectedMemeText(),
        builder: (context, snapshot) {
          if (snapshot.hasData || snapshot.data != null) {
            needDecoration =
                (snapshot.data!.id == widget.memeText.id) ? true : false;
          } else {
            needDecoration = false;
          }
          return Positioned(
            top: top,
            left: left,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                bloc.selectMemeText(widget.memeText.id);
                //setState(() {
                //  txColor = (bloc.selectedMemeTextSubject.value!.id == widget.memeText.id) ? AppColors.fuchsia : null;
                //});
              },
              onPanUpdate: (details) {
                setState(() {
                  bloc.selectMemeText(widget.memeText.id);
                  left = calculateLeft(details);
                  top = calculateTop(details);
                });
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: widget.parentConstraints.maxWidth,
                  maxHeight: widget.parentConstraints.maxHeight,
                ),
                padding: EdgeInsets.all(padding),
                decoration: (needDecoration) ? selectedTextDecoration : null,
                child: Text(
                  widget.memeText.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          );
        });
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - 30) {
      return widget.parentConstraints.maxHeight - padding * 2 - 30;
    }
    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }
    return rawLeft;
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.addNewText(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: AppColors.fuchsia,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Добавить текст'.toUpperCase(),
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.fuchsia),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

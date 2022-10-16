import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await showConfirmationExitDialog(context);
          return goBack ?? false;
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: Text(
              'Мемогенератор',
              style: GoogleFonts.seymourOne(fontSize: 24),
            ),
          ),
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final selectedMemePath = await bloc.selectMeme();
              if (selectedMemePath == null) {
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CreateMemePage(
                        selectedMemePath: selectedMemePath,
                      )));
            },
            backgroundColor: AppColors.fuchsia,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            label: Text('Создать'),
          ),
          body: SafeArea(
            child: MainPageContent(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<bool?> showConfirmationExitDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: Text("Точно хотите выйти?"),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16),
          content: Text("Мемы сами себя не сделают"),
          actions: [
            AppButton(
              onTap: () => Navigator.of(context).pop(false),
              text: "Остаться",
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () => Navigator.of(context).pop(true),
              text: "Выйти",
            ),
          ],
        );
      },
    );
  }
}

class MainPageContent extends StatefulWidget {
  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MemesWithDocsPath>(
      stream: bloc.observeMemesWithDocPath(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        final items = snapshot.requireData.memes;
        final docsPath = snapshot.requireData.docsPath;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          children: items.map((item) {
            return GridItem(meme: item, docsPath: docsPath);
          }).toList(),
        );
      },
    );
  }
}

class GridItem extends StatelessWidget {
  const GridItem({
    Key? key,
    required this.meme,
    required this.docsPath,
  }) : super(key: key);

  final String docsPath;
  final Meme meme;

  @override
  Widget build(BuildContext context) {
    final imageFile = File('$docsPath${Platform.pathSeparator}${meme.id}.png');
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(id: meme.id);
            },
          ),
        );
      },
      child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.darkGrey,
              width: 1,
            ),
          ),
          child: imageFile.existsSync() ? Image.file(
              File('$docsPath${Platform.pathSeparator}${meme.id}.png')) : Text(meme.id)),
    );
  }

}

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/position.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/domain/interactors/save_meme_interactor.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class CreateMemeBloc {
  final memeTextsSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextSubject = BehaviorSubject<MemeText?>.seeded(null);
  final memeTextOffsetsSubject =
      BehaviorSubject<List<MemeTextOffset>>.seeded(<MemeTextOffset>[]);
  final newMemeTextOffsetSubject =
      BehaviorSubject<MemeTextOffset?>.seeded(null);
  final memePathSubject = BehaviorSubject<String?>.seeded(null);

  StreamSubscription<MemeTextOffset?>? newMemeTextOffsetSubscription;
  StreamSubscription<bool>? saveMemeSubscription;
  StreamSubscription<Meme?>? existendMemeSubscription;

  final String id;

  CreateMemeBloc({final String? id, final String? selectedMemePath})
      : this.id = id ?? Uuid().v4() {
    print('Got id: $id');
    memePathSubject.add(selectedMemePath);
    _subscribeToNewMemTextOffset();
    _subscribeToExistentMeme();
  }

  void _subscribeToExistentMeme() {
    existendMemeSubscription =
        MemesRepository.getInstance().getMeme(this.id).asStream().listen(
      (meme) {
        if (meme == null) {
          return;
        }
        print("Got meme in constructor: $meme");
        final memeTexts = meme.texts.map((textWithPosition) {
          return MemeText(id: textWithPosition.id, text: textWithPosition.text);
        }).toList();
        final memeTextOffsets = meme.texts.map((textWithPosition) {
          return MemeTextOffset(
            id: textWithPosition.id,
            offset: Offset(
              textWithPosition.position.left,
              textWithPosition.position.top,
            ),
          );
        }).toList();
        memeTextsSubject.add(memeTexts);
        memeTextOffsetsSubject.add(memeTextOffsets);
        memePathSubject.add(meme.memePath);
      },
      onError: (error, stackTrace) =>
          print("Error in existendMemeSubscription: $error, $stackTrace"),
    );
  }

  void saveMeme() {
    final memeTexts = memeTextsSubject.value;
    final memeTextOffsets = memeTextOffsetsSubject.value;
    final textsWithPositions = memeTexts.map((memeText) {
      final memeTextPosition =
          memeTextOffsets.firstWhereOrNull((memeTextOffset) {
        return memeTextOffset.id == memeText.id;
      });
      final position = Position(
        top: memeTextPosition?.offset.dy ?? 0,
        left: memeTextPosition?.offset.dx ?? 0,
      );
      return TextWithPosition(
          id: memeText.id, text: memeText.text, position: position);
    }).toList();

    saveMemeSubscription =
        SaveMemeInteractor.getInstance().saveMeme(id:id, textWithPositions:textsWithPositions, imagePath: memePathSubject.value).asStream().listen(
      (saved) {
        print("Meme saved: $saved");
      },
      onError: (error, stackTrace) =>
          print("Error in saveMemeSubscription: $error, $stackTrace"),
    );
  }

  //Future<bool> _saveMemeInternal(
  //    final List<TextWithPosition> textsWithPositions) async {
  //  final imagePath = memePathSubject.value;
  //  if (imagePath == null) {
  //    final meme = Meme(
  //      id: id,
  //      texts: textsWithPositions,
  //    );
  //    return MemesRepository.getInstance().addToMemes(meme);
  //  }
  //  final docsPath = await getApplicationDocumentsDirectory();
  //  final memePath = "${docsPath.absolute.path}${Platform.pathSeparator}memes";
  //  await Directory(memePath).create(recursive: true);
  //  final imageName = imagePath.split(Platform.pathSeparator).last;
  //  final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
  //  final tempFile = File(imagePath);
  //  await tempFile.copy(newImagePath);
  //
  //  final meme = Meme(
  //    id: id,
  //    texts: textsWithPositions,
  //    memePath: newImagePath,
  //  );
  //  return MemesRepository.getInstance().addToMemes(meme);
  //}

  void _subscribeToNewMemTextOffset() {
    newMemeTextOffsetSubscription = newMemeTextOffsetSubject
        .debounceTime(Duration(milliseconds: 300))
        .listen(
      (newMemeTextOffset) {
        if (newMemeTextOffset != null) {
          _changeMemeTextOffsetInternal(newMemeTextOffset);
        }
      },
      onError: (error, stackTrace) =>
          print("Error in newMemeTextOffsetSubscription: $error, $stackTrace"),
    );
  }

  void changeMemeTextOffset(final String id, final Offset offset) {
    newMemeTextOffsetSubject.add(MemeTextOffset(id: id, offset: offset));
  }

  void _changeMemeTextOffsetInternal(final MemeTextOffset newMemeTextOffset) {
    final copiedMemeTextOffsets = [...memeTextOffsetsSubject.value];
    final currrentMemeTextOffset = memeTextOffsetsSubject.value
        .firstWhereOrNull(
            (memeTextOffset) => memeTextOffset.id == newMemeTextOffset.id);
    if (currrentMemeTextOffset != null) {
      copiedMemeTextOffsets.remove(currrentMemeTextOffset);
    }
    copiedMemeTextOffsets.add(newMemeTextOffset);
    memeTextOffsetsSubject.add(copiedMemeTextOffsets);
  }

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextsSubject.add([...memeTextsSubject.value, newMemeText]);
    selectedMemeTextSubject.add(newMemeText);
  }

  void selectMemeText(final String id) {
    final foundMemeText = memeTextsSubject.value
        .firstWhereOrNull((memeText) => memeText.id == id);
    selectedMemeTextSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextSubject.add(null);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextsSubject.value];
    final index = copiedList.indexWhere((memeText) => memeText.id == id);
    if (index == -1) {
      return;
    }
    copiedList.removeAt(index);
    copiedList.insert(index, MemeText(id: id, text: text));
    memeTextsSubject.add(copiedList);
  }

  Stream<String?> observeMemePath() => memePathSubject.distinct();

  Stream<List<MemeText>> observeMemeTexts() => memeTextsSubject
      .distinct(((prev, next) => ListEquality().equals(prev, next)));

  Stream<List<MemeTextWithOffset>> observeMemeTextWithOffset() {
    return Rx.combineLatest2<List<MemeText>, List<MemeTextOffset>,
            List<MemeTextWithOffset>>(
        observeMemeTexts(), memeTextOffsetsSubject.distinct(),
        (memeTexts, memeTextOffsets) {
      return memeTexts.map((memeText) {
        final memeTextOffset = memeTextOffsets.firstWhereOrNull((element) {
          return element.id == memeText.id;
        });
        return MemeTextWithOffset(
            id: memeText.id,
            text: memeText.text,
            offset: memeTextOffset?.offset);
      }).toList();
    });
  }

  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeMemeTextWithSelection() {
    return Rx.combineLatest2<List<MemeText>, MemeText?,
        List<MemeTextWithSelection>>(
      observeMemeTexts(),
      observeSelectedMemeText(),
      (memeTexts, selectedMemeText) {
        return memeTexts.map((memeText) {
          return MemeTextWithSelection(
              memeText: memeText,
              selected: memeText.id == selectedMemeText?.id);
        }).toList();
      },
    );
  }

  void dispose() {
    memeTextsSubject.close();
    selectedMemeTextSubject.close();
    memeTextOffsetsSubject.close();
    newMemeTextOffsetSubject.close();
    memePathSubject.close();

    newMemeTextOffsetSubscription?.cancel();
    saveMemeSubscription?.cancel();
    existendMemeSubscription?.cancel();
  }
}

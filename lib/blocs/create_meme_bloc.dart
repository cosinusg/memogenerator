// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class CreateMemeBloc {
  final memeTextSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextSubject = BehaviorSubject<MemeText?>.seeded(null);

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextSubject.add([...memeTextSubject.value, newMemeText]);
    selectedMemeTextSubject.add(newMemeText);
  }

  void selectMemeText(final String id) {
    final foundMemeText =
        memeTextSubject.value.firstWhereOrNull((memeText) => memeText.id == id);
    selectedMemeTextSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextSubject.add(null);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextSubject.value];
    final index = copiedList.indexWhere((memeText) => memeText.id == id);
    if (index == -1) {
      return;
    }
    copiedList.removeAt(index);
    copiedList.insert(index, MemeText(id: id, text: text));
    memeTextSubject.add(copiedList);
  }

  Stream<List<MemeText>> observeMemeTexts() => memeTextSubject
      .distinct(((prev, next) => ListEquality().equals(prev, next)));
  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextSubject.distinct();
  Stream<List<MemeTextWithSelection>> observeMemeTextWithSelection() {
    return Rx.combineLatest2<List<MemeText>, MemeText?, List<MemeTextWithSelection>>(
      observeMemeTexts(),
      observeSelectedMemeText(),
      (memeTexts, selectedMemeText) {
        return memeTexts.map((memeText) {
          return MemeTextWithSelection(memeText: memeText, selected: memeText.id == selectedMemeText?.id);
        }).toList();
      },
    );
  }

  void dispose() {
    memeTextSubject.close();
    selectedMemeTextSubject.close();
  }
}

class MemeTextWithSelection {
  final MemeText memeText;
  final bool selected;
  MemeTextWithSelection({
    required this.memeText,
    required this.selected,
  });

  @override
  bool operator ==(covariant MemeTextWithSelection other) {
    if (identical(this, other)) return true;

    return other.memeText == memeText && other.selected == selected;
  }

  @override
  int get hashCode => memeText.hashCode ^ selected.hashCode;

  @override
  String toString() =>
      'MemeTextWithSelection(memeText: $memeText, selected: $selected)';
}

class MemeText {
  final String id;
  final String text;
  MemeText({
    required this.id,
    required this.text,
  });
  factory MemeText.create() {
    return MemeText(id: Uuid().v4(), text: '');
  }

  @override
  bool operator ==(covariant MemeText other) {
    if (identical(this, other)) return true;

    return other.id == id && other.text == text;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode;

  @override
  String toString() => 'MemeText(id: $id, text: $text)';
}

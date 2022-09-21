import 'dart:io';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class SaveMemeInteractor {
  static SaveMemeInteractor? _instance;
  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();
  SaveMemeInteractor._internal();

  Future<bool> saveMeme(
      {required final String id,
      required final List<TextWithPosition> textWithPositions,
      final String? imagePath}) async {
    if (imagePath == null) {
      final meme = Meme(
        id: id,
        texts: textWithPositions,
      );
      return MemesRepository.getInstance().addToMemes(meme);
    }
    final newImagePath = await createNewFile(imagePath);

    final meme = Meme(
      id: id,
      texts: textWithPositions,
      memePath: newImagePath,
    );
    return MemesRepository.getInstance().addToMemes(meme);
  }

  Future<String> createNewFile(final String imagePath) async {
    final docsPath = await getApplicationDocumentsDirectory();
    final memePath = "${docsPath.absolute.path}${Platform.pathSeparator}memes";
    final memesDirectory = Directory(memePath);
    await memesDirectory.create(recursive: true);
    final currentFiles = memesDirectory.listSync();

    final imageName = _getFileNameByPath(imagePath);
    final oldFileWithSameName = currentFiles.firstWhereOrNull((element) {
      return _getFileNameByPath(element.path) == imageName && element is File;
    });
    final newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    final tempFile = File(imagePath);
    if (oldFileWithSameName == null) {
      final tempFile = File(imagePath);
      await tempFile.copy(newImagePath);
      return newImagePath;
    }
    final oldFileLength = await (oldFileWithSameName as File).length();
    final newFileLength = await tempFile.length();
    if (oldFileLength == newFileLength) {
      return newImagePath;
    }
    return _createFileForSameNameButDifferentLength(imageName: imageName, tempFile: tempFile, newImagePath: newImagePath, memePath: memePath);
  }

  Future<String> _createFileForSameNameButDifferentLength({
    required String imageName, 
    required File tempFile, 
    required String newImagePath, 
    required String memePath}) async {
    final indexOfLastDot = imageName.lastIndexOf(".");
    if (indexOfLastDot == -1) {
      await tempFile.copy(newImagePath);
      return newImagePath;
    }
    final extention = imageName.substring(indexOfLastDot);
    final imageNameWithoutExtension = imageName.substring(0, indexOfLastDot);
    final indexOfLastUnderscore = imageNameWithoutExtension.lastIndexOf("_");
    if (indexOfLastUnderscore == -1) {
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutExtension}_1$extention";
      await tempFile.copy(correctedNewImagePath);
      return correctedNewImagePath;
    }
    final suffixNumberString =
        imageNameWithoutExtension.substring(indexOfLastUnderscore + 1);
    final suffixNumber = int.tryParse(suffixNumberString);
    if (suffixNumber == null) {
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutExtension}_1$extention";
      await tempFile.copy(correctedNewImagePath);
      return correctedNewImagePath;
    } else {
      final imageNameWithoutSuffix =
          imageNameWithoutExtension.substring(0, indexOfLastUnderscore);
      final correctedNewImagePath =
          "$memePath${Platform.pathSeparator}${imageNameWithoutSuffix}_${suffixNumber + 1}$extention";
      await tempFile.copy(correctedNewImagePath);
      return correctedNewImagePath;
    }
  }

  String _getFileNameByPath(String imagePath) =>
      imagePath.split(Platform.pathSeparator).last;
}

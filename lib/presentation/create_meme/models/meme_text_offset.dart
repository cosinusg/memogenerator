
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';

class MemeTextOffset extends Equatable {
  final String id;
  final Offset offset;
  MemeTextOffset({
    required this.id,
    required this.offset,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [id, offset];
}
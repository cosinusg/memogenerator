// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';

class MemeTextWithOffset extends Equatable {
  final MemeText memeText;
  final Offset? offset;
  MemeTextWithOffset({
    required this.memeText,
    required this.offset,
  });

  
  @override
  // TODO: implement props
  List<Object?> get props => [memeText, offset];
}

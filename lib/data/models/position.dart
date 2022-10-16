// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Position extends Equatable {
  final double top;
  final double left;
  Position({
    required this.left,
    required this.top,
  });
  
  factory Position.fromJson(final Map<String, dynamic> json) => _$PositionFromJson(json);
  Map<String, dynamic> toJson() => _$PositionToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => [left, top];

}

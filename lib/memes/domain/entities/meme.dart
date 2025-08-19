import 'package:equatable/equatable.dart';

class Meme extends Equatable {
  final String id;
  final String name;
  final String url;
  final int width;
  final int height;
  final int boxCount;
  final int captions;

  const Meme({
    required this.id,
    required this.name,
    required this.url,
    required this.width,
    required this.height,
    required this.boxCount,
    required this.captions,
  });

  @override
  List<Object?> get props => [id, name, url, width, height, boxCount, captions];
}

class MemeResult extends Equatable {
  final String url;
  final bool success;

  const MemeResult({required this.url, required this.success});

  @override
  List<Object?> get props => [url, success];
}

import 'package:memes/memes/domain/entities/meme.dart';

class MemeModel extends Meme {
  const MemeModel({
    required super.id,
    required super.name,
    required super.url,
    required super.width,
    required super.height,
    required super.boxCount,
    required super.captions,
  });

  factory MemeModel.fromJson(Map<String, dynamic> json) {
    return MemeModel(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      width: json['width'],
      height: json['height'],
      boxCount: json['box_count'],
      captions: json['captions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'width': width,
      'height': height,
      'box_count': boxCount,
      'captions': captions,
    };
  }

  factory MemeModel.fromEntity(Meme entity) {
    return MemeModel(
      id: entity.id,
      name: entity.name,
      url: entity.url,
      width: entity.width,
      height: entity.height,
      boxCount: entity.boxCount,
      captions: entity.captions,
    );
  }
}

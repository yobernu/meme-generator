import 'dart:convert';

import 'package:memes/memes/data/models/meme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MemeLocalDataSource {
  Future<void> cacheMeme(MemeModel meme);
  Future<MemeModel?> getChachedMeme();
  Future<void> cacheMemes(List<MemeModel> memes);
  Future<List<MemeModel>> getCachedMemes();

  Future<void> saveFavoriteIds(List<String> ids);
  Future<List<String>> getFavoriteIds();
}

class MemeLocalDataSourcesImpl implements MemeLocalDataSource {
  final SharedPreferences sharedPreferences;

  MemeLocalDataSourcesImpl({
    required this.sharedPreferences,
  });
  MemeModel? _cached;
  @override
  Future<void> cacheMeme(MemeModel meme) async {
    _cached = meme;
    sharedPreferences.setString('cachedMeme', jsonEncode(meme.toJson()));
  }

  @override
  Future<MemeModel?> getChachedMeme() async {
    final cachedMeme = sharedPreferences.getString('cachedMeme');
    if (cachedMeme != null) {
      return MemeModel.fromJson(jsonDecode(cachedMeme));
    }
    return null;
  }

  @override
  Future<void> cacheMemes(List<MemeModel> memes) async {
    final listJson = memes.map((e) => e.toJson()).toList();
    await sharedPreferences.setString('cachedMemes', jsonEncode(listJson));
  }

  @override
  Future<List<MemeModel>> getCachedMemes() async {
    final cached = sharedPreferences.getString('cachedMemes');
    if (cached == null) return [];
    final List<dynamic> list = jsonDecode(cached);
    return list.map((e) => MemeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveFavoriteIds(List<String> ids) async {
    await sharedPreferences.setStringList('favorite_ids', ids);
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    return sharedPreferences.getStringList('favorite_ids') ?? [];
  }

}

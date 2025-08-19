import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:memes/core/constants/api_constants.dart';
import 'package:memes/core/failures/failures.dart';
import 'package:memes/core/network_info/network_info.dart';
import 'package:memes/memes/data/models/meme_model.dart';
import 'package:memes/memes/domain/entities/meme.dart';
import 'package:memes/memes/domain/entities/meme_caption.dart';

abstract class MemeRemoteDataSources {
  Future<Either<Failure, List<Meme>>> getMemes();
  Future<Either<Failure, MemeResult>> createMeme(CreateMemeRequest request);
}

/*
 how it works
  - Future<Either
  - check-connection
  - assign url = Uri.parse(url)
  - assign response http.get()
      - return Right(response.body)
      - return Left(ServerFailure())

  Future<Either<Failure, Meme>> nameFunc() {
    if (http.isconnected) {
      final url = Uri.parse(baseurl + endpoint)
      final result = await http.get(url)
      if (result.statusCode == 200) {
        final meme = MemeModel.fromJson(jsonDecode(result.body))
        return Right(meme)
      }
      return Left(ServerFailure())
    }
    return Left(ServerFailure())
  } 




 */

class MemeRemoteDataSourcesImpl implements MemeRemoteDataSources {
  final http.Client client;
  final NetworkInfo networkInfo;

  MemeRemoteDataSourcesImpl({required this.client, required this.networkInfo});

  @override
  Future<Either<Failure, List<Meme>>> getMemes() async {
    if (await networkInfo.isConnected) {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getMemesEndpoint}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final memes = (result['data']['memes'] as List)
            .map((e) => MemeModel.fromJson(e))
            .toList();
        return Right(memes);
      }
      return Left(ServerFailure());
    }
    return Left(ServerFailure());
  }

  @override
  Future<Either<Failure, MemeResult>> createMeme(
    CreateMemeRequest request,
  ) async {
    if (await networkInfo.isConnected) {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.captionImageEndpoint}',
      );

      final Map<String, String> body = {
        'template_id': request.templateId,
        'username': request.username,
        'password': request.password,
      };

      for (int i = 0; i < request.boxes.length; i++) {
        final box = request.boxes[i];
        body['boxes[$i][text]'] = box.text;
        body['boxes[$i][x]'] = box.x.toString();
        body['boxes[$i][y]'] = box.y.toString();
        body['boxes[$i][width]'] = box.width.toString();
        body['boxes[$i][height]'] = box.height.toString();
        body['boxes[$i][color]'] = box.color;
        body['boxes[$i][outline_color]'] = box.outlineColor;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return Right(MemeResult(url: result['data']['url'], success: true));
        } else {
          return Left(
            ServerFailure(result['error_message'] ?? 'Unknown error'),
          );
        }
      }
      return Left(ServerFailure("No Internet Connection"));
    }
    return Left(ServerFailure("No Internet Connection"));
  }
}

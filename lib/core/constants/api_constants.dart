class ApiConstants {
  static const String baseUrl = 'https://api.imgflip.com';

  //headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  //query parameters
  static Map<String, String> get queryParameters => {
    'access_key': 'YOUR_ACCESS_KEY',
    'username': 'YOUR_USERNAME',
    'password': 'YOUR_PASSWORD',
  };

  //endpoints
  static const String getMemesEndpoint = '/get_memes';
  static const String captionImageEndpoint = '/caption_image';
  static const String captionGifEndpoint = '/caption_gif';
  static const String searchMemesEndpoint = '/search_memes';
  static const String getMemeEndpoint = '/get_meme';
  static const String autoMemeEndpoint = '/auto_meme';
  static const String aiMemeEndpoint = '/ai_meme';
}

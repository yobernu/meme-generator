class MemeCaption {
  final String text;
  final int x;
  final int y;
  final int width;
  final int height;
  final String color;
  final String outlineColor;

  MemeCaption({
    required this.text,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    required this.outlineColor,
  });
}

class CreateMemeRequest {
  final String templateId;
  final String username;
  final String password;
  final List<MemeCaption> boxes;

  CreateMemeRequest({
    required this.templateId,
    required this.username,
    required this.password,
    required this.boxes,
  });
}

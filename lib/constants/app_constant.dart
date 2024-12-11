class AppConstant {
  AppConstant._();

  static const baseTodo = 'http://206.189.150.98:3000/api/v1';
  static baseImage(String path) =>
      'http://206.189.150.98:3000/public/images/$path';

  static const endPointBaseImage = 'http://206.189.150.98:3000/public/images';
  static const endPointUploadFile = '$baseTodo/file/upload';
}

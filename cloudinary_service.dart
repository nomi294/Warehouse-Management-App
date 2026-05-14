import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class CloudinaryService {
  final String cloudName = "YOUR_CLOUD_NAME";
  final String uploadPreset = "YOUR_UPLOAD_PRESET";

  Future<String?> uploadImage(File imageFile) async {
    String uploadUrl =
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    var request = http.MultipartRequest("POST", Uri.parse(uploadUrl));
    request.fields["upload_preset"] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    var response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = jsonDecode(res);

    if (response.statusCode == 200) {
      return jsonData["secure_url"];
    }
    return null;
  }
}

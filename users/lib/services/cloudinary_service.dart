import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "dduqfsnvr";

  // Your unsigned upload preset
  static const String uploadPreset = "safetify_preset";

  static Future<String?> uploadIncidentImage(File file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri);

    request.fields["upload_preset"] = uploadPreset;

    // Upload file
    request.files.add(
      await http.MultipartFile.fromPath("file", file.path),
    );

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200 && data["secure_url"] != null) {
        return data["secure_url"]; // Cloudinary URL returned
      } else {
        print("Upload failed: $data");
      }
    } catch (e) {
      print("Cloudinary upload error: $e");
    }

    return null;
  }
}




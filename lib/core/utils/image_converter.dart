import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageConverter {
  static const int maxFileSizeBytes = 500 * 1024; // 500 Ko (512 000 octets)

  /// Compresses and formats an image file from ImagePicker to ensure it does not exceed 500 KB.
  /// Returns a data URI string: "data:image/jpeg;base64,<data>"
  static Future<String?> processAndConvertToBase64(XFile file) async {
    final Uint8List rawBytes = await file.readAsBytes();

    // 1. Decode image using pure Dart 'image' library
    img.Image? decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw Exception('Format d\'image non supporté ou fichier corrompu.');
    }

    // 2. Fix orientation if needed (exif)
    decoded = img.bakeOrientation(decoded);

    // 3. Resize if dimensions are excessively large for a profile picture
    const int maxDimension = 800;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      if (decoded.width >= decoded.height) {
        decoded = img.copyResize(decoded, width: maxDimension);
      } else {
        decoded = img.copyResize(decoded, height: maxDimension);
      }
    }

    // 4. Encode as JPEG with adaptive compression loop to ensure <= 500 KB
    int quality = 85;
    List<int> compressedBytes = img.encodeJpg(decoded, quality: quality);

    while (compressedBytes.length > maxFileSizeBytes && quality > 20) {
      quality -= 15;
      compressedBytes = img.encodeJpg(decoded, quality: quality);
    }

    // If still too large, downscale further
    if (compressedBytes.length > maxFileSizeBytes) {
      decoded = img.copyResize(decoded, width: 400);
      compressedBytes = img.encodeJpg(decoded, quality: 60);
    }

    if (compressedBytes.length > maxFileSizeBytes) {
      throw Exception('Impossible de réduire l\'image en dessous de 500 Ko.');
    }

    // 5. Convert to Base64 data URI
    final String base64String = base64Encode(compressedBytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  /// Helper to decode bytes from either a raw base64 string or a data URI
  static Uint8List? decodeBase64Photo(String? photoData) {
    if (photoData == null || photoData.trim().isEmpty) return null;
    try {
      final clean = photoData.contains(',') ? photoData.split(',').last.trim() : photoData.trim();
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }
}

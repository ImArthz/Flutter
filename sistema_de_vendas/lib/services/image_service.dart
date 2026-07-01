import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // <-- ADICIONE ESTE IMPORT
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickFromGallery() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  }

  Future<XFile?> pickFromCamera() async {
    return await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
  }

  Future<String?> imageToBase64(XFile imageFile) async {
    try {
      File file = File(imageFile.path);
      Uint8List originalBytes = await file.readAsBytes(); // <-- MUDE PARA Uint8List

      img.Image? imagem = img.decodeImage(originalBytes);
      if (imagem == null) return null;

      img.Image resized = img.copyResize(imagem, width: 200, height: 200);

      // encodeJpg retorna Uint8List, que já é aceito pelo base64Encode
      Uint8List compressedBytes = img.encodeJpg(resized, quality: 70);

      return base64Encode(compressedBytes);
    } catch (e) {
      print('Erro ao processar imagem: $e');
      return null;
    }
  }
}
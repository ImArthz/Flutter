import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/contato.dart';
class ContatosProvider extends ChangeNotifier {
  List<Contato> _contatos = [];
  int _currentIndex = 0;

  List<Contato> get contatos => _contatos;
  int get currentIndex => _currentIndex;
  Contato get currentContato =>
      _contatos.isNotEmpty
          ? _contatos[_currentIndex]
          : Contato(
              id: '',
              nome: '',
              telefone: '',
              endereco: '',
              fotoPerfil: '',
              observacao: '',
            );

  void loadFromJsonList(List<dynamic> jsonList) {
    _contatos = jsonList.map((e) => Contato.fromJson(e)).toList();
    if (_contatos.isNotEmpty) {
      _currentIndex = 0;
    }
    notifyListeners();
  }

  void replaceList(List<Contato> novaLista) {
    _contatos = novaLista;
    if (_currentIndex >= _contatos.length) {
      _currentIndex = _contatos.isEmpty ? 0 : _contatos.length - 1;
    }
    notifyListeners();
  }

  void addContato(Contato novo) {
    _contatos.add(novo);
    _currentIndex = _contatos.length - 1;
    notifyListeners();
  }

  void updateCurrent(Contato updated) {
    if (_contatos.isNotEmpty) {
      _contatos[_currentIndex] = updated;
      notifyListeners();
    }
  }

  
  void updateAtIndex(int index, Contato updated) {
    if (index >= 0 && index < _contatos.length) {
      _contatos[index] = updated;
      notifyListeners();
    }
  }

  void deleteCurrent() {
    if (_contatos.isEmpty) return;
    _contatos.removeAt(_currentIndex);
    if (_contatos.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _contatos.length) {
      _currentIndex = _contatos.length - 1;
    }
    notifyListeners();
  }

  void goToFirst() {
    if (_contatos.isNotEmpty) {
      _currentIndex = 0;
      notifyListeners();
    }
  }

  void goToPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToNext() {
    if (_currentIndex < _contatos.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void goToLast() {
    if (_contatos.isNotEmpty) {
      _currentIndex = _contatos.length - 1;
      notifyListeners();
    }
  }

  void selectByIndex(int index) {
    if (index >= 0 && index < _contatos.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> toJsonList() {
    return _contatos.map((c) => c.toJson()).toList();
  }
  Future<void> reloadFromLocalFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/contatos_salvos.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _contatos = jsonList.map((e) => Contato.fromJson(e)).toList();
      } else {
        // Carrega do asset
        final assetString = await rootBundle.loadString('assets/data/contatos.json');
        final List<dynamic> jsonList = json.decode(assetString);
        _contatos = jsonList.map((e) => Contato.fromJson(e)).toList();
      }
      // Ajusta o índice atual para não ficar fora da lista
      if (_currentIndex >= _contatos.length) {
        _currentIndex = _contatos.isEmpty ? 0 : _contatos.length - 1;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao recarregar: $e');
    }
  }
}


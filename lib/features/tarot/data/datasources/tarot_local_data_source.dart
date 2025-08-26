import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/tarot_card_model.dart';

abstract class TarotLocalDataSource {
  Future<List<TarotCardModel>> loadFromAssets();
}

class TarotLocalDataSourceImpl implements TarotLocalDataSource {
  final String jsonAssetPath;
  TarotLocalDataSourceImpl({this.jsonAssetPath = 'assets/tarot/data/tarot_cards.json'});

  @override
  Future<List<TarotCardModel>> loadFromAssets() async {
    final raw = await rootBundle.loadString(jsonAssetPath);
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => TarotCardModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

import 'dart:convert';

import 'package:kanji_dictionary/models/incorrect_question.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kanji_dictionary/models/kanji_list.dart';
import 'package:kanji_dictionary/models/question.dart';

const favKanjiStrsKey = 'favKanjiStrs';
const starKanjiStrsKey = 'starKanjiStrs';
const kanjiListStrKey = 'kanjiListStr';
const incorrectQuestionsKey = 'incorrectQuestions';

class SharedPreferencesProvider {
  SharedPreferences _sharedPreferences;

  SharedPreferencesProvider() {
    initSharedPrefs();
  }

  Future initSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (!_sharedPreferences.containsKey(favKanjiStrsKey)) {
      _sharedPreferences.setStringList(favKanjiStrsKey, []);
      _sharedPreferences.setStringList(starKanjiStrsKey, ['字']);
      _sharedPreferences.setStringList(incorrectQuestionsKey, []);
    }
  }

  List<String> getAllFavKanjiStrs() => _sharedPreferences.getStringList(favKanjiStrsKey);

  List<IncorrectQuestion> _incorrectQuestions;

  void addFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(favKanjiStrsKey);
    favKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, favKanjiStrs);
  }

  void removeFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(favKanjiStrsKey);
    favKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, favKanjiStrs);
  }

  List<String> getAllStarKanjiStrs() => _sharedPreferences.getStringList(starKanjiStrsKey);

  void addStar(String kanjiStr) {
    var starKanjiStrs = _sharedPreferences.getStringList(starKanjiStrsKey);
    starKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, starKanjiStrs);
  }

  void removeStar(String kanjiStr) {
    var starKanjiStrs = _sharedPreferences.getStringList(starKanjiStrsKey);
    starKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(starKanjiStrsKey, starKanjiStrs);
  }

  List<KanjiList> getAllKanjiLists() => kanjiListsFromJsonStr(_sharedPreferences.getString(kanjiListStrKey));


  void updateKanjiLists(List<KanjiList> kanjiLists) => _sharedPreferences.setString(kanjiListStrKey, kanjiListsToJsonStr(kanjiLists));
}

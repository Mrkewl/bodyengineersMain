import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/achievement/achievement.dart';
import '../model/user/region_country.dart';

class JsonHelper {
  Future<List<Country>> getCountries() async {
    String json = await rootBundle.loadString('assets/json/country_list.json');
    List<Map<String, dynamic>> structuredCountryList = [];
    for (Map<String, dynamic> item in jsonDecode(json)) {
      structuredCountryList.add(item);
    }
    List<Country> listCountry = structuredCountryList
        .map((e) => Country(name: e['name'], id: int.parse(e['id'])))
        .toList();
    return listCountry;
  }

  Future<List<Region>> getRegions() async {
    String json = await rootBundle.loadString('assets/json/region_list.json');
    List<Map<String, dynamic>> structuredRegionList = [];
    for (Map<String, dynamic> item in jsonDecode(json)) {
      structuredRegionList.add(item);
    }
    List<Region> listRegion = structuredRegionList
        .map((e) => Region(
            name: e['name'],
            id: int.parse(e['id']),
            countryId: int.parse(e['country_id'])))
        .toList();
    return listRegion;
  }

  Future<List<Achievement>> getAchievements() async {
    String json =
        await rootBundle.loadString('assets/json/achievement_list.json');
    List<Map<String, dynamic>> structuredAchievementList = [];
    for (Map<String, dynamic> item in jsonDecode(json)) {
      structuredAchievementList.add(item);
    }
    List<Achievement> listRegion = structuredAchievementList
        .map((e) => Achievement.fromLocalJson(e))
        .toList();
    return listRegion;
  }
}

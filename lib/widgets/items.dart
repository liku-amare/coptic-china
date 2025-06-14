import 'package:flutter/material.dart';
import '../widgets/settings.dart';

class Items {
  static String getTitles(String key) {
    Map<String, String> titles = {
      'readings': itemName('cat_readings'),
      'agpeya': itemName('cat_agpeya'),
    };
    return titles[key] ?? key;
  }

  static final List<_MenuItem> readings = [
    _MenuItem(itemName('read_vespers'), Icons.nightlight_round),
    _MenuItem(itemName('read_matins'), Icons.wb_sunny),
    _MenuItem(itemName('read_Liturgy'), Icons.local_fire_department),
    _MenuItem(itemName('read_antiphonary'), Icons.library_music),
  ];

  static final List<String> reading_files = ['assets/excel/Vespers.xlsx'];

  static final List<_MenuItem> agpeya = [
    _MenuItem(itemName('agpeya_first'), Icons.nightlight_round),
    _MenuItem(itemName('agpeya_third'), Icons.wb_sunny),
    _MenuItem(itemName('agpeya_sixth'), Icons.local_fire_department),
    _MenuItem(itemName('agpeya_nineth'), Icons.library_music),
    _MenuItem(itemName('agpeya_eleventh'), Icons.lock_clock),
    _MenuItem(itemName('agpeya_twelfth'), Icons.lock_clock),
    _MenuItem(itemName('agpeya_viel'), Icons.lock_clock),
    _MenuItem(itemName('agpeya_midnight'), Icons.lock_clock),
    _MenuItem(itemName('agpeya_prayers'), Icons.lock_clock),
  ];

  static final List<String> agpeya_files = ['assets/excel/Vespers.xlsx'];

  static final Map<String, List<_MenuItem>> itemMap = {
    'readings': readings,
    'agpeya': agpeya,
  };

  static final Map<String, List<String>> fileMap = {
    'readings': reading_files,
    'agpeya': agpeya_files,
  };

  static String itemName(key) {
    return AppSettings.getNameValue(key);
  }
}

class _MenuItem {
  final String title;
  final IconData icon;

  _MenuItem(this.title, this.icon);
}

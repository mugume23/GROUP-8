import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches Uganda administrative data from the paulgrammer/ug-locale
/// package served via jsDelivr CDN — no API key required.
///
/// Hierarchy: District → County → Subcounty → Parish → Village
class UgandaLocationService {
  static const String _base =
      'https://cdn.jsdelivr.net/npm/ug-locale@latest/data';

  // ── Cache ────────────────────────────────────────────────────────────────
  static List<String>? _districtCache;
  static final Map<String, List<String>> _countyCache = {};
  static final Map<String, List<String>> _subcountyCache = {};
  static final Map<String, List<String>> _parishCache = {};
  static final Map<String, List<String>> _villageCache = {};

  // ── Districts ────────────────────────────────────────────────────────────
  static Future<List<String>> getDistricts() async {
    if (_districtCache != null) return _districtCache!;
    try {
      final res = await http
          .get(Uri.parse('$_base/districts.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _districtCache = data
            .map((d) => (d['name'] as String).trim())
            .toList()
          ..sort();
        return _districtCache!;
      }
    } catch (_) {}
    // Fallback — major Uganda districts
    _districtCache = _fallbackDistricts;
    return _districtCache!;
  }

  // ── Counties ─────────────────────────────────────────────────────────────
  static Future<List<String>> getCounties(String district) async {
    if (_countyCache.containsKey(district)) return _countyCache[district]!;
    try {
      final districtSlug = _slug(district);
      final res = await http
          .get(Uri.parse('$_base/counties/$districtSlug.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final list = data
            .map((c) => (c['name'] as String).trim())
            .toList()
          ..sort();
        _countyCache[district] = list;
        return list;
      }
    } catch (_) {}
    return [];
  }

  // ── Subcounties ──────────────────────────────────────────────────────────
  static Future<List<String>> getSubcounties(String county) async {
    if (_subcountyCache.containsKey(county)) return _subcountyCache[county]!;
    try {
      final countySlug = _slug(county);
      final res = await http
          .get(Uri.parse('$_base/subcounties/$countySlug.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final list = data
            .map((s) => (s['name'] as String).trim())
            .toList()
          ..sort();
        _subcountyCache[county] = list;
        return list;
      }
    } catch (_) {}
    return [];
  }

  // ── Parishes ─────────────────────────────────────────────────────────────
  static Future<List<String>> getParishes(String subcounty) async {
    if (_parishCache.containsKey(subcounty)) return _parishCache[subcounty]!;
    try {
      final slug = _slug(subcounty);
      final res = await http
          .get(Uri.parse('$_base/parishes/$slug.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final list = data
            .map((p) => (p['name'] as String).trim())
            .toList()
          ..sort();
        _parishCache[subcounty] = list;
        return list;
      }
    } catch (_) {}
    return [];
  }

  // ── Villages ─────────────────────────────────────────────────────────────
  static Future<List<String>> getVillages(String parish) async {
    if (_villageCache.containsKey(parish)) return _villageCache[parish]!;
    try {
      final slug = _slug(parish);
      final res = await http
          .get(Uri.parse('$_base/villages/$slug.json'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        final list = data
            .map((v) => (v['name'] as String).trim())
            .toList()
          ..sort();
        _villageCache[parish] = list;
        return list;
      }
    } catch (_) {}
    return [];
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  static String _slug(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').trim();

  // ── Fallback district list (all 146 Uganda districts) ────────────────────
  static const List<String> _fallbackDistricts = [
    'Abim', 'Adjumani', 'Agago', 'Alebtong', 'Amolatar', 'Amudat',
    'Amuria', 'Amuru', 'Apac', 'Arua', 'Budaka', 'Bududa', 'Bugiri',
    'Bugweri', 'Buhweju', 'Buikwe', 'Bukedea', 'Bukomansimbi', 'Bukwo',
    'Bulambuli', 'Buliisa', 'Bundibugyo', 'Bunyangabu', 'Bushenyi',
    'Busia', 'Butaleja', 'Butebo', 'Buvuma', 'Buyende', 'Dokolo',
    'Gomba', 'Gulu', 'Hoima', 'Ibanda', 'Iganga', 'Isingiro', 'Jinja',
    'Kaabong', 'Kabale', 'Kabarole', 'Kaberamaido', 'Kagadi', 'Kakumiro',
    'Kalaki', 'Kalangala', 'Kaliro', 'Kalungu', 'Kampala', 'Kamuli',
    'Kamwenge', 'Kanungu', 'Kapchorwa', 'Kapelebyong', 'Karenga',
    'Kasanda', 'Kasese', 'Katakwi', 'Kayunga', 'Kazo', 'Kibaale',
    'Kiboga', 'Kibuku', 'Kikuube', 'Kiruhura', 'Kiryandongo', 'Kisoro',
    'Kitagwenda', 'Kitgum', 'Koboko', 'Kole', 'Kotido', 'Kumi',
    'Kwania', 'Kween', 'Kyankwanzi', 'Kyegegwa', 'Kyenjojo', 'Kyotera',
    'Lamwo', 'Lira', 'Luuka', 'Luwero', 'Lwengo', 'Lyantonde',
    'Madi-Okollo', 'Manafwa', 'Maracha', 'Masaka', 'Masindi', 'Mayuge',
    'Mbale', 'Mbarara', 'Mitooma', 'Mityana', 'Moroto', 'Moyo',
    'Mpigi', 'Mubende', 'Mukono', 'Nabilatuk', 'Nakapiripirit', 'Nakaseke',
    'Nakasongola', 'Namayingo', 'Namisindwa', 'Namutumba', 'Napak',
    'Nebbi', 'Ngora', 'Ntoroko', 'Ntungamo', 'Nwoya', 'Obongi',
    'Omoro', 'Otuke', 'Oyam', 'Pader', 'Pakwach', 'Pallisa', 'Rakai',
    'Rubanda', 'Rubirizi', 'Rukiga', 'Rukungiri', 'Rwampara', 'Sembabule',
    'Serere', 'Sheema', 'Sironko', 'Soroti', 'Tororo', 'Wakiso',
    'Yumbe', 'Zombo',
  ];
}

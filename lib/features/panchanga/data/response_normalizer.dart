import 'dart:convert';

/// Normalizes all Panchanga API responses into a common shape so the UI
/// can read consistent keys.
///
/// Final merged shape used by the screen:
/// {
///   'sunrise_sunset': {'sun_rise_time':'6:12:22','sun_set_time':'18:29:39'},
///   'tithi':          {'number':..,'name':'..','paksha':'..','completes_at':'..', ...},
///   'nakshatra':      {'number':..,'name':'..','starts_at':'..','ends_at':'..', ...},
///   'yoga':           {'1': {...}, '2': {...}},
///   'karana':         {'1': {...}, '2': {...}, '3': {...}},
///   'goodbad': {
///      'abhijit_data': {...}, 'amrit_kaal_data': {...}, 'brahma_muhurat_data': {...},
///      'rahu_kaalam_data': {...}, 'yama_gandam_data': {...}, 'gulika_kalam_data': {...},
///      'dur_muhurat_data': {'1': {...}, '2': {...}}, 'varjyam_data': {...}
///   },
///   'weekday':        {'weekday_number':.., 'weekday_name':'..',
///                      'vedic_weekday_number':.., 'vedic_weekday_name':'..'},
///   'lunar':          {...},
///   'ritu':           {'number':..,'name':'..'}
/// }
Map<String, dynamic> normalizeAstroResponse(
    String endpoint,
    Map<String, dynamic> raw,
    ) {
  Map<String, dynamic> decodeIfJSONString(dynamic v) {
    if (v is String && v.trim().isNotEmpty) {
      try {
        final d = jsonDecode(v);
        if (d is Map<String, dynamic>) return d;
        if (d is List) return {'list': d};
      } catch (_) {
        // leave as string if not JSON
      }
    }
    if (v is Map) return Map<String, dynamic>.from(v as Map);
    return {};
  }

  Map<String, dynamic> pickOutput(Map<String, dynamic> m) {
    if (m.containsKey('output')) {
      final o = m['output'];
      if (o is Map) return Map<String, dynamic>.from(o);
      return decodeIfJSONString(o);
    }
    return m;
  }

  switch (endpoint) {
    case 'getsunriseandset':
    case 'sunrise_sunset':
    case 'sunrisesunset':
    // your working endpoint returns { statusCode, output: {sun_rise_time, sun_set_time} }
      return {
        'sunrise_sunset': pickOutput(raw),
      };

    case 'tithi-durations':
      return {'tithi': pickOutput(raw)};

    case 'nakshatra-durations':
      return {'nakshatra': pickOutput(raw)};

    case 'yoga-durations': {
      final o = pickOutput(raw);
      // ensure map<String, Map>
      final Map<String, dynamic> yoga = {};
      o.forEach((k, v) => yoga['$k'] = decodeIfJSONString(v)..addAll({}));
      return {'yoga': yoga};
    }

    case 'karana-durations': {
      final o = pickOutput(raw);
      final Map<String, dynamic> karana = {};
      o.forEach((k, v) => karana['$k'] = decodeIfJSONString(v)..addAll({}));
      return {'karana': karana};
    }

    case 'good-bad-times': {
      // sometimes values are JSON strings, sometimes objects
      final keys = [
        'abhijit_data',
        'amrit_kaal_data',
        'brahma_muhurat_data',
        'rahu_kaalam_data',
        'yama_gandam_data',
        'gulika_kalam_data',
        'dur_muhurat_data',
        'varjyam_data',
      ];
      final Map<String, dynamic> gb = {};
      for (final k in keys) {
        final v = raw[k];
        gb[k] = decodeIfJSONString(v);
      }
      return {'goodbad': gb};
    }

    case 'vedicweekday':
      return {'weekday': pickOutput(raw)};

    case 'lunarmonthinfo':
      return {'lunar': pickOutput(raw)};

    case 'rituinfo': {
      // response had { ritu: {number,name} }
      final o = pickOutput(raw);
      if (o.containsKey('ritu')) {
        final r = o['ritu'];
        return {'ritu': decodeIfJSONString(r)};
      }
      return {'ritu': o};
    }

    case 'samvatinfo':
    // not shown on the screen now, but normalize if needed later
      return {'samvat': pickOutput(raw)};

    default:
      return pickOutput(raw);
  }
}

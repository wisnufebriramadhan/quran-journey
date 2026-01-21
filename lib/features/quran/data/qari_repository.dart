
import 'package:quran_tracker/core/models/qari.dart';

class QariRepository {
  static const List<Qari> all = [
    Qari(
      id: 'abdullaah_3awwaad_al-juhaynee',
      name: 'Abdullah Al Juhany',
      type: QariUrlType.complete,
    ),
    Qari(
      id: 'abdurrahmaan_as-sudays',
      name: 'Abdurrahman As-Sudais',
      type: QariUrlType.complete,
    ),
    Qari(
      id: 'mishaari_raashid_al-3afaasee',
      name: 'Mishari Rashid Alafasy',
      type: QariUrlType.complete,
    ),
    Qari(
      id: 'khalid_alghamdi',
      name: 'Khalid Al Ghamdi',
      type: QariUrlType.direct,
    ),
  ];

  static Qari byId(String id) =>
      all.firstWhere((q) => q.id == id);
}

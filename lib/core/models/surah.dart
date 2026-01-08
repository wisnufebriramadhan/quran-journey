class Surah {
  final int number;
  final String name;
  final int ayatCount;

  const Surah({
    required this.number,
    required this.name,
    required this.ayatCount,
  });

  @override
  String toString() => '$number. $name';
}

class NomineeParser {
  /// Parses nominee names and IDs from pipe-separated strings
  static List<Map<String, String>> parseNominees(
    String nominees,
    String nomineeIds,
  ) {
    final nomineeNames = nominees
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final ids = nomineeIds.split('|').map((s) => s.trim()).toList();

    return List.generate(
      nomineeNames.length,
      (i) => {'name': nomineeNames[i], 'id': i < ids.length ? ids[i] : ''},
    );
  }
}

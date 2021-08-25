class Country {
  int? id;
  String? name;
  Country({this.id, this.name});
}

class Region {
  int? id;
  int? countryId;
  String? name;
  Region({this.id, this.name, this.countryId});
}

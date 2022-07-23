import 'package:googleapis/firestore/v1.dart';

class Candidate {
  String name;

  Candidate(this.name);

  @override
  String toString() {
    return ({
      'name': name,
    }).toString();
  }

  static Candidate fromValue(Value candidateValue) => Candidate(candidateValue.stringValue ?? '');
  static List<Candidate> fromValues(Value candidateValues) => (candidateValues.arrayValue?.values ?? []).map((value) => Candidate.fromValue(value)).toList();
}
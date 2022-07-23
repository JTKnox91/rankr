import 'package:googleapis/firestore/v1.dart';

import './candidate.dart';
import './vote.dart';

import './src/constants.dart';

class Election {
  String name;
  Set<Candidate> candidates;
  List<Vote> votes;

  Election(this.name, this.candidates, this.votes);

  @override
  String toString() {
    return ({
      'name': name,
      'candidates': candidates,
      'votes': votes,
    }).toString();
  }

  /// Retrieves the election document for a given ID and constructs an instance of this object from it.
  /// 
  /// If only the canidate names are needed, [ignoreVotes] can be used to speed up the query.
  static Future<Election> getFromElectionId(FirestoreApi api, String electionId, {bool ignoreVotes = false}) {
    final electionDocName = '$projectDocumentBasePath/elections/$electionId';
    final electionDocFuture = api.projects.databases.documents.get(electionDocName);
    final votesFuture = ignoreVotes ? Future.value(null) : Vote.listFromElectionId(api, electionId);
    return Future.wait([electionDocFuture, votesFuture]).then((futures) {
      final electionDoc = futures[0] as Document;
      final votes = futures[1] as List<Vote>?;
      final electionName = electionDoc.fields![nameFieldName]?.stringValue ?? '';
      return Election(electionName, {...Candidate.fromValues(electionDoc.fields![candidatesFieldName]!)}, votes ?? []);
    });
  }
}
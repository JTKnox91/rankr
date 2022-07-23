import 'package:googleapis/firestore/v1.dart';

import './candidate.dart';

import './src/constants.dart';

class Vote {
  List<Candidate> candidates;

  Vote(this.candidates);

  Vote.fromDocument(Document voteDocument) : candidates = Candidate.fromValues(voteDocument.fields![candidatesFieldName]!);

  @override
  String toString() {
    return ({
      'candidates': candidates,
    }).toString();
  }

  static Future<List<Vote>> listFromElectionId(FirestoreApi api, String electionId) {
    final electionDocName = '$projectDocumentBasePath/elections/$electionId';
    final votesCollectionFuture = api.projects.databases.documents.list(electionDocName, 'votes');
    return votesCollectionFuture.then((ListDocumentsResponse voteDocs) {
      return (voteDocs.documents ?? []).map((voteDoc) => Vote.fromDocument(voteDoc)).toList();
    });
  }
}

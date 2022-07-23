// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:rankr/model/election.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'credentials.dart';

const htmlHeaders = <String, String>{
  'Content-type': 'text/html',
};
const jsonHeaders = <String, String>{
  'Content-type': 'application/json',
};

// FYI, 'yPR0HpuPaCoGqFbykAG4' is an election ID is one is needed for local checks.

late FirestoreApi firestoreApi;

Future<Response> _defaultHandler(Request request) async {
  return Response.ok('Welcome the Rankr', headers: htmlHeaders);
}

Future<Response> _votingPageHandler(Request request, String electionId) async {
  try {
    final election = await Election.getFromElectionId(firestoreApi, electionId, ignoreVotes: true);
    return Response.ok(election.toString(), headers: jsonHeaders);
  } catch (e) {
    return Response.internalServerError(body: 'An Error Occured:\n${e.toString()}', headers: htmlHeaders);
  }
}

Future<Response> _resultsPageHandler(Request request, String electionId) async {
  try {
    final election = await Election.getFromElectionId(firestoreApi, electionId);
    return Response.ok(election.toString(), headers: jsonHeaders);
  } catch (e) {
    return Response.internalServerError(body: 'An Error Occured:\n${e.toString()}', headers: htmlHeaders);
  }
}

Future main() async {
  // If the "PORT" environment variable is set, listen to it. Otherwise, 8080.
  // https://cloud.google.com/run/docs/reference/container-contract#port
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final dbClient =
      await clientViaServiceAccount(getCredentials(), [FirestoreApi.datastoreScope]);
  firestoreApi = FirestoreApi(dbClient);

  final app = Router();
  app.get('/<electionId>', _votingPageHandler);
  app.get('/<electionId>/results', _resultsPageHandler);
  app.get('/', _defaultHandler);

  // See https://pub.dev/documentation/shelf/latest/shelf_io/serve.html
  final server = await shelf_io.serve(
    app,
    InternetAddress.anyIPv4, // Allows external connections
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

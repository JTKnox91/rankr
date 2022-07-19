// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';

import 'credentials.dart';

const htmlHeaders = <String, String>{
  'Content-type': 'text/html',
};
const jsonHeaders = <String, String>{
  'Content-type': 'application/json',
};

Future<Response> _defaultHandler(Request request) async {
  final credentials = getCredentials();
  final client =
      await clientViaServiceAccount(credentials, [FirestoreApi.datastoreScope]);
  final firestoreApi = FirestoreApi(client);
  
  try {
    // An arbitrary document id
    final arbitraryDocPath = 'projects/rankr-ch-vote/databases/(default)/documents/election/lEU6p2oi6MeEsV708E1D';
    final result = await firestoreApi.projects.databases.documents.get(arbitraryDocPath);
    return Response.ok(result.toJson().toString(), headers: jsonHeaders);
  } catch (e) {
    return Response.internalServerError(body: 'An Error Occured:\n${e.toString()}', headers: htmlHeaders);
  }
}

Future main() async {
  // If the "PORT" environment variable is set, listen to it. Otherwise, 8080.
  // https://cloud.google.com/run/docs/reference/container-contract#port
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // See https://pub.dev/documentation/shelf/latest/shelf_io/serve.html
  final server = await shelf_io.serve(
    // See https://pub.dev/documentation/shelf/latest/shelf/logRequests.html
    logRequests()
        // See https://pub.dev/documentation/shelf/latest/shelf/MiddlewareExtensions/addHandler.html
        .addHandler(_defaultHandler),
    InternetAddress.anyIPv4, // Allows external connections
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

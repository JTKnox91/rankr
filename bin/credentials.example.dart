import 'package:googleapis_auth/auth_io.dart';

ServiceAccountCredentials getCredentials() {
  return ServiceAccountCredentials.fromJson({
  "type": "XXXX",
  "project_id": "XXXX",
  "private_key_id": "",
  "private_key": "-----BEGIN PRIVATE KEY-----\nXXXX\n-----END PRIVATE KEY-----\n",
  "client_email": "XXXX",
  "client_id": "XXXX",
  "auth_uri": "XXXX",
  "token_uri": "XXXX",
  "auth_provider_x509_cert_url": "XXXX",
  "client_x509_cert_url": "XXXX"
});
}
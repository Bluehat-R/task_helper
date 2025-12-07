// lib/services/auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:googleapis/classroom/v1.dart' as classroom;

class GoogleAuthService {
  static final _googleSignIn = GoogleSignIn(
    scopes: [
      classroom.ClassroomApi.classroomCoursesReadonlyScope,
      classroom.ClassroomApi.classroomCourseworkMeReadonlyScope,
    ],
  );

  static Future<http.Client?> getAuthenticatedClient() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authHeaders;
    final ioClient = IOClient();
    return AuthenticatedClient(ioClient, auth);
  }
}

class AuthenticatedClient extends http.BaseClient {
  final IOClient _inner;
  final Map<String, String> _headers;

  AuthenticatedClient(this._inner, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request..headers.addAll(_headers));
  }
}

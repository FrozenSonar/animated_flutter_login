import '../exceptions/exceptions.dart';
import '../models/models.dart';
import 'package:audioplayers/audio_cache.dart';
abstract class AuthenticationService {
  Future<User> getCurrentUser();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

class FakeAuthenticationService extends AuthenticationService {
  @override

  Future<User> getCurrentUser() async {
    return null; // return null for now
  }

  @override
  final player = AudioCache();
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // simulate a network delay

    if (email.toLowerCase() != 'cictapps@wvsu.edu.ph' || password != '1234') {
      player.play('AD.wav'); //plays the audio when credentials entered are wrong
      throw AuthenticationException(message: 'Wrong username or password'); //when anything is entered aside from actual credentials app will bring up error
    }
    return User(name: 'Test User', email: email);
  }

  @override
  Future<void> signOut() {
    return null;
  }
}

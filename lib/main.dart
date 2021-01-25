import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/blocs.dart';
import 'services/services.dart';
import 'pages/pages.dart';
import 'package:audioplayers/audio_cache.dart'; //enables to play local sound assets

void main() => runApp(
        // Injects the Authentication service
        RepositoryProvider<AuthenticationService>(
      create: (context) {
        return FakeAuthenticationService();
      },
      // Injects the Authentication BLoC
      child: BlocProvider<AuthenticationBloc>(
        create: (context) {
          final authService = RepositoryProvider.of<AuthenticationService>(context);
          return AuthenticationBloc(authService)..add(AppLoaded());
        },
        child: MyApp(),
      ),
    ));

class MyApp extends StatelessWidget {
  @override
  final player = AudioCache(); //initialization for playing Audio
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            // show home page if exact credentials are entered.
            player.play('DC1.wav'); //plays audio
            return HomePage(
              user: state.user,
            );
          }
          // otherwise show login page
          return LoginPage();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/blocs.dart';
import '../services/services.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audio_cache.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container( //Background
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),

          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              final authBloc = BlocProvider.of<AuthenticationBloc>(context);
              if (state is AuthenticationNotAuthenticated) {
                return _AuthForm();
              }
              if (state is AuthenticationFailure) {
                return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(state.message),

                        FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text('Retry'),
                          onPressed: () {
                            authBloc.add(AppLoaded());
                          },
                        )
                      ],
                    ));
              }
              // return splash screen
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            },
          )),
    );
  }
}

class _AuthForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Container(
      alignment: Alignment.center,
      child: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(authBloc, authService),
        child: _SignInForm(),
      ),
    );
  }
}

class _SignInForm extends StatefulWidget {
  @override
  __SignInFormState createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> with TickerProviderStateMixin{
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _autoValidate = false;

  //Animation variables
  //===============================
  AnimationController _controller;


  @override
  final player = AudioCache();
  void initState() {
    super.initState();

    _controller = AnimationController(
      /*
       This code is when the user types in the Email and password text fields
       the animation and sound goes along with it
       */
        vsync: this,
        lowerBound: 0.40,
        upperBound: 0.50,
        duration: Duration(milliseconds: 30) );
    _emailController.addListener(() {
      _controller.forward().then((value) => _controller.reverse());
      player.play('KB1.wav');
      //_controller.reverse();
    });
    _passwordController.addListener(() {
      _controller.forward().then((value) => _controller.reverse());
      player.play('KB1.wav');
      //_controller.reverse();
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }


  //=====================================

  @override

  Widget build(BuildContext context) {
    final _loginBloc = BlocProvider.of<LoginBloc>(context);

    _onLoginButtonPressed() {
      if (_key.currentState.validate()) {
        _loginBloc.add(LoginInWithEmailButtonPressed(email: _emailController.text, password: _passwordController.text));
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          _showError(state.error);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );

          }
          return Container(
            margin: const EdgeInsets.only(top: 0, bottom: 90, right: 20, left: 20), // Resizes the buttons and textfields and places a margin around them
            child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Lottie.network(
                    'https://assets1.lottiefiles.com/private_files/lf30_UsJGRD.json',
                    controller: _controller,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration( //Puts Border around textfield and hightlights once you click it
                      labelText: 'Email address',
                      filled: true,
                      isDense: true,
                      fillColor: Color(0xffe7f7f7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                      ),
                    ),

                    controller: _emailController, //This connects to the animation as the controller
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null) {
                        return 'Email is required.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(//Puts Border around textfield and hightlights once you click it
                      labelText: 'Password',
                      filled: true,
                      isDense: true,
                      fillColor: Color(0xffe7f7f7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(29),
                        borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                      ),
                    ),
                    obscureText: true,
                    controller: _passwordController, //This connects to the animation as the controller
                    validator: (value) {
                      if (value == null) {
                        return 'Password is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    focusColor: Colors.white,
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(29.0)),
                    child: Text('LOG IN'),
                    onPressed: state is LoginLoading ? () { } : _onLoginButtonPressed,
                  )
                ],
              ),
            ),
            ),
          );
        },

      ),
    );
  }

  void _showError(String error) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(error),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }
}

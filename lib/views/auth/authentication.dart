import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mova/constants.dart';
import 'package:mova/views/menu/menu_screen.dart';
import 'package:mova/views/widgets/utils.dart';
import 'package:mova/views/widgets/widgets.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  password,
  loggedIn,
}

class Authentication extends StatelessWidget {
  Authentication({
    required this.loginState,
    required this.email,
    required this.startLoginFlow,
    required this.verifyEmail,
    required this.signInWithEmailAndPassword,
    required this.cancelRegistration,
    required this.registerAccount,
    required this.signOut,
  });

  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;
  final Future<String> Function(String email) verifyEmail;
  final Future<bool> Function(
    String email,
    String password,
    BuildContext context,
    void Function(Exception e) error,
  ) signInWithEmailAndPassword;
  final void Function() cancelRegistration;
  final Future<bool> Function(
    String email,
    String displayName,
    String password,
    BuildContext context,
    void Function(Exception e) error,
  ) registerAccount;
  final void Function() signOut;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
      case ApplicationLoginState.emailAddress:
        return Column(
          children: [
            EmailForm(
              callback: (email) => verifyEmail(
                email,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, MenuScreen.id);
              },
              child: const Text('use only locally'),
            ),
          ],
        );
      case ApplicationLoginState.password:
        return PasswordForm(
          email: email!,
          outerContext: context,
          login: (email, password, context) => signInWithEmailAndPassword(email, password, context,
              (e) => Utils.showErrorDialogWitException(context, 'Failed to sign in', e)),
        );
      case ApplicationLoginState.register:
        return RegisterForm(
          email: email!,
          cancel: () {
            cancelRegistration();
          },
          outerContext: context,
          registerAccount: (
            email,
            displayName,
            password,
            context,
          ) =>
              registerAccount(email, displayName, password, context,
                  (e) => Utils.showErrorDialogWitException(context, 'Failed to sign in', e)),
        );
      case ApplicationLoginState.loggedIn:
        if (email == null || email!.isEmpty) signOut();
        //TODO push delaed - logged in successfully
        // else Navigator.pushReplacementNamed(context, MenuScreen.id);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'You\'re logged in as:',
                style: kLoginFormLabelText,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                email ?? '',
                style: kLoginFormText.copyWith(fontSize: 20.0),
              ),
              SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: StyledButton(
                        onPressed: () {
                          signOut();
                        },
                        controller: _btnController,
                        child: const Text(
                          'Log out',
                          style: kLoginFormButtonText,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: StyledButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, MenuScreen.id),
                        controller: _btnController,
                        child: const Text(
                          'Proceed',
                          style: kLoginFormButtonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }
}

class EmailForm extends StatefulWidget {
  const EmailForm({required this.callback});

  final Future<String> Function(String email) callback;

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Sign in'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: kLoginFormText,
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: kLoginFormHintText,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      } else if (errorMessage.isNotEmpty) {
                        String toReturn = errorMessage;
                        errorMessage = '';
                        return toReturn;
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: StyledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String result = await widget.callback(_controller.text);
                            errorMessage = result;
                            if (_formKey.currentState!.validate() && result == 'SUCCESS') {
                              _btnController.success();
                              return;
                            }
                          }
                          _btnController.error();
                        },
                        controller: _btnController,
                        child: const Text(
                          'continue',
                          style: kLoginFormButtonText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    required this.registerAccount,
    required this.cancel,
    required this.email,
    required this.outerContext,
  });

  final BuildContext outerContext;
  final String email;
  final Future<bool> Function(
    String email,
    String displayName,
    String password,
    BuildContext context,
  ) registerAccount;
  final void Function() cancel;

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Create account'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: kLoginFormText,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: kLoginFormHintText,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: kLoginFormText,
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      hintText: 'First & last name',
                      hintStyle: kLoginFormHintText,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your account name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: kLoginFormText,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: kLoginFormHintText,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.cancel,
                        child: const Text(
                          'cancel',
                          style: kLoginFormButtonText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      StyledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (await widget.registerAccount(
                              _emailController.text,
                              _displayNameController.text,
                              _passwordController.text,
                              widget.outerContext,
                            )) {
                              _btnController.success();
                              return;
                            }
                          }
                          _btnController.error();
                        },
                        controller: _btnController,
                        child: const Text(
                          'save',
                          style: kLoginFormButtonText,
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordForm extends StatefulWidget {
  const PasswordForm({
    required this.login,
    required this.email,
    required this.outerContext,
  });

  final BuildContext outerContext;
  final String email;
  final Future<bool> Function(String email, String password, BuildContext context) login;

  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Sign in'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: kLoginFormText,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: kLoginFormHintText,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: kLoginFormText,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: kLoginFormHintText,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16),
                      StyledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (await widget.login(
                              _emailController.text,
                              _passwordController.text,
                              widget.outerContext,
                            )) {
                              _btnController.success();
                              return;
                            }
                          }
                          _btnController.error();
                        },
                        controller: _btnController,
                        child: const Text(
                          'sign in',
                          style: kLoginFormButtonText,
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

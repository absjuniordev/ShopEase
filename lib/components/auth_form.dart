import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _passwordControlle = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.Signup;
      } else {
        _authMode = AuthMode.Login;
      }
    });
  }

  void _submit() {
    final isvalid = _formKey.currentState?.validate() ?? false;
    if (!isvalid) {
      return;
    }
    _formKey.currentState?.save();
    if (_isLogin()) {
      //
    } else {
      //
    }
    setState(() => _isLoading = true);
  }

  bool _isLogin() => _authMode == AuthMode.Login;
  bool _isSignup() => _authMode == AuthMode.Signup;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: _isLogin() ? 310 : 400,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (_email) {
                  final email = _email ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordControlle,
                decoration: const InputDecoration(labelText: 'Senha'),
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                validator: (_password) {
                  final password = _password ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Informe uma senha valida';
                  }
                  return null;
                },
                onSaved: (password) => _authData['password'] = password ?? '',
              ),
              if (_isSignup())
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Confirme Senha'),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  validator: _isLogin()
                      ? null
                      : (_password) {
                          final password = _password ?? '';
                          if (password != _passwordControlle.text) {
                            return 'Senha não confere';
                          }
                          return null;
                        },
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                  child: Text(_isLogin() ? 'ENTRAR' : 'REGISTRAR'),
                ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child:
                    Text(_isLogin() ? "DESEJA REGISTRAR?" : "JÁ POSSUE CONTA?"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

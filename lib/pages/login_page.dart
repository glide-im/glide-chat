import 'package:flutter/material.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/utils/extensions.dart';
import 'package:glide_chat/utils/logger.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/dialog.dart';
import 'package:glide_chat/widget/window.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: Adaptive(
        builder: (c) => _LoginMobile(),
        L: (c) => _LoginDesktop(),
      ),
    );
  }
}

class _LoginDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            children: [Spacer(), WindowBarActions()],
          ),
          const SizedBox(height: 160),
          Card(
            child: Container(
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: LoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColorLight,
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoginForm(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GlobalCubit.of(context).logout();
  }

  Future guestLogin(BuildContext context) async {
    try {
      await GlobalCubit.of(context).loginGuest();
    } catch (_, e) {
      loge("login page", e);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  }

  Future login(BuildContext context) async {
    final account = _accountController.text;
    final password = _passwordController.text;

    if (account.isEmpty || password.isEmpty) {
      return;
    }

    try {
      await GlobalCubit.of(context).login(account, password);
    } catch (_, e) {
      loge("login page", e);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Glide Chat",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountController,
            decoration: const InputDecoration(labelText: "Account"),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            keyboardType: TextInputType.visiblePassword,
            decoration: const InputDecoration(labelText: "Password"),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await context.loading(guestLogin(context));
                  if (context.mounted) AppRoutes.home.go(context);
                },
                child: const Text("Guest"),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("TODO")));
                  }
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  await context.loading(login(context));
                  if (context.mounted) AppRoutes.home.go(context);
                },
                child: const Center(
                  widthFactor: 1,
                  child: Text("Sign In"),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

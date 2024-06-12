import 'package:flutter/material.dart';
import 'package:glide_chat/global_cubit.dart';
import 'package:glide_chat/routes.dart';
import 'package:glide_chat/widget/adaptive.dart';
import 'package:glide_chat/widget/dialog.dart';
import 'package:glide_chat/widget/window.dart';
import 'package:glide_chat/widget/window_dragble.dart';

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
  Future guestLogin(BuildContext context) async {
    try {
      await GlobalCubit.of(context).loginGuest();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  }

  Future login(BuildContext context) async {
    try {
      await GlobalCubit.of(context).login();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            children: [
              Spacer(),
              WindowBarActions()
            ],
          ),
          const SizedBox(height: 160),
          Card(
            child: Container(
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Form(
                  child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome to Glide Chat",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Account"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
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
                        onPressed: () {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("TODO")));
                          }
                        },
                        child: const Text("Sign Up"),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          context.loading(Future(() async {
                            await context.loading(login(context));
                            await Future.delayed(Duration(seconds: 2));
                            if (context.mounted) AppRoutes.home.go(context);
                          }));
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
              )),
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
    return Column();
  }
}

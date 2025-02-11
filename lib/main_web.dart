import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glide_chat/bloc/global_cubit.dart';
import 'package:glide_chat/bloc/session_cubit.dart';

import 'app.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => GlobalCubit()),
        BlocProvider(create: (ctx) => SessionCubit()),
      ],
      child: const GlideApp(),
    ),
  );
}

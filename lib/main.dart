import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/src/app_root.dart';
import 'cubit/favourite_cubit.dart';
import 'cubit/weather_cubit.dart';
import 'di/initialize_dependency.dart';
import 'pages/home_page.dart';
import 'services/repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDependency();
  runApp(const AppView());
}

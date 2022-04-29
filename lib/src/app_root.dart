import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/favourite_cubit.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/di/initialize_dependency.dart';
import 'package:weather_app/pages/home_page.dart';
import 'package:weather_app/services/repository.dart';


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppView();
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (BuildContext context) =>
                    WeatherCubit(injector.get<IRepository>()),
              ),
              BlocProvider(
                create: (BuildContext context) => FavouriteCubit(),
              )
            ],
            child: const MaterialApp(
              title: 'Weather App',
              home: HomePage(),
            )));
  }
}

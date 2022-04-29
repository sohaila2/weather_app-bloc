import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/models/forecast.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/pages/favourite_page.dart';
import 'widgets/city_information_widget.dart';
import 'widgets/city_entry_widget.dart';
import 'widgets/daily_summary_widget.dart';
import 'widgets/gradient_container_widget.dart';
import 'widgets/indicator_widget.dart';
import 'widgets/last_update_widget.dart';
import 'widgets/weather_description_widget.dart';
import 'widgets/weather_summary_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<void>? _refreshCompleter;
  Forecast? _forecast;
  bool isSelectedDate = false;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  void searchCity() {
    isSelectedDate = false;
    _forecast = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade800,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () async {
                isSelectedDate = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavouritePage(),
                  ),
                );
              },
            )
          ],
        ),
        body: _buildGradientContainer(
            _forecast == null
                ? WeatherCondition.clear
                : _forecast!.current.condition,
            _forecast == null ? false : _forecast!.isDayTime,
            Container(
                height: MediaQuery.of(context).size.height,
                child: RefreshIndicator(
                    color: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    onRefresh: () => refreshWeather(
                        (BlocProvider.of<WeatherCubit>(context).state
                                as WeatherLoaded)
                            .forecast),
                    child: ListView(children: <Widget>[
                      CityEntryWidget(callBackFunction: searchCity),
                      BlocBuilder<WeatherCubit, WeatherState>(
                          builder: (context, state) {
                        if (state is WeatherInitial) {
                          return buildMessageText(state.message);
                        } else if (state is WeatherLoading) {
                          return const IndicatorWidget();
                        } else if (state is WeatherLoaded) {
                          if (!isSelectedDate) {
                            _forecast = state.forecast;
                          }
                          return buildColumnWithData();
                        } else if (state is WeatherError) {
                          return buildMessageText(state.message);
                        } else {
                          return const IndicatorWidget();
                        }
                      })
                    ])))));
  }

  Widget buildMessageText(String message) {
    return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
            child: Text(message,
                style: const TextStyle(fontSize: 21, color: Colors.white))));
  }

  Widget buildColumnWithData() {
    return Column(children: [
      CityInformationWidget(
          city: _forecast!.city,
          sunrise: _forecast!.sunrise,
          sunset: _forecast!.sunset,
          isFavourite: _forecast!.isFavourite),
      const SizedBox(height: 40),
      WeatherSummaryWidget(
          date: _forecast!.date,
          condition: _forecast!.current.condition,
          temp: _forecast!.current.temp,
          feelsLike: _forecast!.current.feelLikeTemp),
      const SizedBox(height: 20),
      WeatherDescriptionWidget(
          weatherDescription: _forecast!.current.description),
      const SizedBox(height: 40),
      buildDailySummary(_forecast!.daily),
      LastUpdatedWidget(lastUpdatedOn: _forecast!.lastUpdated)
    ]);
  }

  Widget buildDailySummary(List<Weather> dailyForecast) {
    return Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: dailyForecast.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  onTap: () {
                    isSelectedDate = true;
                    _forecast!.date = dailyForecast[index].date;
                    _forecast!.sunrise = dailyForecast[index].sunrise;
                    _forecast!.sunset = dailyForecast[index].sunset;
                    _forecast!.current = dailyForecast[index];

                    _refreshCompleter?.complete();
                    _refreshCompleter = Completer();
                    refreshWeather(_forecast!);
                  },
                  child: DailySummaryWidget(weather: dailyForecast[index]));
            }));
  }

  Future<void> refreshWeather(Forecast forecast) {
    if (isSelectedDate) {
      setState(() {
        _forecast = forecast;
      });
      return _refreshCompleter!.future;
    } else {
      return BlocProvider.of<WeatherCubit>(context)
          .getWeather(forecast.city, forecast.isFavourite);
    }
  }

  GradientContainerWidget _buildGradientContainer(
      WeatherCondition condition, bool isDayTime, Widget child) {
    GradientContainerWidget container;
    if (!isDayTime) {
      container = GradientContainerWidget(color: Colors.blueGrey, child: child);
    } else {
      switch (condition) {
        case WeatherCondition.clear:
        case WeatherCondition.lightCloud:
          container =
              GradientContainerWidget(color: Colors.yellow, child: child);
          break;
        case WeatherCondition.rain:
        case WeatherCondition.drizzle:
        case WeatherCondition.mist:
        case WeatherCondition.heavyCloud:
          container =
              GradientContainerWidget(color: Colors.indigo, child: child);
          break;
        case WeatherCondition.snow:
          container =
              GradientContainerWidget(color: Colors.lightBlue, child: child);
          break;
        case WeatherCondition.thunderstorm:
          container =
              GradientContainerWidget(color: Colors.deepPurple, child: child);
          break;
        default:
          container =
              GradientContainerWidget(color: Colors.lightBlue, child: child);
      }
    }

    return container;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {
  final bool isDarkMode;
  ToggleTheme(this.isDarkMode);
}

class LoadTheme extends ThemeEvent {}

class ThemeState {
  final ThemeMode themeMode;
  ThemeState(this.themeMode);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FlutterSecureStorage secureStorage;
  static const String _themeKey = 'is_dark_mode';

  ThemeBloc({required this.secureStorage}) : super(ThemeState(ThemeMode.light)) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final val = await secureStorage.read(key: _themeKey);
    final isDark = val == 'true';
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    await secureStorage.write(key: _themeKey, value: event.isDarkMode.toString());
    emit(ThemeState(event.isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }
}

import 'package:flutter/material.dart';
import 'package:orbit/l10n/app_localizations.dart';

/// テスト用に [AppLocalizations] を備えた [MaterialApp] で [child] を包む。
///
/// ロケールは決定的に固定する(既定は日本語)。本番は端末ロケールに追従するが、
/// テストでは locale を固定して表示文字列を決定的にする(ハーネス方針)。
Widget localizedApp(Widget child, {Locale locale = const Locale('ja')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

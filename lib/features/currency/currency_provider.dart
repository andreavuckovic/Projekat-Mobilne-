import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Currency { eur, rsd }

final currencyProvider =
    NotifierProvider<CurrencyController, Currency>(CurrencyController.new);

class CurrencyController extends Notifier<Currency> {
  @override
  Currency build() => Currency.eur;

  void toggle() {
    state = state == Currency.eur ? Currency.rsd : Currency.eur;
  }

  void setCurrency(Currency c) {
    state = c;
  }
}

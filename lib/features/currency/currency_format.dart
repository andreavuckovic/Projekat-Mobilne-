import 'currency_provider.dart';

const double eurToRsd = 117.0;

String formatPrice(double eur, Currency currency) {
  if (currency == Currency.eur) {
    return '${eur.toStringAsFixed(0)} €';
  }
  final rsd = eur * eurToRsd;
  return '${rsd.toStringAsFixed(0)} RSD';
}

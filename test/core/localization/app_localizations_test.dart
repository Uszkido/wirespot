import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/currency/currency_formatter.dart';
import 'package:wirespot/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('translates key terms to Hausa', () {
      final loc = AppLocalizations(AppLanguage.hausa);
      expect(loc.translate('dashboard'), 'Shafin Farko');
      expect(loc.translate('vouchers'), 'Katin Samun Intanet');
      expect(loc.translate('reports'), 'Rahotanni');
    });

    test('translates key terms to Yoruba', () {
      final loc = AppLocalizations(AppLanguage.yoruba);
      expect(loc.translate('dashboard'), 'Oju-ewe Agbara');
      expect(loc.translate('vouchers'), 'Awon Tiketi Intaneti');
      expect(loc.translate('total_revenue'), 'Apapọ Owo Ti A Wole');
    });

    test('translates key terms to Igbo', () {
      final loc = AppLocalizations(AppLanguage.igbo);
      expect(loc.translate('dashboard'), 'Mpaghara Mhazi');
      expect(loc.translate('vouchers'), 'Akwụkwọ Tiketi Intanet');
      expect(loc.translate('total_revenue'), 'Ego Niile Betara');
    });

    test('translates key terms to Nigerian Pidgin', () {
      final loc = AppLocalizations(AppLanguage.pidgin);
      expect(loc.translate('dashboard'), 'Main Dashboard');
      expect(loc.translate('vouchers'), 'Wi-Fi Ticket Vouchers');
      expect(loc.translate('total_revenue'), 'Total Money Wey Enter');
    });

    test('parses language codes accurately', () {
      expect(AppLanguage.fromCode('yo'), AppLanguage.yoruba);
      expect(AppLanguage.fromCode('ig'), AppLanguage.igbo);
      expect(AppLanguage.fromCode('pcm'), AppLanguage.pidgin);
      expect(AppLanguage.fromCode('ha'), AppLanguage.hausa);
    });
  });

  group('CurrencyFormatter', () {
    test('formats NGN Naira correctly', () {
      final result = CurrencyFormatter.format(50000, currencyCode: 'NGN');
      expect(result, '₦500.00');
    });

    test('formats KES Kenyan Shilling correctly', () {
      final result = CurrencyFormatter.format(15000, currencyCode: 'KES');
      expect(result, 'KSh150.00');
    });

    test('formats GHS Ghanaian Cedi correctly', () {
      final result = CurrencyFormatter.format(2500, currencyCode: 'GHS');
      expect(result, 'GH₵25.00');
    });

    test('formats USD Dollar correctly', () {
      final result = CurrencyFormatter.format(1000, currencyCode: 'USD');
      expect(result, '\$10.00');
    });
  });
}

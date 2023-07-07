import 'package:intl/intl.dart';
import 'package:money/money.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('should parse string values to raw values', () {
      expect(Money.parse(''), Money.zero);
      expect(Money.parse('0'), Money.zero);
      expect(Money.parse('1'), Money(1000000));
      expect(Money.parse('0').rawValue, 0);
      expect(Money.parse('1').rawValue, 1000000);
      expect(Money.parse('1,000,100.34567').rawValue, 1000100345670);
    });

    test('should format values to currency', () {
      expect(Money.parse('0').formatted, "\$0.00");
      expect(Money.parse('1').formatted, "\$1.00");
      expect(Money.parse('1,000,100.34567').formatted, "\$1,000,100.35");
      expect(Money.parse('1,000,100.34567').toString(), "\$1,000,100.35");
    });

    test('should support editable representation', () {
      expect(Money.parse('0').editableTextValue, '0');
      expect(Money.parse('1').editableTextValue, '1');
      expect(Money.parse('1,000,100.34567').editableTextValue, '1000100.346');
    });

    test('should support percentage representation', () {
      expect(Money.parse('1').percentage(Money.parse('100')), '1.0%');
    });

    test('should support calculating fractions', () {
      expect(Money.parse('1').ratio(Money.parse('100')), 0.01);
    });

    test('should support addition & subtraction', () {
      expect(Money.parse('1') + Money.parse('1'), Money.parse('2'));
      expect(Money.parse('2') - Money.parse('1'), Money.parse('1'));
    });

    test('should support multiplication', () {
      expect(Money.parse('2') * Money.parse('2'), Money.parse('4').rawValue);
      expect(Money.parse('2') * 2, Money.parse('4').rawValue);
      expect(Money.parse('2') * 2.0, Money.parse('4').rawValue);
      expect(Money.parse('2') * Money.parse('2'), Money.parse('4').rawValue);

      expect(() => Money.parse('4') * '2.0', throwsArgumentError);
    });

    test('should support divisions', () {
      expect(Money.parse('4') / Money.parse('2'), 2.0);
      expect(Money.parse('4') / 2, Money.parse('2').rawValue);
      expect(Money.parse('4') / 2.0, Money.parse('2').rawValue);

      expect(() => Money.parse('4') / '2.0', throwsArgumentError);
    });

    test('should support equality', () {
      expect(Money.parse('1'), equals(Money.parse('1')));
      expect(Money.parse('1'), greaterThan(Money.parse('0')));
      expect(Money.parse('1') >= Money.parse('0'), isTrue);
      expect(Money.parse('1'), lessThan(Money.parse('2')));
      expect(Money.parse('1') <= Money.parse('2'), isTrue);
      expect(Money.parse('1').hashCode, Money.parse('1').hashCode);
    });

    test('should support the comparable api', () {
      expect(Money.parse('1').compareTo(Money.parse('1')), 0);
      expect(Money.parse('1').compareTo(Money.parse('0')), 1);
      expect(Money.parse('1').compareTo(Money.parse('2')), -1);
    });

    test('should support changing global Intl locale', () {
      final defaultLocale = Intl.defaultLocale;
      addTearDown(() => Intl.defaultLocale = defaultLocale);

      expect(Money.decimalSeparator, '.');
      expect(Money.regExp.pattern, '^\\d+.?\\d{0,4}');
      expect(Money.parse('1').formatted, "\$1.00");

      Intl.defaultLocale = 'nl_NL';
      expect(Money.decimalSeparator, ',');
      expect(Money.regExp.pattern, '^\\d+,?\\d{0,4}');
      expect(Money.parse('1.000,10').formatted, "€ 1.000,10");

      Intl.defaultLocale = 'de_DE';
      expect(Money.decimalSeparator, ',');
      expect(Money.regExp.pattern, '^\\d+,?\\d{0,4}');
      expect(Money.parse('1.000,10').formatted, "1.000,10 €");
    });

    test('should support changing global decimal digits', () {
      addTearDown(() => Money.decimalDigits = Money.defaultDecimalDigits);

      Money.decimalDigits = 0;
      expect(Money.parse('1,000,100.34567').formatted, "\$1,000,100");

      Money.decimalDigits = 3;
      expect(Money.parse('1,000,100.34567').formatted, "\$1,000,100.346");
    });

    test('should support changing global percentage decimal digits', () {
      addTearDown(() => Money.percentageDecimalDigits = Money.defaultPercentageDecimalDigits);

      Money.percentageDecimalDigits = 0;
      expect(Money.parse('1').percentage(Money.parse('100')), "1%");

      Money.percentageDecimalDigits = 3;
      expect(Money.parse('1').percentage(Money.parse('100')), "1.000%");
    });

    test('include extension from int to Money', () {
      expect(2000000.asMoney, Money.parse('2'));
    });

    test('should support summation of Money from an Iterable', () {
      expect([Money.parse('1'), Money.parse('1')].sum(), Money.parse('2'));
    });
  });
}

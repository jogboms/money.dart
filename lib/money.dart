import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class Money implements Comparable<Money> {
  const Money(this.rawValue);

  static const Money zero = Money(0);

  static Money parse(String value) {
    if (value.isEmpty) {
      return Money.zero;
    }
    return Money((_numberFormat.parse(value) * divisor).toInt());
  }

  @visibleForTesting
  static const double divisor = 1e+6;
  @visibleForTesting
  static const int defaultDecimalDigits = 2;
  @visibleForTesting
  static const int defaultPercentageDecimalDigits = 1;

  static set decimalDigits(int digits) => _decimalDigits = digits;
  static int _decimalDigits = defaultDecimalDigits;

  static set percentageDecimalDigits(int digits) => _percentageDecimalDigits = digits;
  static int _percentageDecimalDigits = defaultPercentageDecimalDigits;

  static NumberFormat get _numberFormat => NumberFormat.simpleCurrency(decimalDigits: _decimalDigits);

  static String get decimalSeparator => _numberFormat.symbols.DECIMAL_SEP;

  static RegExp get regExp => RegExp('^\\d+$decimalSeparator?\\d{0,4}');

  final int rawValue;

  double get _editableValue => rawValue / divisor;

  String get editableTextValue =>
      NumberFormat.decimalPattern().format(_editableValue).replaceAll(_numberFormat.symbols.GROUP_SEP, '');

  String get formatted => _numberFormat.format(_editableValue);

  double ratio(Money of) => this / of;

  String percentage(Money of) => NumberFormat.decimalPercentPattern(
        decimalDigits: _percentageDecimalDigits,
      ).format(ratio(of));

  Money operator +(Money other) => Money(rawValue + other.rawValue);

  Money operator -(Money other) => Money(rawValue - other.rawValue);

  double operator *(Object other) {
    if (other is Money) {
      return (rawValue * other.rawValue) / divisor;
    } else if (other is num) {
      return (rawValue * other).toDouble();
    }

    throw ArgumentError('Invalid multiplier type. Supports only Money or num types');
  }

  double operator /(Object other) {
    if (other is Money) {
      return rawValue / other.rawValue;
    } else if (other is num) {
      return rawValue / other;
    }

    throw ArgumentError('Invalid divisor type. Supports only Money or num types');
  }

  bool operator >(Money other) => rawValue > other.rawValue;

  bool operator >=(Money other) => rawValue >= other.rawValue;

  bool operator <(Money other) => rawValue < other.rawValue;

  bool operator <=(Money other) => rawValue <= other.rawValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Money && runtimeType == other.runtimeType && rawValue == other.rawValue;

  @override
  int get hashCode => rawValue.hashCode;

  @override
  int compareTo(Money other) => rawValue.compareTo(other.rawValue);

  @override
  String toString() => formatted;
}

extension MoneyIntExtension on int {
  Money get asMoney => Money(this);
}

extension MoneyIterableSumExtension on Iterable<Money> {
  Money sum() => isEmpty ? Money.zero : reduce((Money value, Money current) => value + current);
}

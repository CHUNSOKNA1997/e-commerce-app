String formatCurrency(num value) {
  final amount = value.toDouble();
  final whole = amount.truncate().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final decimals = ((amount - amount.truncate()) * 100).round()
      .toString()
      .padLeft(2, '0');
  return '\$$whole.$decimals';
}

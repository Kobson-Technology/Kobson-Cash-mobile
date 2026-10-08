import 'package:intl/intl.dart';

class Formatters {
  static final _numberFormat = NumberFormat('#,##0', 'fr_FR');
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  static final _dateOnlyFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

  static String formatCurrency(num amount) {
    return '${_numberFormat.format(amount)} FCFA';
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateFormat.format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    return _dateOnlyFormat.format(dateTime.toLocal());
  }

  static String formatDateOnly(DateTime dateTime) {
    return _dateOnlyFormat.format(dateTime.toLocal());
  }

  static String formatTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'membershippayment':
        return 'Achat du Coffre';
      case 'referralcommission':
        return 'Commission de Parrainage';
      case 'withdrawal':
        return 'Retrait Décaissé';
      case 'withdrawalhold':
        return 'Retrait en Réserve';
      case 'withdrawalrelease':
        return 'Libération Réserve';
      case 'refund':
        return 'Remboursement';
      case 'adjustment':
        return 'Ajustement';
      case 'platformrevenue':
        return 'Revenu Kobson';
      case 'paymentfee':
        return 'Frais Opérateur';
      default:
        return type;
    }
  }
}

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
    // Handle integer type values sent by backend (WalletTransactionType enum as int)
    switch (type.trim()) {
      case '1':
      case 'membershippayment':
        return 'Achat du Coffre';
      case '2':
      case 'referralcommission':
        return 'Commission de Parrainage';
      case '3':
      case 'withdrawal':
        return 'Retrait Décaissé';
      case '4':
      case 'withdrawalhold':
        return 'Retrait en Réserve';
      case '5':
      case 'withdrawalrelease':
        return 'Libération Réserve';
      case '6':
      case 'refund':
        return 'Remboursement';
      case '7':
      case 'adjustment':
        return 'Ajustement';
      case '8':
      case 'platformrevenue':
        return 'Revenu Kobson';
      case '9':
      case 'paymentfee':
        return 'Frais Opérateur';
      case '10':
      case 'questbonus':
        return 'Prime Quête';
      default:
        return type.isNotEmpty ? type : 'Transaction';
    }
  }
}

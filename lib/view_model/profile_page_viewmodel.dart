import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siparis_takip/constants/ShowSnackBar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePageViewmodel extends ChangeNotifier {
  String _savedValue = '';

  Future<void> saveValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('my_key', value);
    await loadSavedValue(); // Güncellenmiş değeri yükle
  }

  Future<String> loadSavedValue() async {
    final prefs = await SharedPreferences.getInstance();
    _savedValue = prefs.getString('my_key') ?? 'Önce iban ekle ve kaydet.'; // Varsayılan değer 'Yok'
    notifyListeners(); // Değişiklikleri dinleyicilere bildir
    return _savedValue;
  }

  Future<void> shareViaWhatsApp(BuildContext context, String message) async {
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ShowSnackBar.showSnackbar(context, 'WhatsApp uygulaması yüklenmemiş olabilir.');
    }
  }

  String get savedValue => _savedValue; // Getter ekleyin
}

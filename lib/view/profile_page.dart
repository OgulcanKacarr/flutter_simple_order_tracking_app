import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siparis_takip/constants/AppSizes.dart';
import 'package:siparis_takip/constants/AppStrings.dart';
import 'package:siparis_takip/view_model/profile_page_viewmodel.dart';

import '../constants/ShowSnackBar.dart';

final view_model = ChangeNotifierProvider((ref) => ProfilePageViewmodel());
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController ibanController;

  @override
  void initState() {
    super.initState();
    ibanController = TextEditingController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final viewModel = ref.read(view_model);
    final savedValue = await viewModel.loadSavedValue();
    setState(() {
      ibanController.text = savedValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // İçeride biraz boşluk bırakma
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: const Text(AppStrings.iban_share,style: TextStyle(
            color: Colors.red,
            fontSize: AppSizes.paddingMedium
          ),),),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: ibanController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.iban,
                    border: OutlineInputBorder(), // Kenarlık ekleyerek görünürlüğü artırabilirsiniz
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // İkon ile text field arasında boşluk
              IconButton(
                onPressed: () {
                  ref.watch(view_model).shareViaWhatsApp(context,ibanController.text);
                },
                icon: const Icon(Icons.share, color: Colors.green,),
              ),
            ],
          ),
          Center(
            child: TextButton(
              onPressed: () {
                ref.read(view_model).saveValue(ibanController.text);
                ShowSnackBar.showSnackbar(context, AppStrings.iban_saved);
              },
              child: const Text(AppStrings.iban_save),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    ibanController.dispose();
    super.dispose();
  }
}



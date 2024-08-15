import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siparis_takip/services/DatabaseHelper.dart';
import 'package:siparis_takip/view_model/base_page_viewmodel.dart';

import '../constants/AppStrings.dart';
import '../model/Customers.dart';
import '../model/Orders.dart';

final view_model = ChangeNotifierProvider((ref) => BasePageViewmodel());

class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();




  @override
  Widget build(BuildContext context) {
    var watch = ref.watch(view_model);
    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: bottomNavigationBar(watch),
      floatingActionButton: floatButton(),
      body: ref.watch(view_model).buildBody(),
    );
  }

Widget floatButton(){
 return FloatingActionButton(
    backgroundColor: Colors.green,
    child: const Icon(
      Icons.add,
      color: Colors.white,
    ),
    onPressed: () async {
      ref.watch(view_model).showOrderDialog(context);
    },
  );
}

Widget bottomNavigationBar(var watch){
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.pinkAccent,
      items: watch.list,
      currentIndex: watch.current_index,
      onTap: (new_index) {
        watch.setCurrentIndex(new_index);
      },
    );
}

AppBar _buildAppBar(){
    return AppBar(
      title: const Row(
        children: [
          Icon(
            Icons.shop,
            color: Colors.green,
          ),
          SizedBox(
            width: 5,
          ),
          Text(AppStrings.appName),
        ],
      ),
      actions: [],
    );
}

}

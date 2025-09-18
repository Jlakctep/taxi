import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Имя'),
            subtitle: Text('Пассажир'),
            leading: Icon(Icons.person_outline),
          ),
          ListTile(
            title: Text('Телефон'),
            subtitle: Text('+380 00 000 00 00'),
            leading: Icon(Icons.phone_outlined),
          ),
          ListTile(
            title: Text('Оплата'),
            subtitle: Text('Наличные / Карта'),
            leading: Icon(Icons.credit_card),
          ),
        ],
      ),
    );
  }
}



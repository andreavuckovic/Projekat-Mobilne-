import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
 
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Emulator")),
      body: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Hello World', 
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ), 
          
          ElevatedButton(
            onPressed: () { 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Radi!"))
              );
            }, 
            child: const Text("Klikni"),
          ),
        ],           
      ),
    );
  }
}

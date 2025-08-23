import 'package:flutter/material.dart';

class PrashnaScreen extends StatelessWidget {
  const PrashnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jamakkol")),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            "Jamakkol Chart",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: const Center(
                  child: Text("Jamakkol Chart will load here"),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(label: const Text("English"), selected: true),
              const SizedBox(width: 12),
              ChoiceChip(label: const Text("தமிழ்"), selected: false),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text("Share Chart"),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text("Save Chart"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

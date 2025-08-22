import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 46, 16, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'We made Finding Memes Easy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search for memes [name, tags, ...]',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: () {}, child: const Text('Search')),
              SearchCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchCard extends StatelessWidget {
  const SearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 89, 139, 219),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(
        height: 200,
        width: double.infinity,
        child: Text('Search Card'),
      ),
    );
  }
}

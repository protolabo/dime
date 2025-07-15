import 'package:flutter/material.dart';

class CreateItemPage extends StatelessWidget {
  const CreateItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1DC),
      appBar: AppBar(
        title: const Text(
          "Create a new item",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFDF1DC),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker mockup
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("picture item", style: TextStyle(fontSize: 10)),
                      Icon(Icons.photo_camera, size: 18),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Name of the item",
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.amber[100],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Price section (improved)
            const Text("Price", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: "Enter price (e.g. 9.99)",
                hintStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.amber[100],
                border: const OutlineInputBorder(),
                suffixText: "\$",
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const Text("Description", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 7,
              decoration: InputDecoration(
                hintText: "Enter description...",
                hintStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.amber[100],
                border: const OutlineInputBorder(),
              ),
            ),
            const Spacer(),

            // Save Button
            Center(
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // TODO: action de sauvegarde
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

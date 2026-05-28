// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../state/game_state.dart';
//
// class InventoryOverlay extends StatelessWidget {
//   const InventoryOverlay({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final state = context.watch<GameState>();
//
//     return Container(
//       color: Colors.black.withOpacity(0.8),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           const Text("ИНВЕНТАРЬ", style: TextStyle(color: Colors.white, fontSize: 24)),
//           const SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 5, childAspectRatio: 1, crossAxisSpacing: 10, mainAxisSpacing: 10),
//               itemCount: 20, // Количество слотов
//               itemBuilder: (context, index) {
//                 // Здесь логика отображения предметов (заглушка)
//                 return Container(
//                   decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
//                   child: const Icon(Icons.inventory, color: Colors.white24),
//                 );
//               },
//             ),
//           ),
//           ElevatedButton(onPressed: () => state.toggleInventory(), child: const Text("Закрыть")),
//         ],
//       ),
//     );
//   }
// }
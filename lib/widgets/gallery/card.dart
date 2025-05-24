// import 'dart:developer';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
//
// class GalleryCard extends StatelessWidget {
//   final Uint8List image;
//
//   const GalleryCard({super.key, required this.image});
//
//   @override
//   Widget build(BuildContext context) {
//     final imageWidget = ImageLoader(
//       imagePath: product.productImagePath,
//       height: 190,
//       width: 160,
//     );
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(12.0),
//         child: Column(
//           spacing: 2,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             /// Para darle acciones al tocar la foto, un toque, o pulsación larga.
//             GestureDetector(
//               onTap: () => log('Clicked ${product.productName}'),
//               child: imageWidget,
//             ),
//             Text(
//               textAlign: TextAlign.center,
//               '\$${product.price.toString()}',
//               maxLines: 1,
//               style: Theme.of(context).textTheme.labelLarge,
//               overflow: TextOverflow.ellipsis,
//               softWrap: true,
//             ),
//             Text(
//               product.productName,
//               style: Theme.of(context).textTheme.labelMedium,
//               softWrap: true,
//               maxLines: 1,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 PeekButton(imageWidget: imageWidget),
//                 SimplifiedAddToCart(product: product),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

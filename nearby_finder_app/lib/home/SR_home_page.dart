// import 'package:flutter/material.dart';
// import 'package:nearby_finder_app/detail/detail_page.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         //
//       },
//       child: Scaffold(
//         backgroundColor: Colors.grey[300],
//         //
//         appBar: AppBar(
//           title: Text('title'),

//           // TextField(

//           //   //

//           // ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '최근 글',
//                 style: TextStyle(
//                   //
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               SizedBox(height: 20),
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: 10,
//                   separatorBuilder: (context, index) => SizedBox(
//                     height: 10,
//                   ),
//                   itemBuilder: (context, index) {
//                     return post();
//                   },
//                 ),
//               ),
//             ],
//             //
//           ),
//         ),
//       ),
//     );
//   }
// }

// Widget post() {
//   return Builder(
//     builder: (context) {
//       return GestureDetector(
//         onTap: () {
//           //
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) {
//                 return DetailPage();
//               },
//             ),
//           );
//         },
//         child: SizedBox(
//           width: double.infinity,
//           height: 120,
//           // color: Colors.blue,
//           child: Stack(
//             //
//             children: [
//               Positioned(
//                 right: 0,
//                 width: 140,
//                 height: 120,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Image.network(
//                     'https://picsum.photos/200/300',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 margin: EdgeInsets.only(right: 100),

//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     //
//                     children: [
//                       Text(
//                         '뿌뿌1',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                       Text(
//                         '뿌뿌2' * 15,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         '뿌뿌3' * 5,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:nearby_finder_app/write/write_page.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          iconButton(Icons.delete, () {}),
          iconButton(Icons.edit, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return WritePage();
                },
              ),
            );
          }),
        ],
        title: Text('detail입니당'),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 500),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.network(
              'https://picsum.photos/200/200',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '제목',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  '작성자',
                  style: TextStyle(fontSize: 16),
                ),

                Text(
                  '날짜',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 14,
                ),

                Text(
                  '내용' * 19,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget iconButton(IconData icon, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        color: Colors.transparent,
        child: Icon(icon),
      ),
    );
  }
}

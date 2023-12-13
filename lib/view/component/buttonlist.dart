import 'package:flutter/material.dart';

class ButtonList extends StatelessWidget {
  const ButtonList({
    this.onTap,
    required this.title,
    required this.deskripsi,
    required this.imagePath,
    super.key,
  });

  final String title;
  final String deskripsi;
  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue,
      borderRadius: BorderRadius.circular(15.0),
      onTap: onTap,
      child: Ink(
        height: 100,
        decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green)
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20)),
                    Text(deskripsi,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                decoration: BoxDecoration(
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/images/$imagePath.png"
                        ),
                      fit: BoxFit.cover
                    ),
                    border: Border.all(color: Colors.black)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
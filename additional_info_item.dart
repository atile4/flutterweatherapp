import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value
  });
  

  @override
  Widget build (BuildContext context) {
    return Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(icon, size: 48,),
                        SizedBox(height: 8,),
                        Text(label, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8,),
                        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)

                      ],                      
                    ),
                  );
  }
}

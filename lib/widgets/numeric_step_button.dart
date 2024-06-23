import 'package:flutter/material.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final int initialValue;  // Add an initial value parameter

  const NumericStepButton({
    required Key key,
    this.minValue = 0,
    this.maxValue = 10,
    required this.onChanged,
    this.initialValue = 1,  // Default initial value
  }) : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  late int counter;  // Declare counter as a late variable
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    counter = widget.initialValue;  // Initialize counter with initial value
    _isMounted = true;
  }

  @override
  void dispose(){
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(
            Icons.remove,
            color: Colors.blue,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
          iconSize: 32.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            if(_isMounted){
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                  widget.onChanged(counter);  // Call onChanged with the updated value
                }
              });
            }
            
          },
        ),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.add,
            color: Colors.blue,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
          iconSize: 32.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            if(_isMounted){
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                  widget.onChanged(counter);  // Call onChanged with the updated value
                }
              });
            }
            
          },
        ),
      ],
    );
  }
}

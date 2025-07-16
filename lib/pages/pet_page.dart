import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PetPage extends StatelessWidget {
  const PetPage({super.key});

  final double coverHeight = 280;
  final double profileHeight = 140;
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[    
          _buildTop(context),
          _buildContent()
      ]),
    );
  }

  Widget _buildContent() {
    return Container(
      child: Text('test'),
      alignment: Alignment.center,
    );
  }

  Stack _buildTop(context) {
    final top = coverHeight - profileHeight /2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        
        BuildCoverImage(),
        Positioned(
          top:40,
          left:15,
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                border: Border.all(),
                shape: BoxShape.circle
              ),
              child: SvgPicture.asset(
                  'assets/images/Arrow - Left 2.svg',
                  height: 20,
                  width: 20,
                  ),
            ),
          ),
        ),
        Positioned(
          top: top-10,
          right: top+20,
          child: BuildProfileImage()),
      ],
    );
  }

  Widget BuildCoverImage() => Container(
    color: Colors.white,
    child: Image.asset('assets/images/cat1.jpeg',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    )
  );

  Widget BuildProfileImage() => Container(
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
      child: CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.black,
        backgroundImage: AssetImage('assets/images/dog1.jpeg'),
      ),
  );
}
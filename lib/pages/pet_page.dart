import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paws/model/animal_model.dart';

class PetPage extends StatelessWidget {
  final Animal animal;

  const PetPage({Key? key, required this.animal}) : super(key: key);

  final double coverHeight = 280;
  final double profileHeight = 140;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/Arrow - Left 2.svg',
            height: 20,
            width: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BuildCoverImage(),
          BuildProfileImage(),
          const SizedBox(height: 20),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        animal.name,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget BuildCoverImage() => Container(
        color: Colors.white,
        child: Image.asset(
          animal.imageCover,
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
        ),
      );

  Widget BuildProfileImage() => Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: profileHeight / 2),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: profileHeight / 2,
            backgroundColor: Colors.black,
            backgroundImage: AssetImage(animal.imagePicture),
          ),
        ),
      );
}

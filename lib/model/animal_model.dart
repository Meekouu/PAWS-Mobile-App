class Animal{
   String petID;
   String name;
   String breed;
   String type;
   String birthday;
   String sex;
   String imageCover;
   String imagePicture;
   String petImagePath; // legacy local path or asset path
   String petImageUrl;  // new: Firestore/Storage URL

  Animal({
    required this.petID,
    this.name = 'Unknown',
    this.breed = 'Unknown',
    this.type = 'Unknown',
    this.sex = 'Unknown',
    this.birthday = 'Unknown',
    this.imageCover = 'assets/images/dog1.jpeg',
    this.imagePicture = 'assets/images/cat1.jpeg',
    this.petImagePath = '',
    this.petImageUrl = '',
    });

  factory Animal.fromMap(String petId, Map<dynamic, dynamic> map) {
    return Animal(
      petID: petId,
      name: map['petName'] ?? 'Unknown',
      breed: map['petBreed'] ?? 'Unknown',
      type: map['petType'] ?? 'Unknown',
      birthday: map['petBirthday'] ?? 'Unknown',
      sex: map['petSex'] ?? 'Unknown',
      imageCover: 'assets/images/dog1.jpeg',
      imagePicture: 'assets/images/cat1.jpeg',
      petImagePath: map['petImagePath'] ?? '',
      petImageUrl: map['petImageUrl'] ?? '',
    );
  }
}
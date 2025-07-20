class Animal{
  final String petID;
  final String name;
  final String breed;
  final String type;
  final String birthday;
  final String sex;
  final String imageCover;
  final String imagePicture;
  final String petImagePath;

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
    );
  }
}
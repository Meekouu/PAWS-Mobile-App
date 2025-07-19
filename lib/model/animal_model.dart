class Animal{
  final String name;
  final String breed;
  final String type;
  final String birthday;
  final String imageCover;
  final String imagePicture;

  Animal({
    this.name = 'Unknown',
    this.breed = 'Unknown',
    this.type = 'Unknown',
    this.birthday = 'Unknown',
    this.imageCover = 'assets/images/dog1.jpeg',
    this.imagePicture = 'assets/images/cat1.jpeg',
    });

  static List<Animal> getAnimal(){
    List<Animal> animal = [];

    animal.add(
      Animal(
        name: 'Cat',
        breed: 'Cet',
        imageCover: 'assets/images/dog1.jpeg',
        imagePicture: 'assets/images/cat1.jpeg'
      )
    );

    animal.add(
      Animal(
        name: 'Dog',
        breed: 'Barks',
        imageCover: 'assets/images/cat1.jpeg',
        imagePicture: 'assets/images/dog1.jpeg'
      )
    );

    return animal;
  }
}
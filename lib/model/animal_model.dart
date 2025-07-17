class Animal{
  final String name;
  final String species;
  final String imageCover;
  final String imagePicture;

  Animal({
    required this.name, 
    required this.species, 
    required this.imageCover,
    required this.imagePicture,
    });

  static List<Animal> getAnimal(){
    List<Animal> animal = [];

    animal.add(
      Animal(
        name: 'Cat',
        species: 'Cet',
        imageCover: 'assets/images/dog1.jpeg',
        imagePicture: 'assets/images/cat1.jpeg'
      )
    );

    animal.add(
      Animal(
        name: 'Dog',
        species: 'Barks',
        imageCover: 'assets/images/cat1.jpeg',
        imagePicture: 'assets/images/dog1.jpeg'
      )
    );

    return animal;
  }
}
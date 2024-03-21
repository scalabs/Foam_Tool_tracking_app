# Foam_Tool_Tracking_App

This Flutter app is a tool tracking system designed to manage and monitor various tools within a specific context. Users can view, add, modify, and delete tool entries through a user-friendly interface. The app fetches data from an API, allowing real-time updates and interactions with the database. It features filtering options to streamline tool visualization based on criteria such as cleanliness and calibration status. Additionally, users can perform actions like adding new tools or updating tool statuses, all with the convenience of intuitive UI elements.


How to Start using it locally:

1.Adjust the api python file to your needs
2.Start the api
3.In tabs change the url to your api 
Example:
In Tool_Overview.dart
On line:
37:
  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('http://10.3.41.36:7000/api/active'), //Change to your url
      headers: {'Content-Type': 'application/json'},
    );
4.Flutter pub get (Fetch dependencies)
5.Flutter run (Open the app)



More tricks and tips:


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

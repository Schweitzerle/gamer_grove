import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class AppTokenService {
  static final String clientId = 'lbesf37nfwly4czho4wp8vqbzhexu8';
  static final String clientSecret = 's6xa3psvwt8sroq2ox8k5r7972a1ka';
  static final String firebaseUrl = 'https://gamegrove-e25ff-default-rtdb.europe-west1.firebasedatabase.app/';
  static String token = '';
  static DateTime? expirationDate;

  static Future<void> getAppToken() async {
    Future<void> getNewToken() async {
      final response = await http.post(
        Uri.parse('https://id.twitch.tv/oauth2/token'
            '?client_id=$clientId'
            '&client_secret=$clientSecret'
            '&grant_type=client_credentials'),
        body: null,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['access_token'];
        final expiresIn = data['expires_in'];

        expirationDate = DateTime.now().add(Duration(seconds: expiresIn));

        print('New token fetched');
        final firebaseRef = FirebaseDatabase.instance.ref(
            'admin'); // Adjust this accordingly
        await firebaseRef.set({
          'expirationDate': expirationDate?.toIso8601String(),
          'token': newToken,
        });
      } else {
        throw Exception('Failed to get a new token');
      }
    }

    Future<void> fetchTokenFromFirebase() async {
      try {
        final firebaseRef = FirebaseDatabase.instance.ref('admin');
        final snapshot = await firebaseRef.once();

        if (snapshot.snapshot.value != null) {
          final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
          final expirationDateString = data['expirationDate'];
          final firebaseToken = data['token'];

          if (firebaseToken != null && expirationDateString != null) {
            expirationDate = DateTime.parse(expirationDateString);
            if (expirationDate!.isBefore(DateTime.now())) {
              await getNewToken();
            } else {
              if (firebaseToken != null) {
                token = firebaseToken;  // Set the token variable here
              } else {
                throw Exception('Failed to get the app token');
              }
            }
          } else {
            // Token or expirationDate is null in Firebase, so generate a new one
            await getNewToken();
          }
        } else {
          await getNewToken();
        }
      } catch (err) {
        throw Exception('Failed to fetch the token from Firebase: $err');
      }
    }

    // Initial fetch at the app start
    await fetchTokenFromFirebase();
  }


}

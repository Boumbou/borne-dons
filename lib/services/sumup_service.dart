import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants.dart';
import 'storage_service.dart';

class SumupService {

  final http.Client _client;

  SumupService({http.Client? client}): _client = client ?? http.Client();



  Future<String?> pairSumupSolo(String merchantCode, String apiKey, String pairingCode) async{
    final url = Uri.parse('${AppConstants.sumupBaseUrl}/$merchantCode/readers');

    final response = await _client.post(
      url,
      headers:{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'pairing_code': pairingCode,
        'name': 'testPairingReader'
      })
    );

    if (response.statusCode == 201){
      final data = jsonDecode(response.body);
      return data['id'];
    } else{
      throw Exception('Impossible d\'enregistrer le terminal: ${response.body}');
    }
  }


  // TODO : add polling payment status
  Future<Map<String,dynamic>> startSoloCheckout ({ 
    required double amount,
    required StorageService storage,
    void Function(String message)? onStatusUpdate,}
    ) async{
    //fetch credentials
    final readerId = await storage.getSumupReaderId();
    final merchantCode = await storage.getSumupMerchantCode();
    final apiKey = await storage.getSumupApiKey();
    final appId = await storage.getSumupAppId();
    final afKey = await storage.getSumupAfKey();


    final url = Uri.parse('${AppConstants.sumupBaseUrl}/$merchantCode/readers/$readerId/checkout');
    int minorUnitAmunt = (amount * 100).toInt();
    try{

      onStatusUpdate?.call('Initialisation du paiement ($amount)...');

      //creates reader checkout
      final response = await _client.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'total_amount':{
            'minor_unit':2,
            'currency': 'EUR',
            'value': minorUnitAmunt
          },
          'affiliate':{
            'app_id': appId,
            'key': afKey
          },
          'description': 'Donation Kiosk'
        })
      );

      // stop process if not 201
      //catch reader activation error
      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Connexion au terminal échouée: ${errorBody['error']?['message'] ?? response.body}');
      }

      onStatusUpdate?.call('Terminal activé. Presentez votre carte...');

      // ----------------------------------------------------
      // STEP 3: Poll PaymentIntent Status
      // ----------------------------------------------------
      // poll the Stripe payment intent status every 2 seconds
      // until it transitions out of processing/requires_payment_method states.
      final int maxPollAttempts = 30; // 60 seconds timeout
      final String transactionId = jsonDecode(response.body)['data']['client_transaction_id'];
      for (int attempt = 0; attempt < maxPollAttempts; attempt++) {
        await Future.delayed(const Duration(seconds: 2));

        final checkUrl = Uri.https(
          'api.sumup.com','/v2.1/merchants/$merchantCode/transactions',{
            'client_transaction_id':transactionId
          }
        );
        
        final checkResponse = await _client.get(
          checkUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        );

        

        if (checkResponse.statusCode == 200) {
          final checkData = jsonDecode(checkResponse.body);
          final String status = checkData['status'];
          final String id = checkData['id'];
          onStatusUpdate?.call('Lecture de la carte en cours: Status "$status"...');

          if (status == 'SUCCESSFUL') {
            return {
              'success': true,
              'transaction_id': id,
              'message': 'Paiement autorisé et enregistré.',
              'amount': amount,
            };
          } else if (status == 'CANCELLED') {
            throw Exception('Paiement annulé par le terminal.');
          } else if (status == 'FAILED') {
            throw Exception('Tentative de paiement échouée');
          }
        } else {
          onStatusUpdate?.call('Status poll warning: HTTP ${checkResponse.statusCode}');
        }
      }


      throw Exception('Carte non présentée, paiement annulé.');
    }catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erreur lors de la transaction.',
      };
    }
    
  }
}

import 'package:bonako_demo/core/shared_models/user.dart';
import 'package:bonako_demo/features/addresses/enums/address_enums.dart';
import '../../api/repositories/api_repository.dart';
import '../../api/providers/api_provider.dart';
import 'package:http/http.dart' as http;
import './../models/address.dart';

class AddressRepository {

  /// The address does not exist until it is set.
  final Address? address;

  /// The Api Provider is provided to enable requests using the
  /// Bearer Token that has or has not been set
  final ApiProvider apiProvider;

  /// Constructor: Set the provided Address and Api Provider
  AddressRepository({ this.address, required this.apiProvider });

  /// Get the Api Repository required to make requests with the set Bearer Token
  ApiRepository get apiRepository => apiProvider.apiRepository;

  /// Update the specified address
  Future<http.Response> updateAddress({ AddressType? type, String? addressLine }){

    if(address == null) throw Exception('The address must be set to update address');

    String url =  address!.links.updateAddress.href;

    Map body = {};

    if(type != null) body['type'] = type.name;
    if(addressLine != null) body['addressLine'] = addressLine;

    return apiRepository.put(url: url, body: body);
    
  }

  /// Update the specified address
  Future<http.Response> deleteAddress({ AddressType? type, String? addressLine }){

    if(address == null) throw Exception('The address must be set to delete address');

    String url =  address!.links.deleteAddress.href;

    return apiRepository.delete(url: url);
    
  }

}
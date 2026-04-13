import 'dart:convert';
import 'package:http/http.dart' as http;

class IbgeLocalidadesService {
  final http.Client client;

  IbgeLocalidadesService(this.client);

  static const String _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades';

  Future<List<Map<String, dynamic>>> fetchStates() async {
    final uri = Uri.parse('$_baseUrl/estados?orderBy=nome');
    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar estados');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return {
        'id': item['id'],
        'sigla': item['sigla'],
        'nome': item['nome'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCitiesByUf(String uf) async {
    final uri = Uri.parse(
      '$_baseUrl/estados/$uf/municipios?orderBy=nome',
    );

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar cidades');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return {
        'id': item['id'],
        'nome': item['nome'],
      };
    }).toList();
  }
}
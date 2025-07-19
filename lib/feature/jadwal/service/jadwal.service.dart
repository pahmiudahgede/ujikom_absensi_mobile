import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/jadwal.model.dart';

abstract class JadwalService {
  Future<HolidayResponse> getHolidays({int? month, int? year});
  Future<HolidayResponse> getCurrentYearHolidays();
  Future<HolidayResponse> getMonthHolidays(int month, {int? year});
}

class JadwalServiceImpl implements JadwalService {
  static const String _baseUrl = 'https://api-harilibur.vercel.app';
  final http.Client _client;

  JadwalServiceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<HolidayResponse> getHolidays({int? month, int? year}) async {
    try {
      String endpoint = '/api';
      List<String> queryParams = [];

      if (month != null) {
        queryParams.add('month=$month');
      }
      if (year != null) {
        queryParams.add('year=$year');
      }

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw const SocketException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return HolidayResponse.fromJsonList(jsonData);
      } else {
        throw HttpException(
          'Failed to load holidays. Status code: ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<HolidayResponse> getCurrentYearHolidays() async {
    return await getHolidays();
  }

  @override
  Future<HolidayResponse> getMonthHolidays(int month, {int? year}) async {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }
    return await getHolidays(month: month, year: year);
  }

  void dispose() {
    _client.close();
  }
}
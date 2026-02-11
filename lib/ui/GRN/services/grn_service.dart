import '../models/grn_list_models.dart';
import '../constants/grn_list_constants.dart';

class GRNService {
  /// Fetch GRN data from API
  static Future<List<GRNRecordModel>> fetchGrnData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate API response
    final Map<String, dynamic> apiResponse = {
      "success": true,
      "message": "GRN data fetched successfully",
      "data": GRNListConstants.sampleApiData,
      "total": GRNListConstants.sampleApiData.length,
      "timestamp": DateTime.now().toIso8601String(),
    };

    if (apiResponse['success'] == true) {
      final List<dynamic> dataList = apiResponse['data'];
      return dataList.map((item) => GRNRecordModel.fromJson(item)).toList();
    } else {
      throw Exception(apiResponse['message'] ?? 'Failed to fetch data');
    }
  }

  /// Load mock data as fallback
  static List<GRNRecordModel> getMockData() {
    return GRNListConstants.sampleApiData
        .map((item) => GRNRecordModel.fromJson(item))
        .toList();
  }

  /// Format date to string
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

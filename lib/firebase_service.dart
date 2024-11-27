import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 특정 oil 이름으로 Firestore에서 색상 가져오기
  Future<Color?> getOilColor(String oilName) async {
    try {
      final snapshot = await _firestore.collection('oil').doc(oilName).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['color'] != null) {
          return Color(int.parse(data['color'])); // 색상을 반환
        }
      }
    } catch (e) {
      print("Error fetching color for oil $oilName: $e");
    }
    return null; // 색상을 찾지 못하면 null 반환
  }

  // 특정 oil의 데이터를 가져오기
  Future<Map<String, dynamic>?> getOilData(String oilName) async {
      try {
        final DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('oil') // oil 컬렉션
            .doc(oilName) // 특정 문서
            .get();

        if (snapshot.exists) {
          return snapshot.data() as Map<String, dynamic>;
        }
        return null;
      } catch (e) {
        print("Error fetching oil data for $oilName: $e");
        return null;
      }
    }
  /// 사용자 히스토리에 향 조합 추가
  Future<void> saveScentToUserHistory({
    required String userId,
    required Map<String, dynamic> scentData,
  }) async {
    try {
      // 지정된 사용자 문서 참조
      DocumentReference userRef = _firestore.collection('user_history').doc(userId);

      // maked_scent 필드에 리스트 형태로 새로운 조합 추가
      await userRef.update({
        'maked_scent': FieldValue.arrayUnion([
          {
            'name': scentData['name'],
            'oils': scentData['oils'],
            'percentages': scentData['percentages'],
            'created_at': Timestamp.now(), // 현재 시간 추가
          }
        ]),
      });
      print("Firestore에 저장할 데이터: ${scentData}");
    } catch (e) {
      // 문서가 없을 경우 생성 후 저장
      if (e is FirebaseException && e.code == 'not-found') {
        await _firestore.collection('user_history').doc(userId).set({
          'user_name': 'Unknown User', // 기본값 설정
          'maked_scent': [
            {
              'name': scentData['name'],
              'oils': scentData['oils'],
              'percentages': scentData['percentages'],
              'created_at': Timestamp.now(),
            }
          ],
        });
        print("User history document created and scent saved!");
      } else {
        print("Error saving scent to user history: $e");
      }
    }
  }

  /// 특정 사용자 히스토리 가져오기
  Future<Map<String, dynamic>> getUserHistory(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('user_history').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("No user history found for ID: $userId");
        return {};
      }
    } catch (e) {
      print("Error retrieving user history: $e");
      return {};
    }
  }
}

class GeminiParser {
  /// Gemini 응답을 파싱하여 name, oils, percentages 추출
  static Map<String, dynamic> parseResponse(String response) {
    // 정규식으로 데이터 추출
    RegExp nameRegex = RegExp(r"name:\s*(.+)");
    RegExp oilsRegex = RegExp(r"oils:\s*(.+)");
    RegExp percentagesRegex = RegExp(r"percentage:\s*(.+)");

    String recipeName = nameRegex.firstMatch(response)?.group(1)?.trim() ?? "Unknown";
    List<String> oils = oilsRegex
            .firstMatch(response)
            ?.group(1)
            ?.split(', ')
            .map((oil) => oil.trim())
            .toList() ??
        [];
    List<int> percentages = percentagesRegex
            .firstMatch(response)
            ?.group(1)
            ?.split(', ')
            .map((percentage) => int.parse(percentage.replaceAll('%', '').trim()))
            .toList() ??
        [];
    print("향 이름: $recipeName");
    print("오일: $oils");
    print("퍼센티지: $percentages");

    return {
      'name': recipeName,
      'oils': oils,
      'percentages': percentages,
    };
  }
}

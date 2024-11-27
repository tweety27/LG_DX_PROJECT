import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRecipes {
  // Firestore에서 scent_recipe 컬렉션 데이터를 읽는 함수
  Future<List<Map<String, dynamic>>> fetchScentRecipes() async {
    List<Map<String, dynamic>> recipes = [];
    try {
      // scent_recipe 컬렉션 가져오기
      final querySnapshot =
          await FirebaseFirestore.instance.collection('scent_recipe').get();
      for (var doc in querySnapshot.docs) {
        recipes.add(doc.data()); // 각 문서를 리스트에 추가
      }
    } catch (e) {
      print("Error fetching scent recipes: $e");
    }
    return recipes;
  }
}

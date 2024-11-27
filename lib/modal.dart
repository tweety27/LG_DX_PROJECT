import 'package:flutter/material.dart';
import 'secondmodal.dart';

class Modal extends StatelessWidget {
  final String content; // 모달창의 내용
  final VoidCallback onClose; // 닫기 버튼 동작
  final List<Map<String, dynamic>> scents; // 향료 데이터 받아오기

  // 향료 데이터를 리스트로 선언
  // final List<Map<String, dynamic>> scents = [
  //   {'name': '로즈마리', 'color': Color(0xffFF7570)},
  //   {'name': '파출리', 'color': Color(0xffAA9C80)},
  //   {'name': '시더우드', 'color': Color(0xffC8BC9C)},
  //   {'name': '라벤더', 'color': Color(0xffF596FF)},
  // ];

  Modal({
    Key? key,
    required this.content,
    required this.onClose,
    required this.scents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22), // 둥근 모서리
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 뒤로가기 버튼 (모달 상단)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(); // 모달 닫기
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 텍스트 내용
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 향료 목록 표시
                Wrap(
                  spacing: 12, // 가로 간격
                  runSpacing: 12, // 세로 간격
                  alignment: WrapAlignment.center,
                  children: scents.map((scent) {
                    return _buildScentItem(scent['name'], scent['color']);
                  }).toList(),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 현재 모달 닫기
                    _showSecondModal(context); // 두 번째 모달 열기
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(202, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xffEFF0F4),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Text(
                      "확인",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 두 번째 모달 창 띄우기
  void _showSecondModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SecondModal(), // 두 번째 모달 호출
    );
  }

  // 향료 아이템 빌드
  Widget _buildScentItem(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffEFF0F4), // 배경색
        borderRadius: BorderRadius.circular(20), // 둥근 모서리
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color, // 동그란 아이콘 색상
              shape: BoxShape.circle, // 동그란 모양
            ),
          ),
          const SizedBox(width: 8), // 간격
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

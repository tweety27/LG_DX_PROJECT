import 'package:flutter/material.dart';
import 'package:soom/soom.dart';

class SecondModal extends StatefulWidget {
  const SecondModal({Key? key}) : super(key: key);

  @override
  _SecondModalState createState() => _SecondModalState();
}

class _SecondModalState extends State<SecondModal> {
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
                const EdgeInsets.only(top: 0, bottom: 30, left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // gif 이미지
                Image.asset(
                  'assets/img/perfuming.GIF',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),

                // 텍스트 내용
                const Text(
                  "조향이 완료되면\n알람을 보내드릴게요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 0),

                // 확인 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 현재 모달 닫기
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SoomPage(),
                      ),
                    );
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
                  child: const Text(
                    "확인",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

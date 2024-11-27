import 'package:soom/firebase_service.dart';
import 'package:soom/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'modal.dart';
import 'firebase_recipes.dart';

class ChatGptApp extends StatefulWidget {
  ChatGptApp({super.key});

  @override
  State<ChatGptApp> createState() => _ChatGptAppState();
}

class _ChatGptAppState extends State<ChatGptApp> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _canSendMessage = false;
  ChatRoom _room = ChatRoom(chats: [], createdAt: DateTime.now());
  bool _isLoading = false;
  bool _isButtonDisabled = false; // 예 아니오 버튼 비활성화
  final FirebaseRecipes _firebaseRecipes = FirebaseRecipes(); // FirebaseService 인스턴스 생성
  final FirebaseService _firebaseService = FirebaseService();
  String _userId = 'user_1';

  @override
  void initState() {
    super.initState();
    Gemini.init(
        apiKey: "AIzaSyAaeypz83jbE3iImpjmmaxA_OrF0v9rk2c"); // 실제 API 키 입력

    // 앱이 시작될 때 첫 번째 질문 자동 전송
    _sendInitialMessage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // 뒤로가기 아이콘
            color: Colors.black, // 아이콘 색상
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "Chat Soom",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // 배경 이미지 설정
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/img/Chat ThinQ.png"), // 이미지 경로
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(top: 120, bottom: 80),
              child: Column(
                children: [
                  for (var chat in _room.chats)
                    chat.isMe
                        ? _buildMyChatBubble(chat)
                        : _buildGptChatBubble(chat),
                  if (_isLoading) _buildLoadingBubble(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey[100], // 하얀색 배경 추가
                padding: const EdgeInsets.only(
                    top: 0.0, bottom: 30.0), // 위, 아래 간격 설정
                child: _buildTextField(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGptChatBubble(ChatMessage chat) {
    final bool isInitialMessage = chat.text == "은호님, 오늘 만들고 싶은 향이 있으신가요?";
    final List<String> keywords = [
      "추천드린 향",
      "추천하는 향",
      "오늘의 추천",
      "op",
      "탑",
      "노트",
      "추천드립니다",
      "추천합니다",
      "추천해드립니다",
      "오일",
      "비율",
      "%",
      "레시피"
    ];
    final bool isRecommendationMessage =
        keywords.any((keyword) => chat.text.contains(keyword));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 20, top: 5),
          child: Image.asset(
            "assets/img/ChatSoomMark.png",
            width: 20,
            height: 20,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 300),
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.text,
                  style: TextStyle(
                      fontFamily: 'Pretendard', // Pretendard 글씨체 적용
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                if (isInitialMessage) ...[
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(90, 40),
                        ),
                        onPressed: _isButtonDisabled
                            ? null
                            : () => _handleYesNoResponse("예"),
                        child: Text(
                          "예",
                          style: TextStyle(
                            fontFamily: 'Pretendard', // Pretendard 글씨체 적용
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(90, 40),
                        ),
                        onPressed: _isButtonDisabled
                            ? null
                            : () => _handleYesNoResponse("아니오"),
                        child: Text(
                          "아니오",
                          style: TextStyle(
                            fontFamily: 'Pretendard', // Pretendard 글씨체 적용
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isRecommendationMessage) ...[
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(110, 40),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => _showCustomModal(
                          context,
                          "스마트 센트 제품에\n해당 향료를 넣어주세요!",
                        ),
                        child: Text(
                          "조향하기",
                          style: TextStyle(
                            fontFamily: 'Pretendard', // Pretendard 글씨체 적용
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(110, 40),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => _showCustomModal(
                          context,
                          "스마트 센트 제품에\n해당 향료를 넣어주세요!",
                        ),
                        child: Text(
                          "시향하기",
                          style: TextStyle(
                            fontFamily: 'Pretendard', // Pretendard 글씨체 적용
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 예/아니오 버튼 클릭 시 처리 함수
  void _handleYesNoResponse(String response) {
    setState(() {
      // 버튼 비활성화
      _isButtonDisabled = true;

      // 사용자의 응답 추가
      _room.chats.add(ChatMessage(
        isMe: true,
        text: response,
        sentAt: DateTime.now(),
      ));
    });

    // 일정 시간 후 후속 질문 추가
    Future.delayed(Duration(seconds: 1), () {
      if (response == "예") {
        setState(() {
          _room.chats.add(ChatMessage(
            isMe: false,
            text: "무슨 향을 만들고 싶은지 자유롭게 말씀해주세요!",
            sentAt: DateTime.now(),
          ));
        });
      } else if (response == "아니오") {
        setState(() {
          _room.chats.add(ChatMessage(
            isMe: false,
            text: "알겠습니다. 그럼 오늘은 은호님의 기분을 토대로 향을 추천해드릴게요. 오늘 기분이 어떠신가요?",
            sentAt: DateTime.now(),
          ));
        });
      }
    });
  }

  Widget _buildMyChatBubble(ChatMessage chat) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 250),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          chat.text,
          style: TextStyle(
              fontFamily: 'Pretandard',
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 250),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              "응답 대기 중...",
              style: TextStyle(
                  fontFamily: 'Pretandard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onSubmitted: (text) {
          if (text.trim().isNotEmpty) {
            _sendMessage(); // 메세지 전송
          }
        },
        onChanged: (text) {
          setState(() {
            _canSendMessage = text.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: "메시지를 입력하세요",
          hintStyle: TextStyle(
            fontFamily: 'Pretendard', // 폰트 지정
            fontSize: 16, // 폰트 크기
            fontWeight: FontWeight.w500, // 폰트 두께
            color: Color(0xFF8b95a1), // 텍스트 색상
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              vertical: 16, horizontal: 16), // 텍스트의 상하 간격 조정
          alignLabelWithHint: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 균일 간격
            child: GestureDetector(
              onTap: () {
                print("Mic icon tapped"); // 마이크 아이콘 클릭 시 동작
              },
              child: Image.asset(
                'assets/img/mic_icon.png', // 마이크 아이콘 경로
                width: 24, // 아이콘 너비
                height: 24, // 아이콘 높이
              ),
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 균일 간격
            child: IconButton(
              icon: Icon(
                Icons.send,
                size: 20, // 아이콘 크기 조정
                color: _canSendMessage ? Color(0xFF626A7D) : Color(0xFF626A7D),
              ),
              onPressed: _canSendMessage
                  ? () {
                      _sendMessage();
                    }
                  : null,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          height: 1.5, // 텍스트와 아이콘이 정렬되도록 줄 간격 설정
        ),
        maxLines: null,
        keyboardType: TextInputType.text,
      ),
    );
  }

  // 메시지 전송 함수
  void _sendMessage() async {
    _focusNode.unfocus();

    if (_controller.text.trim().isEmpty) {
      return;
    }

    final ChatMessage chat = ChatMessage(
      isMe: true,
      text: _controller.text.trim(),
      sentAt: DateTime.now(),
    );

    setState(() {
      _room.chats.add(chat);
      _canSendMessage = false;
      _isLoading = true;
    });

    // Firebase 데이터 가져오기
    List<Map<String, dynamic>> recipes = await _firebaseRecipes.fetchScentRecipes();

    // Firebase 데이터 기반의 메시지 생성
    String firebaseData = recipes.map((recipe) {
      return "Name: ${recipe['name']}, Oils: ${recipe['oils']}, Percentages: ${recipe['percentage']}";
    }).join("\n");

    String question = "${_controller.text}\nAvailable Recipes:\n$firebaseData\n사용자가 만들고 싶은 향에 대한 반응이나 기분에 대한 공감 반응을 먼저 출력하고 어울리는 레시피를 두번째 줄에서 하나만 찾아서 향의 이름, percentage를 포함한 레시피를 출력해줘\n응답 형식 예시는 오늘은 기분이 좋으시군요!\n여기에 어울리는 향을 추천해드릴게요.\nname: Lemon\noils: 레몬그라스, 클라리세이지, 라벤더\npercentage: 15%, 40%, 45%";

    // Gemini 호출
    Gemini.instance.streamGenerateContent(question).listen((event) {
      print(event.output);
      setState(() {
        if (_room.chats.last.isMe == false) {
          _room.chats.last.text += (event.output ?? "");
        } else {
          _room.chats.add(ChatMessage(
            isMe: false,
            text: event.output ?? "",
            sentAt: DateTime.now(),
          ));
        }
        _isLoading = false;
      });
    }).onError((error) {
      setState(() {
        _room.chats.add(ChatMessage(
          isMe: false,
          text: "응답을 가져오는 데 실패했습니다. 다시 시도해 주세요.",
          sentAt: DateTime.now(),
        ));
        _isLoading = false;
      });
    });

    _controller.clear();
  }


  // 첫 번째 질문 보내기
  void _sendInitialMessage() {
    String initialMessage = "은호님, 오늘 만들고 싶은 향이 있으신가요?";

    setState(() {
      _room.chats.add(ChatMessage(
        isMe: false,
        text: initialMessage,
        sentAt: DateTime.now(),
      ));
    });
  }

  void _handleCustomAction(String action) async {
    setState(() {
      // 사용자가 선택한 액션을 추가
      _room.chats.add(ChatMessage(
        isMe: true,
        text: action,
        sentAt: DateTime.now(),
      ));
    });

    // 마지막 gemini 응답 가져오기
    String lastGeminiResponse = _room.chats.lastWhere((chat) => !chat.isMe).text;

    // Gemini 응답 파싱하여 데이터 추출
    Map<String, dynamic> parsedResponse = GeminiParser.parseResponse(lastGeminiResponse);

    try {
      // Firestore에 데이터 저장
      await _firebaseService.saveScentToUserHistory(
        userId: _userId, // 현재 사용자 ID
        scentData: parsedResponse, // 파싱된 데이터
      );
    } catch (e) {
      print("Error saving scent to Firestore: $e");
    }

    // 조향하기/시향하기에 따른 추가 로직
    Future.delayed(Duration(seconds: 1), () {
      if (action == "조향하기") {
        setState(() {
          _room.chats.add(ChatMessage(
            isMe: false,
            text: "조향을 시작합니다! 원하는 향의 톱 노트를 알려주세요.",
            sentAt: DateTime.now(),
          ));
        });
      } else if (action == "시향하기") {
        setState(() {
          _room.chats.add(ChatMessage(
            isMe: false,
            text: "시향을 시작합니다! 오늘의 추천 향을 준비 중입니다.",
            sentAt: DateTime.now(),
          ));
        });
      }
    });
  }

// 모달창 호출 함수
void _showCustomModal(BuildContext context, String content) async {
  // Gemini 응답에서 oils 추출
  String lastGptResponse = _room.chats.lastWhere((chat) => !chat.isMe).text;
  Map<String, dynamic> parsedResponse = GeminiParser.parseResponse(lastGptResponse);
  List<String> oils = parsedResponse['oils']; // oils 이름만 리스트로 추출

  // Firestore에서 각 oil의 색상 가져오기
  List<Map<String, dynamic>> scents = [];
  for (String oil in oils) {
    Color? color = await _firebaseService.getOilColor(oil); // Firestore에서 색상 가져오기
    if (color != null) {
      scents.add({'name': oil, 'color': color});
    } else {
      scents.add({'name': oil, 'color': Colors.grey}); // 색상을 찾지 못한 경우 기본값
    }
  }

  // 모달 호출
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Modal(
        content: content,
        scents: scents, // 동적으로 전달된 향료 데이터
        onClose: () {
          Navigator.of(context).pop(); // 모달창 닫기
        },
      );
    },
  );
}


// Firebase 에서 향료 색상 가져오기
Color _getOilColor(String oilName) {
  // Firestore에서 데이터를 가져오는 비동기 로직을 여기에 추가
  // 예시: {'로즈마리': Color(0xffFF7570)}와 같은 색상 매핑 사용
  return Color(0xffEFF0F4); // 기본 색상 반환
}
}

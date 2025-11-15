

bool isLoggedIn = false;
late UserData loginUser;

class UserData{
  String userId = "";          //학습자 아이디
  String authCode = "";    //학습자 식별번호
}

class StudyTogetherData{
  String studyTogetherName = "";          //스터디 이름
  String studyTogetherTarget = "";        //
  String dayOfWeek = "";                     // 0:월, 1:화, 2:수, 3:목, 4:금, 5:토, 6:일
  String startTime = "";                  // "HH:MM"
  String endTime = "";                    // "HH:MM"
  String studyTogetherRequirements = "";  //스터디 요구사항
  String studyTogetherLocation = "";      //스터디 장소

  String toLineStrint(){
    return '스터디 이름: $studyTogetherName, 공부할 부분 : $studyTogetherTarget, 매주 참여 요일 : $dayOfWeek, 시작시간 : $startTime 끝나는 시간 : $endTime, 스터디 요구 사항 : $studyTogetherRequirements, 스터디 장소 : $studyTogetherLocation';
  }
}
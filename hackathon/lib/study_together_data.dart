

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
}
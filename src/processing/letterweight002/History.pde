static class History {
  static History DEFAULT = new History();
  char letter; // Keep the history?
  int visits = 0;
  int time = 0;
  int score = 0;
  
  String toString() {
    return "letter=" + letter 
      + ", visits=" + visits
      + ", time=" + time
      + ", score=" + score;
  }
}



// Basic text evaluator.
// Steady tempo. Get the average while calculating.
// Repetition.

// More uppercase than lower?
// Exclamation marks
// many none alpha, [a-zA-Z]

class Evaluator {

  History history[];
  int prevTime;
  String text;

  Evaluator(int size) {
    history = new History[size];
    prevTime = millis();
    text = "";
  }

  String getText() {
    //return text;
    StringBuilder sb = new StringBuilder();
    for (History h : history) {
      if (h != null) {
        sb.append(h.letter);
      }
    }
    return sb.toString();
  }

  History getHistory(int position) {
    History h = history[position];
    if (h == null) {
      h = History.DEFAULT;
    }
    return h;
  }

  int calculateWeight() {
    int total = 0;
    int score;
    for (int i = 0; i < history.length; i++) {
      score = 0;
      if (history[i] != null) {
        score = history[i].score;
      }
      total += score;
    }
    return total / 1000;
  }

  void process(char key) {
    if (text.length() < history.length) {
      if (key != CODED) {
        if (key != BACKSPACE) {
          text += key;    
  
          int position = text.length() - 1;
          int now = millis();
          History h = history[position];
          if (h == null) {
            h = new History();
          }
 
          h.letter = key; 
          h.time = now - prevTime;
          h.visits++;
          //h.score = constrain(int(((h.score/0.7 + h.time) * (h.visits * 0.2))), 0, 20000);
          h.score += int(h.time + (h.visits * 1.5));
  
          history[position] = h;
  
          //history[text.length() - 1] = millis() - prevTime;
          prevTime = millis();
  
          println(history[position]);
        }
      }
    }

    // This enough for all?
    if (text.length() > 0) {
      if (key == BACKSPACE) {        
        // TODO: Store a value per cell and calculate the value for that.
        // We can then break it down to detect spots within a message that
        // has been edited over and over again.
        int position = text.length() - 1;
        History h = history[position];
        h.score *= 1.5;
        h.letter = '\0'; 
        //prevTime -= map[text.length() - 1].time * 1.02;
        text = text.substring(0, position);
  
        //println("edit: " + history[position]);
      }
    }
  }

  String toJson() {
    JSONObject rootJson = new JSONObject();
    rootJson.setString("text", text);
    return rootJson.toString();
  }
  
  String toHistoryJson() {
    JSONArray historyJsonArray = new JSONArray(); 

    int i = 0;
    for (History h : history) {
      if (h != null) {
        JSONObject historyJson = new JSONObject();
        historyJson.setInt("visits", h.visits);
        historyJson.setInt("time", h.time);
        historyJson.setInt("score", h.score);
        historyJson.setString("letter", String.valueOf(h.letter));
        historyJsonArray.setObject(i, historyJson);        
      }

      i++;
    }
    return historyJsonArray.toString();
  }
}


//Pins definition
const int button1 = 2;
const int button2 = 3;
const int resetBtn = 4;

const int lamp1 = 5;
const int lamp2 = 6;

bool gameOver = false;

void setup() {
  Serial.begin(9600);

  pinMode(button1, INPUT);
  pinMode(button2, INPUT);
  pinMode(resetBtn, INPUT);

  pinMode(lamp1, OUTPUT);
  pinMode(lamp2, OUTPUT);

  resetSystem(); // Start
}

void loop() {
  if (!gameOver) {
    // switch reading
    int state1 = digitalRead(button1);
    int state2 = digitalRead(button2);

    if (state1 == HIGH) {
      triggerWinner(1);
    } 
    else if (state2 == HIGH) {
      triggerWinner(2);
    }
  }

  // Switch reading
  if (digitalRead(resetBtn) == HIGH || (Serial.available() && Serial.read() == 'r'))
  {
    resetSystem();
  }
}

void triggerWinner(int player) {
  gameOver = true;

  // notify ui
  Serial.println(player);
  
  if (player == 1) {
    digitalWrite(lamp2, LOW); // loser lamp off
    
    for(int i=0; i<5; i++) {
      digitalWrite(lamp1, LOW);
      delay(100);
      digitalWrite(lamp1, HIGH);
      delay(100);
    }
    digitalWrite(lamp1, HIGH); // keep lamp on
  } 
  else {
    digitalWrite(lamp1, LOW); // loser lamp off
    
    for(int i=0; i<5; i++) {
      digitalWrite(lamp2, LOW);
      delay(100);
      digitalWrite(lamp2, HIGH);
      delay(100);
    }
    digitalWrite(lamp2, HIGH); // keep lamp on
  }
}

void resetSystem() {
  gameOver = false;
  // in start lamps on
  digitalWrite(lamp1, HIGH);
  digitalWrite(lamp2, HIGH);

  // notify ui
  Serial.println('r');

  delay(200); // (debounce)
}

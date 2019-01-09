#define nv1L 170    // ajuste de diferenca de potencia nos motores
#define nv1R 230


/* Definicao dos pinos usados */
int speedRightM = 10;
int speedLeftM = 11;
int rightM = 12;
int leftM = 13;

/* Definicao de Variaveis Auxiliares */
char dir[2] = {'s','s'};
int optMode = 2;          // variavel para definir o modo de operacao "1.SemiAuto"/"2.Manual"/"3.Auto"


/********** SETUP FUNCTION **********/
void setup() {
  Serial.begin(9600);

  pinMode(rightM, OUTPUT);
  pinMode(leftM, OUTPUT);
}
/********** LOOP FUNCTION **********/
void loop() {
  char cmd = Serial.read();
  
  if (cmd == 't') {
    optMode = 1;
    //activateSemiAutoMode();
  } else if (cmd == 'm') {
    optMode = 2;
    activateManualMode();
  } else if (cmd == 'a') {
    optMode = 3;
    //activateAutomaticMode();
  }
}

/********** MANUAL FUNCTION **********/
void activateManualMode() {
  /* Modo Manual */
  Serial.print("\t\tMANUAL MODE\n");
while(optMode == 2) {
  char cmd = Serial.read();
  switch (cmd) {
    case 'f':
      // movimento para Frente
      if (dir[0] == 'f') {  dir[1] = 's'; }
      moveForward(dir[1]);
      dir[0] = 'f';
      break;
    case 'b':
      // Movimento para Tras
      if (dir[0] == 'b') {  dir[1] = 's'; }
      moveBackward(dir[1]);
      dir[0] = 'b';
      break;
    case 'l':
      // Movimento de Curva para a Esquerda
      Serial.println("left");
      analogWrite(speedLeftM, 110);  analogWrite(speedRightM, 242);
      if (dir[0] == 'f') {
        // curva para frente e para esquerda
        digitalWrite(leftM, HIGH); digitalWrite(rightM, HIGH);
      } else if (dir[0] == 'b') {
        // curva para tras e para esquerda
        digitalWrite(leftM, LOW); digitalWrite(rightM, LOW);
      } else {
        // rotaciona sobre o eixo
        analogWrite(speedLeftM, 0);  analogWrite(speedRightM, 200);
        digitalWrite(rightM, HIGH);
      }
      dir[1] = 'l';
      break;
    case 'r':
      // Movimento de Curva para a Direita
      Serial.println("right");
      analogWrite(speedLeftM, 242);  analogWrite(speedRightM, 110);
      if (dir[0] == 'f') {
        // curva para frente e para direita
        digitalWrite(leftM, HIGH); digitalWrite(rightM, HIGH);
      } else if (dir[0] == 'b') {
        // curva para tras e para direita
        digitalWrite(leftM, LOW); digitalWrite(rightM, LOW);
      } else {
        // rotaciona sobre o eixo
        analogWrite(speedLeftM, 200);  analogWrite(speedRightM, 0);
        digitalWrite(leftM, HIGH);
      }
      dir[1] = 'r';
      break;
    case 'z':
      // Movimento de Rotacao sobre o eixo para Esquerda
      rotateLeft();
      dir[0] = 's'; dir[1] = 'l';
      break;
    case 'x':
      // Movimento de Rotacao sobre o eixo para Direita
      rotateRight();
      dir[0] = 's'; dir[1] = 'r';
      break;
    case 's':
      // Movimento de Parada
      stopMoving();
      dir[0] = 's'; dir[1] = 's';
      break;
    case 't':
      // Muda para Modo Semi Automatico
      optMode=1;
      //activateSemiAutoMode();
      break;
    case 'a':
      // Muda para Modo Automatico
      optMode=3;
      //activateAutomaticMode();
      break;
    default: break;
  }
}}

/********** MOTION FUNCTIONS **********/
void moveForward(char dir) {
  digitalWrite(leftM, HIGH); digitalWrite(rightM, HIGH);
  switch (dir) {
    case 'l':
      // movimento para frente virando levemente a esquerda
      analogWrite(speedLeftM, 110);  analogWrite(speedRightM, 242);
      break;
    case 'r':
      // movimento para frente virando levemente a direita
      analogWrite(speedLeftM, 242);  analogWrite(speedRightM, 110);
      break;
    default:
      // movimento para frente em linha reta
      analogWrite(speedLeftM, nv1L); analogWrite(speedRightM, nv1R);
      break;
  }
  Serial.println("forward");
}
void moveBackward(char dir) {
  digitalWrite(leftM, LOW); digitalWrite(rightM, LOW);
  switch (dir) {
    case 'l':
      // movimento para tras virando levemente a esquerda
      analogWrite(speedLeftM, 110);  analogWrite(speedRightM, 242);
      break;
    case 'r':
      // movimento para tras virando levemente a direita
      analogWrite(speedLeftM, 242);  analogWrite(speedRightM, 110);
      break;
    default:
      // movimento para tras em linha reta
      analogWrite(speedLeftM, nv1L); analogWrite(speedRightM, nv1R);
      break;
  }
  Serial.println("backward");
}
void rotateLeft() {
  // Movimento de rotacao sobre o eixo para a esquerda (sentido antihorario)
  analogWrite(speedLeftM, 0);  analogWrite(speedRightM, 200);
  digitalWrite(rightM, HIGH);
  Serial.println("rotate left");
}
void rotateRight() {
  // Movimento de rotacao sobre o eixo para a direita (sentido horario)
  analogWrite(speedLeftM, 200);  analogWrite(speedRightM, 0);
  digitalWrite(leftM, HIGH);
  Serial.println("rotate right");
}
void stopMoving() {
  // Movimento de Parada
  analogWrite(speedLeftM, 0);  analogWrite(speedRightM, 0);
  Serial.println("stop");
}
void stepBack() {
  // Curto movimento para tras em linha reta
  digitalWrite(leftM, LOW); digitalWrite(rightM, LOW);
  analogWrite(speedLeftM, 230);  analogWrite(speedRightM, 230);
  Serial.println("backward");
}

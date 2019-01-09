#include <NewPing.h>

#define nSensors 4    // numero de sensores ultrassonicos
#define maxDist 350   // 

#define nv1L 170    // ajuste de diferenca de potencia nos motores
#define nv1R 230

NewPing sonar[nSensors] = { //trigger, echo, max distance
  NewPing(4,5,maxDist),     // sensor Forward
  NewPing(9,8,maxDist),     // sensor Backward
  NewPing(7,6,maxDist),     // sensor Left
  NewPing(3,2,maxDist),     // sensor Right
};

/* Definicao dos pinos usados */
int speedRightM = 10;
int speedLeftM = 11;
int rightM = 12;
int leftM = 13;

/* Definicao de Variaveis Auxiliares */
char dir[2] = {'s','s'};
int optMode = 1;          // variavel para definir o modo de operacao "1.SemiAuto"/"2.Manual"/"3.Auto"
int feedbackSensor[4] = {0,0,0,0};  // armazena a leitura dos valores dos sensores ultrassonicos
const int gabarito[8][4] = {
  {1,0,0,0},
  {1,0,0,1},
  {1,0,1,0},
  {1,0,1,1},
  {1,1,0,1},
  {1,1,1,0},
  {1,1,0,0},
  {1,1,1,1},
};

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
    activateSemiAutoMode();
  } else if (cmd == 'm') {
    optMode = 2;
    activateManualMode();
  } else if (cmd == 'a') {
    optMode = 3;
    activateAutomaticMode();
  }
}

/********** AUTOMATIC FUNCTION **********/
void activateAutomaticMode() {
  /* Modo Automatico */
  Serial.print("\t\tAUTOMATIC MODE\n");
while(optMode == 3) {
  char cmd = Serial.read();

  // Muda para Modo Semi Automatico
  if (cmd == 't') {
    optMode = 1;
    activateSemiAutoMode();
  }
  
  // Muda para Modo Manual 
  else if (cmd == 'm') {
    stopMoving();
    optMode = 2;
    activateManualMode();
  }

  // Realiza a leitura dos sensores
  else {
    feedbackSensor[0] = sensor(0,20);
    feedbackSensor[1] = sensor(1,20);
    feedbackSensor[2] = sensor(2,20);
    feedbackSensor[3] = sensor(3,20);
  
    printEstadoSensores();

    if (feedbackSensor[0] != 0) {
      int row = checkGabarito();
      switch (row) {
        case 0:
          // obstaculo a frente
          stopMoving();  delay(25);
          stepBack();    delay(100);
          rotateRight(); delay(50);
          break;
        case 1:
          // obstaculo a frente e a direita
          stopMoving(); delay(250);
          rotateLeft(); delay(50);
          break;
        case 2:
          // obstaculo a frente e a esquerda
          stopMoving();  delay(25);
          rotateRight(); delay(50);
          break;
        case 3:
          // obstaculo a frente, a esquerda e a direita
          stopMoving();  delay(25);
          stepBack();    delay(100);
          rotateRight(); delay(50);
          break;
        case 4:
          // obstaculo a frente, atras e a direita
          stopMoving(); delay(25);
          rotateLeft(); delay(50);
          break;
        case 5:
          // obstaculo a frente, atras e a esquerda
          stopMoving();  delay(25);
          rotateRight(); delay(50);
          break;
        case 6:
          // obstaculo a frente e atras
          stopMoving();  delay(25);
          rotateRight(); delay(50);
          break;
        case 7:
          // obstaculo em todas as direcoes
          noMove();
          break;
        default: break;
      }
    } else {
      char d = 's';
      // obstaculo a esquerda, portanto eh aconselhavel virar levemente a direita
      if (feedbackSensor[2]) { d = 'r'; }
      // obstaculo a direita, portanto eh aconselhavel virar levemente a esquerda
      else if (feedbackSensor[3]) { d ='l'; }
      moveForward(d);
    }
  }
  delay(200);
}}

/********** SEMIAUTOMATIC FUNCTION **********/
void activateSemiAutoMode() {
  /* Modo Semi Automatico */
  Serial.print("\t\tSEMIAUTOMATIC MODE\n");
while(optMode == 1) {
  char cmd = Serial.read();
  
  feedbackSensor[0] = sensor(0,20);
  feedbackSensor[1] = sensor(1,20);
  feedbackSensor[2] = sensor(2,20);
  feedbackSensor[3] = sensor(3,20);
  
  printEstadoSensores();

  switch (cmd) {
    case 'f':
      // requisicao para andar para frente
      if (!feedbackSensor[0]) {
        // se nao houver obstaculo a frente, permite o movimento
        if (dir[0] == 'f') {  dir[1] = 's'; }
        moveForward(dir[1]);
      }
      dir[0] = 'f';
      break;
    case 'b':
      // requisicao para andar para tras
      if (!feedbackSensor[1]) {
        // se nao houver obstaculo atras, permite o movimento
        if (dir[0] == 'b') {  dir[1] = 's'; }
        moveBackward(dir[1]);
      }
      dir[0] = 'b';
      break;
    case 'l':
      // requisicao para fazer curva a esquerda
      if (!feedbackSensor[2]) {
        // se nao houver obstaculo a esquerda, permite o movimento para frente e para esquerda
        analogWrite(speedLeftM, 110);  analogWrite(speedRightM, 242);
        Serial.println("left");
      }
      dir[1] = 'l';
      break;
    case 'r':
      // requisicao para fazer curva a direita
      if (!feedbackSensor[3]) {
        // se nao houver obstaculo a direita, permite o movimento para frente e para direita
        analogWrite(speedLeftM, 242);  analogWrite(speedRightM, 110);
        Serial.println("right");
      }
      dir[1] = 'r';
      break;
    case 'z':
      // requisicao para rotacionar sobre o eixo a esquerda
      if (!feedbackSensor[2]) { rotateLeft(); }
      dir[0] = 's'; dir[1] = 'l';
      break;
    case 'x':
      // requisicao para rotacionar sobre o eixo a direita
      if (!feedbackSensor[3]) { rotateRight();  }
      dir[0] = 's'; dir[1] = 'r';
      break;
    case 's':
      // comando de parada
      stopMoving();
      dir[0] = 's'; dir[1] = 's';
      break;
    case 'm':
      // Muda para Modo Manual
      optMode=2;
      activateManualMode();
      break;
    case 'a':
      // Muda para Modo Automatico
      optMode=3;
      activateAutomaticMode();
      break;
    default:
      // continua seguindo a direcao do ultimo comando dado ate encontrar um obstaculo
      if (dir[0] == 'f') {
        if(feedbackSensor[0]) { stopMoving(); }
        else moveForward(dir[1]);
      } else if (dir[0] == 'b') {
        if (feedbackSensor[1]) { stopMoving(); }
        else moveBackward(dir[1]);
      }
      else if (dir[1] == 'l') {
        if (feedbackSensor[2]) {  stopMoving(); }
        else rotateLeft();
      } else if (dir[1] == 'r') {
        if (feedbackSensor[3]) { stopMoving();  }
        else rotateRight();
      }
      break;
  }
  
  delay(400);
}}

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
      activateSemiAutoMode();
      break;
    case 'a':
      // Muda para Modo Automatico
      optMode=3;
      activateAutomaticMode();
      break;
    default: break;
  }
}}


/********** AUXILIAR FUNCTIONS **********/

// Verifica se existe um obstaculo proximo
int sensor(int nSensor, int limit) {
  long cm;
  cm = sonar[nSensor].ping_cm();
  if (cm <= limit && cm != 0) { return 1; }
  else return 0;
}

void printEstadoSensores() {
  for (int i=0; i<4;i++){
    Serial.print(feedbackSensor[i]); Serial.print(" ");
  }
  Serial.println();
}

/* Verifica quais sensores foram ativados
 * e compara com o gabarito, retornando a linha do gabarito que corresponde a situacao encontrada
 */
int checkGabarito() {
  for (int i=0; i<8; i++) {
    int num = 0;
    for (int j=1; j<4; j++) {
       if (feedbackSensor[j] == gabarito[i][j]) { num++;  }
       else j=5;
       if (j==3 && num ==3) { return i; }
    }
  }
}

/********** MOTION FUNCTIONS **********/
void moveForward(char dir) {
  digitalWrite(leftM, HIGH); digitalWrite(rightM, HIGH);
  switch (dir) {
    case 'l':
      if (!feedbackSensor[2]) {
        // se nao identificou obstaculo a esquerda, movimento para frente virando levemente a esquerda
        analogWrite(speedLeftM, 110);  analogWrite(speedRightM, 242);
      } else {
          // caso haja obstaculo a esquerda, anda em linha reta
          analogWrite(speedRightM, nv1L);  analogWrite(speedLeftM, nv1R);
      }
      break;
    case 'r':
      // se nao identificou obstaculo a direita, movimento para frente virando levemente a direita
      if (!feedbackSensor[3]) {
        analogWrite(speedLeftM, 242);  analogWrite(speedRightM, 110);
      } else {
          // caso haja obstaculo a direita, anda em linha reta
          analogWrite(speedRightM, nv1L);  analogWrite(speedLeftM, nv1R);
      }
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
      if (!feedbackSensor[2]) {
        // se nao identificou obstaculo a esquerda, movimento para tras virando levemente a esquerda
        analogWrite(speedLeftM, 110);  analogWrite(speedRightM, 242);
      } else {
          // caso haja obstaculo a esquerda, anda em linha reta
          analogWrite(speedRightM, nv1L);  analogWrite(speedLeftM, nv1R);
      }
      break;
    case 'r':
      if (!feedbackSensor[3]) {
        // se nao identificou obstaculo a direita, movimento para tras virando levemente a direita
        analogWrite(speedLeftM, 242);  analogWrite(speedRightM, 110);
      } else {
          // caso haja obstaculo a direita, anda em linha reta
          analogWrite(speedRightM, nv1L);  analogWrite(speedLeftM, nv1R);
      }
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
void noMove() {
  analogWrite(speedLeftM, 0);  analogWrite(speedRightM, 0);
  Serial.println("I'm Stuck");
}

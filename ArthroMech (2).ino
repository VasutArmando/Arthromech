#include <Arduino.h>
#include <Servo.h>
#include <SoftwareSerial.h>
#include <string.h>
//#if !defined(CONFIG_BT_ENABLED) || !defined (CONFIG_BLUEDROID_ENABLED)
//#error Bluetooth is not enabled! Please run 'make menuconfig' to and enable it
//#endif

SoftwareSerial SerialBT(5, 12);  // pin intrare date de la HC-05

Servo servoStanga;
Servo servoDreapta;
Servo motor1;
Servo motor2;
Servo motor3;
Servo motor4;
Servo motor5;
int pos;
int data;
//sudo chmod a+rw /dev/ttyUSB0

int confirmareObiect = 0;
int procesDePrindere = 0;
int timp = 0;
int GradMax = 180;

const int trigPin = 4;
const int echoPin = 3;
long duration;
float distance;

int Conectat;
int state = 1;
/*
int conversieNivelLaGrade(int nivel, int gradeMax) {
  int diviziune = gradeMax / (nivel - 1);
  int n = (nivel - 1) * diviziune;
  return n;
}*/
void setup() {
  Serial.begin(9600);
  SerialBT.begin(9600);
  // pinMode(A0, INPUT);
  pinMode(2, INPUT);
  pinMode(12, INPUT);
  // servoStanga.attach(11);
  // servoDreapta.attach(8);
  motor5.attach(10);
  motor4.attach(9);
  motor3.attach(8);
  motor2.attach(7);
  motor1.attach(6);


  //nume device bluetooth
  Serial.println("the device has started, now you can pair it with bluetooth!");
}
void ActionareMotorNivel(int nrMotor, int grade)  // 1 inchis, 5 deschis complet 2,3,4 grade intermediare
{
  //int nivelG = conversieNivelLaGrade(nivel, GradMax);

  switch (nrMotor) {
    case 1:
      motor1.write(grade);
      break;
    case 2:
      motor2.write(grade);
      break;
    case 3:
      motor3.write(grade);
      break;
    case 4:
      motor4.write(grade);

      break;
    case 5:
      motor5.write(grade);
      break;
  }
}
// pin motoare 6,7,8,9,10 unde 10 degetul mic si 6 degetul mare



void inchideMana() {
  // servoDreapta.write(180);
  //servoStanga.write(0);
  for (int i = 1; i <= 5; i++) {
    if(i == 1)
      ActionareMotorNivel(i, 0);
    else
      ActionareMotorNivel(i, 180);
  }
  Serial.println(0);
}
void deschideMana() {
  /// servoDreapta.write(0);
  //servoStanga.write(180);
  for (int i = 1; i <= 5; i++) {
    if(i == 1)
      ActionareMotorNivel(i, 180);
    else   
      ActionareMotorNivel(i, 0);
  }
  Serial.println(1);
}


void citireDateSenzor() {

  pinMode(trigPin, OUTPUT);  // Sets the trigPin as an Output

  // Clears the trigPin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);


  pinMode(echoPin, INPUT);
  duration = pulseIn(echoPin, HIGH);
  // Se calculeaza distanta
  distance = duration * 0.034 / 2;
  // Prints the distance on the Serial Monitor
  //Serial.print("Distance: ");
  //Serial.println(distance);
}

void VerificareConexiune() {
  if (digitalRead(12) == LOW)
    Conectat = 1;
  else
    Conectat = 0;
}
void modautomat() {
  citireDateSenzor();
  // Serial.print("d1 ");
 // Serial.println(distance);

  if (distance < 7) {

    confirmareObiect = 1;
    //  Serial.print("obiect gasit");
    //  Serial.println(distance);


  } else if (procesDePrindere != 1) {
    deschideMana();
    confirmareObiect = 0;
  }
  if (confirmareObiect == 1 && procesDePrindere == 0) {
    delay(1000);
    citireDateSenzor();
    //    Serial.print("d2 ");
    //Serial.print(distance);
    if (distance < 7) {
      procesDePrindere = 1;

      ActionareMotorNivel(2, 5);
      delay(2000);
    }
  }


  if (digitalRead(2) == LOW && procesDePrindere == 1)  // senzor miscare vibratie
  {
    //nu se misca
    timp++;
  } else {
    // se misca
    timp = 0;
  }
  Serial.println(timp);
  if (timp > 200) {
    timp = 300;
    confirmareObiect = 0;

    procesDePrindere = 0;
  }
  //Serial.println(procesDePrindere);
  if (timp < 200 && procesDePrindere == 1) {
    inchideMana();

  } else {
    deschideMana();
  }
}
void loop() {
  // VerificareConexiune();
  if (SerialBT.available() > 0) {
    data = 0;
    while (SerialBT.available() > 0) {
      char mesaj = SerialBT.read();
      if (mesaj - 48 >= 0 && mesaj - 48 <= 10)
        data = data * 10 + (mesaj - 48);
    }
  }
  if (data > 0)
    state = data;
  //Serial.println(state);
  if (state == 1) {

    modautomat();
    //Serial.print(procesDePrindere);
  }
  if (state == 2) {
    inchideMana();
  }
  if (state == 3) {
    deschideMana();
  }
  if (state > 9999 && state < 100000) {
    int cs = state;
    for (int i = 5; i >= 1; i--) {
      if(cs % 10 == 2)
        ActionareMotorNivel(i, 180);
      else
        ActionareMotorNivel(i, 0);
      cs /=10;
     
    }
  }

  delay(20);
}
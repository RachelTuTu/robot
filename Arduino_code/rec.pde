/* 
 * rosserial Subscriber Example
 * Blinks an LED on callback
 */

#include <ros.h>
#include <std_msgs/Float32MultiArray.h>

ros::NodeHandle  nh;
float right_motor=0, left_motor=0;
int left_RS_PIN = 13;
int left_RV_PIN = 12;
int left_PWM_PIN = 11;

int right_RS_PIN = 9;
int right_RV_PIN = 8;
int right_PWM_PIN = 10;

bool NH_diff_sign(float a, float b){
  if(a>=0 and b>=0){
    return 0;
  }
  if(a<0 and b<0){
    return 0;
  }
  
  return 1;
}


float Direction_Contral(float digtal_his ,float digital_now, int RS_PIN, int RV_PIN){
  if (NH_diff_sign(digtal_his, digital_now)){
    digitalWrite(RS_PIN, HIGH);
    delay(10);
    digitalWrite(RS_PIN, LOW);
    if (digital_now!=0){
    digitalWrite(RV_PIN, HIGH);
    delay(10);
    digitalWrite(RV_PIN, LOW);
  }
  }
  return digital_now;
}

int float2pwm(float PWM_Max, float upper_lim, float lower_lim, float motor_speed){
  motor_speed = abs(motor_speed);
  if(motor_speed >= upper_lim){
    motor_speed = upper_lim;
  }
  if(motor_speed <= lower_lim){
    motor_speed = lower_lim;
  }
  return round(PWM_Max * (motor_speed / (upper_lim - lower_lim)));
}

void messageCb( const std_msgs::Float32MultiArray& toggle_msg){


  left_motor = Direction_Contral(left_motor, toggle_msg.data[0], left_RS_PIN, left_RV_PIN);
  right_motor = Direction_Contral(right_motor, toggle_msg.data[1], right_RS_PIN, right_RV_PIN);
  analogWrite(right_PWM_PIN,float2pwm(127, 1, 0, left_motor));  
  analogWrite(left_PWM_PIN,float2pwm(127, 1, 0, right_motor));
  return ;
  // digitalWrite(LED_BUILTIN, HIGH-digitalRead(LED_BUILTIN));   // blink the led
}

ros::Subscriber<std_msgs::Float32MultiArray> sub("/arduino_motor", &messageCb );

void setup()
{ 
  pinMode(left_RS_PIN, OUTPUT);
  pinMode(left_RV_PIN, OUTPUT);
  pinMode(left_PWM_PIN, OUTPUT);
  pinMode(right_RS_PIN, OUTPUT);
  pinMode(right_RV_PIN, OUTPUT);
  pinMode(right_PWM_PIN, OUTPUT);


  nh.initNode();
  nh.subscribe(sub);
}

void loop()
{  
  nh.spinOnce();
  
  delay(1);
}


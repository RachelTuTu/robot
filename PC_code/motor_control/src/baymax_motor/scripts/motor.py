#!/usr/bin/env python3

import rospy
from std_msgs.msg import String, Float32MultiArray, MultiArrayDimension
from geometry_msgs.msg import Twist

class DataHandler:

    def __init__(self) -> None:
        self.data = Float32MultiArray()
        self.data.data = [0.0, 0.0]
        dim1 = MultiArrayDimension()
        dim1.label = 'left_motor'
        dim1.size = 1

        dim2 = MultiArrayDimension()
        dim2.label = 'right_motor'
        dim2.size = 1
        self.data.layout.dim = [dim1, dim2]

    def set_processed_data(self, data):
        self.data.data = data
    
    def get_processed_data(self):
        return self.data

class TwistData:
    def __init__(self, node_name='transer', 
                 topic_name='/cmd_vel', 
                 data_handler=DataHandler()):
        self.linear_x = 0.0
        self.linear_y = 0.0
        self.linear_z = 0.0
        self.angular_x = 0.0
        self.angular_y = 0.0
        self.angular_z = 0.0
        self.data_handler = data_handler

        rospy.init_node(node_name)
        rospy.Subscriber(topic_name, Twist, self.callback)
 
    def callback(self, data):
        # self.linear_x = data.linear.x
        # self.linear_y = data.linear.y
        # self.linear_z = data.linear.z
        # self.angular_x = data.angular.x
        # self.angular_y = data.angular.y
        # self.angular_z = data.angular.z
        self.data_handler.set_processed_data([float(data.linear.x), 
                                              float(data.angular.z)]) 
        rospy.loginfo(data.linear.x)

    def run(self):
        rospy.spin()

class ArduinoMotor:
    
    def __init__(self, data_handler=DataHandler()):
        self.data_handler = data_handler
        # rospy.init_node('motor_sender')
        self.publisher = rospy.Publisher('/arduino_motor', 
                                         Float32MultiArray, 
                                         queue_size=10)
    
    def publish_data(self):
        processed_data = self.data_handler.get_processed_data()
        if processed_data is not None:
            rospy.loginfo(processed_data)
            self.publisher.publish(processed_data)

if __name__ == '__main__':
    data_handler = DataHandler()
    twist_data = TwistData(data_handler=data_handler)
    motor_data = ArduinoMotor(data_handler=data_handler)

    rospy.sleep(1)
    rate = rospy.Rate(10)
    while not rospy.is_shutdown():
        motor_data.publish_data()
        rate.sleep()

    twist_data.run()
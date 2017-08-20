The system to be designed is a Fire Alarm System. 
The Fire Alarm System is to be implemented in a large building with 3 floors. 
The Fire Alarm System is made up of two types of subsystems. 
A Floor Subsystem and a Centrally Coordinating Subsystem (Note: These are only the names assigned by the user to the subsystems). 
Floor Subsystem 
Each Floor has 8 smoke sensors and 8 temperature sensors strategically placed along the floor. 
Sensor outputs are conditioned to generate output voltages between 0- 5 V. 
Sensors have a resolution of about 20 mV. 
The smoke and temperature sensors are monitored regularly at intervals of 10 seconds. 
If any abnormal levels are detected from any of the sensor inputs, data from other sensors are collected to validate the data of the sensor indicating abnormal level. 
The data collected by the sensors is collected at the Floor Subsystem, processed and analyzed. 
In case of normal conditions (i.e. when there is no indication of fire) data collected is sent to the Centrally Coordinating Subsystem at regular intervals of 2 minutes. 
In case of any abnormal conditions the Centrally Coordinating Subsystem is alerted immediately. 
In case of a fire, the Floor Subsystem activates the sprinklers (4 nos.) connected to it on, if asked to, by the Centrally Coordinating Subsystem. 
The sprinklers are controlled by solenoid valves. 
The sprinklers are turned off when normal temperature and smoke levels are restored. 
Centrally Coordinating Subsystem 
Collects data from the floor subsystems at regular intervals of time. 
In the case of a fire indication asks the floor subsystems to activate the sprinklers. 
It also sounds an Audio Alarm which is of the form in case of a fire. 
You can assume that the Alarm is loud enough for all the Floors to hear the alarm. 
In case of a fire the subsystem also alerts the nearest fire station using a Telephone connected via a Modem. 
In case data is not received from any of the floors over a certain period of time, the floor subsystem is requested to send data. 
If there is no response then a visual alarm is used to indicate floor from which data has not arrived. 
Each of the floors has a bulb at the centrally coordinating subsystem to indicate failure.

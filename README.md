# Digital-circuit-course-design
Digital circuit course design

# Digital clock

## Abstract:
In public, we often need to look at time, which requires a precise digital clock to serve us, digital clock is a kind of when using a digital circuit technology, minutes and seconds timing device, has higher accuracy compared with the mechanical clock and intuitive, and no mechanical device, has a longer service life, therefore has been widely used. This digital clock is made by Verilog language. There's the basic clock function, there's the alarm clock, the flashing 10 second countdown, the hourly broadcast, THE LCD display, etc

## video
you can watch a video about it from:
### [youtube-video](https://youtu.be/3SdaLhA8cqA )

![image](https://github.com/yangtiming/Digital-circuit-course-design/blob/master/images/board.JPG)



## The design requirements
1. design a 'hour', 'minutes',' seconds' decimal digit display (hours from 00 to 23) timer.

2. the hour strikes. From 59 minutes and 50 seconds, the signal will be sent every two seconds for five consecutive times until the last signal reach the hour. This is achieved by LED flickering.

3. the realization of manual calibration, calibration minute, calibration second function.

4. timing and alarm clock function, only need to set minutes and hours. Manual setting and clock can send out alarm at the set time, and the sound is realized by LED.

5. Design a 10-digit countdown with flashing display and flashing frequency of 2HZ

6. Use the LCD to display the current time.

1、设计一个具有‘时’、‘分’、‘秒’的十进制数字显示（小时从00～23）计时器。 

2、整点报时。仿中央人民广播电台的整点报时信号，即从第59分50秒算起，每隔2秒钟发出一次信号，连续5次，最后一次信号结束即达到整点。通过LED闪烁实现。

3、实现手动校时、校分、校秒功能。

4、定时与闹钟功能，只需要设置分钟和小时。手动设置能在设定的时间发出闹铃声,声音用LED实现。

5、设计一个10个数的倒计时，闪烁显示，闪烁频率2HZ

6、用LCD液晶屏来显示当前时间。

![image](https://github.com/yangtiming/Digital-circuit-course-design/blob/master/images/liuchengtu2.jpg)

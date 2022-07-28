module clockmyself(
	input 		clk,					 //			--总的clk，接50mhz的石英振荡器			------->PIN_N2 
	input 		option_pattern,	    	 //			用于手动调节时分秒的按钮				--------->KEY3--PIN_W2
	input 		up_switch,				//			用于选择手动时间后的a=a+1工作			-------->KEY2--PIN_p23
	
	input 		set_mod,				//													--------->sw1--PIN_N26
	
	input 		set_alarm,				//*			 自动计时：set_mod==1					--------->sw0--PIN_N25
										//* 		手动计时：set_mod==0 且 set_alarm==0//
										//* 		手动设置闹钟：set_mod==0 且 set_alarm==1//
										
	output reg  blink,       			//          整点报时模块output->blinking//			--------->LEDR0--PIN_AE23
	
	
    output reg 	[6:0]qout_recnt,		//          用于在数码管上显示倒计时//        				==>HEX0（完成）
	input	   	recout,         		//          控制是否倒计时//						--------->SW17--PIN_V2
	output reg 	alarm_sound,    		//			显示闹钟是否工作状态.led show//			--------->LEDR1--PIN_AF23

	
	//时分秒的数码管输出
	output reg [6:0]qout_1,		//==>HEX2（完成）
	output reg [6:0]qout_2,		//==>HEX3（完成）
	output reg [6:0]qout_3,		//==>HEX4（完成）
	output reg [6:0]qout_4,		//==>HEX5（完成）
	output reg [6:0]qout_5,		//==>HEX6（完成）
	output reg [6:0]qout_6,		//==>HEX7（完成）
	output reg clk_div,			//fenping
	output reg [1:0]option_1,   //chice led
	
	
	
	
	//lcd的input和output
			input   rst,       			//rst为全局复位信号（高电平有效）
	
			output  LCD_EN,LCD_ON,		//LCD_EN为LCD模块的使能信号（下降沿触发）
			output  reg RS,					//RS=0时为写指令；RS=1时为写数据
			output  RW,					//RW=0时对LCD模块执行写操作；RW=1时对LCD模块执行读操作
			output reg [7:0] DB8		//8位指令或数据总线
	
	);
	

	//---分频模块1--//
parameter n= 49999999;//--选用50Mhz的石英振荡器--//
reg [30:0]div_cnt;
//reg clk_div;
always @(posedge clk )
begin 
	if(div_cnt==n)
	begin 
		div_cnt<=0;
		clk_div<=1;//--将50mHZ分成50m份---//
	end
	
	else
	begin 
		div_cnt<=div_cnt+1;
		clk_div<=0;
	end
end





//--模块2：自动计时模块--//
//--实现 00：00：00 ==> 23：59：59 的循环的时间计时--//
//设置一个flag，来控制此模块//
	
reg [3:0]secL_1;
reg [3:0]secH_1;
reg [3:0]minL_1;
reg [3:0]minH_1;
reg [3:0]hourL_1;
reg [3:0]hourH_1;


always @(posedge clk_div)
begin
if(set_mod==1)
begin
	//23：59：59
	if(hourH_1==4'b0010 && hourL_1==4'b0011 && minH_1==4'b0101 && minL_1==4'b1001 && secH_1==4'b0101 && secL_1==4'b1001)
	begin
		secL_1<=4'b0000;
		secH_1<=4'b0000;
		minL_1<=4'b0000;
		minH_1<=4'b0000;
		hourL_1<=4'b0000;
		hourH_1<=4'b0000;
	end
	else
	//--no-23：59：59->计数//
	if(secL_1==9)
	begin
		secL_1<=4'b0000;
		if(secH_1==5)
		begin
			secH_1<=4'b0000;
			if(minL_1==9)
			begin
				minL_1<=4'b0000;
				if(minH_1==5)
				begin
					minH_1<=4'b0000;
					if(hourL_1==9)
					begin
						hourL_1<=4'b0000;
						hourH_1<=hourH_1+1;
					end
					else
					hourL_1<=hourL_1+1;
				end
				else
				minH_1<=minH_1+1;
			end
			else
			minL_1<=minL_1+1;
		end
		else
		secH_1<=secH_1+1;
	end
	else
	secL_1<=secL_1+1;
end
else if(set_mod==0 && set_alarm==0)
begin
	//--让手动调整后的时间进行自动计时--//
	secL_1<=secL_2;
	secH_1<=secH_2;
	minL_1<=minL_2;
	minH_1<=minH_2;
	hourL_1<=hourL_2;
	hourH_1<=hourH_2;
	
end
end



//--模块3:手动记时模块--//
//--模块3_1:手动调节时分秒选择--//
//--pattern_set==0表示手动调秒;	pattern_set==1表示手动调分;	pattern_set==2表示调时-//

always@(posedge option_pattern)
begin
	if(option_1==3)
		begin option_1<=0; end
	else
	begin 	option_1<=option_1+1; end
end



//--模块3_2:手动调节时模块--//

reg [3:0]secL_2;
reg [3:0]secH_2;
reg [3:0]minL_2;
reg [3:0]minH_2;
reg [3:0]hourL_2;
reg [3:0]hourH_2;

always@(posedge  up_switch)
begin

//手动校时模式
if(set_mod==0 && set_alarm==0)		//--手动计时：set_mod==0 且 set_alarm==0--//
begin 
	//23：59：59//
	if(hourH_2==4'b0010 && hourL_2==4'b0011 && minH_2==4'b0101 && minL_2==4'b1001 && secH_2==4'b0101 && secL_2==4'b1001)
	begin
		secL_2<=4'b0000;
		secH_2<=4'b0000;
		minL_2<=4'b0000;
		minH_2<=4'b0000;
		hourL_2<=4'b0000;
		hourH_2<=4'b0000;
	end
	else
	begin
	//--no-23：59：59->计数--//
	//option_1==0-->调秒//
		if(option_1==0)
		begin
			if(secL_2==9)
			begin
				secL_2<=4'b0000;
				if(secH_2==5)
					secH_2<=4'b0000;
				else
					secH_2<=secH_2+1;
			end
			else
			secL_2<=secL_2+1;
		end

	//option_1==1-->调分//
	if(option_1==1)
	begin 
		if(minL_2==9)
		begin
			minL_2<=4'b0000;
			if(minH_2==5)
				minH_2<=4'b0000;
			else
			minH_2<=minH_2+1;
		end	
		else
		minL_2<=minL_2+1;
	end
	//--option_1==1-->调时--//
	if(option_1==2)
	begin 
	if(hourL_2==3 && hourH_2==2)
	begin
		 hourL_2<=0;
		 hourH_2<=0;
	end
	else
	begin 
		if(hourL_2==9 )
		begin
			hourL_2<=4'b0000;
			if(hourH_2==2)
				hourH_2<=4'b0000;
			else
			hourH_2<=hourH_2+1;
		end	
		else
		hourL_2<=hourL_2+1;
	end
	end
	
	end
end



if(set_mod==0 && set_alarm==1)	//手动设置闹钟：set_mod==0 且 set_alarm==1//
begin
	//23：59：59//
	if(alarm_hourH==4'b0010 && alarm_hourL==4'b0011 && alarm_minH==4'b0101 && alarm_minL==4'b1001 && alarm_secH==4'b0101 && alarm_secL==4'b1001)
	begin
		alarm_secL<=4'b0000;
		alarm_secH<=4'b0000;
		alarm_minL<=4'b0000;
		alarm_minH<=4'b0000;
		alarm_hourL<=4'b0000;
		alarm_hourH<=4'b0000;
	end
	else
	begin
	//--no-23：59：59->计数--//
	//调秒
	if(option_1==0)
	begin
		if(alarm_secL==9)
		begin
			alarm_secL<=4'b0000;
			if(alarm_secH==5)
				alarm_secH<=4'b0000;
			else
				alarm_secH<=alarm_secH+1;
		end
		else
		alarm_secL<=alarm_secL+1;
	end
	//调分
	if(option_1==1)
	begin 
		if(alarm_minL==9)
		begin
			alarm_minL<=4'b0000;
			if(alarm_minH==5)
				alarm_minH<=4'b0000;
			else
			alarm_minH<=alarm_minH+1;
		end	
		else
		alarm_minL<=alarm_minL+1;
	end
	//调时
	if(option_1==2)
	begin 
	if(alarm_hourL==3 && alarm_hourH==2)
	begin
		 alarm_hourL<=0;
		 alarm_hourH<=0;
	end
	else
	begin 
		if(alarm_hourL==9 )
		begin
			alarm_hourL<=4'b0000;
			if(alarm_hourH==2)
				alarm_hourH<=4'b0000;
			else
			alarm_hourH<=alarm_hourH+1;
		end	
		else
		alarm_hourL<=alarm_hourL+1;
	end
	end
	
	end
end

end


//模块4：计时输出模块//
	//作为数码管的输入
reg [3:0]secL;
reg [3:0]secH;
reg  [3:0]minL;
reg [3:0]minH;
reg [3:0]hourL;
reg [3:0]hourH;
// 该模块的输出至少1s更新一次，数码管上的示数也是至少1s更新一次 //
always@(secL_1 or secH_1 or minL_1 or minH_1 or hourL_1 or hourH_1 or secL_2 or secH_2 or minL_2 or minH_2 or hourL_2 or hourH_2)
begin
	//自动计数模式
	if(set_mod==1)
	begin
		secL<=secL_1;
		secH<=secH_1;
		minL<=minL_1;
		minH<=minH_1;
		hourL<=hourL_1;
		hourH<=hourH_1;
	end
	else
	//手动计数模式
	if(set_mod==0 && set_alarm==0)		//手动计时：set_mod==0 且 set_alarm==0//
	begin
		secL<=secL_2;
		secH<=secH_2;
		minL<=minL_2;
		minH<=minH_2;
		hourL<=hourL_2;
		hourH<=hourH_2;
	end
end


//模块5：整点报时模块//

//--从59：50到00：00，产生以1为起始的0-1序列，对应指示灯间隔为2s的闪烁--//
always @(secL)
begin
	if(minH==5 && minL== 9 && secH== 5) //--异步闪烁--//
	begin 
		if(secL==0 || secL==2 || secL==4 || secL==6 || secL==8)
		begin 
			blink<=~blink;
		end
		else
		begin
		 blink<=0;
		end
	end
end

//模块6：倒计时模块//
//倒计时闪烁模块//
parameter m=24999999;
reg [50:0]q;
reg clk_22;
always@(posedge clk)
begin
	if(q==m)
	begin
		clk_22<=1;
		q<=0;
	end 
	else
	begin 
		q<=q+1;
		clk_22<=0;
	end
end










reg [4:0]count;
reg [3:0]recnt;
always @(posedge clk_22 or negedge recout)
begin 
	if(!recout)
	begin 
		count<=4'b0000;
	end
	else 
	begin 
		if(count==19)
		begin count<=0; end
		else 
		begin 
		count <=count+1;
		end
			
	end
case(count)
		5'b00000:recnt<=4'b1001;
		5'b00001:recnt<=4'b1111;
		5'b00010:recnt<=4'b1000;
		5'b00011:recnt<=4'b1111;
		5'b00100:recnt<=4'b0111;
		5'b00101:recnt<=4'b1111;
		5'b00110:recnt<=4'b0110;
		5'b00111:recnt<=4'b1111;
		5'b01000:recnt<=4'b0101;
		5'b01001:recnt<=4'b1111;
		5'b01010:recnt<=4'b0100;
		5'b01011:recnt<=4'b1111;
		5'b01100:recnt<=4'b0011;
		5'b01101:recnt<=4'b1111;
		5'b01110:recnt<=4'b0010;
		5'b01111:recnt<=4'b1111;
		5'b10000:recnt<=4'b0001;
		5'b10001:recnt<=4'b1111;
		5'b10010:recnt<=4'b0000;
		5'b10011:recnt<=4'b1111;
	default:	recnt<=4'b0000;
endcase 
end
always @(recnt)//用于在数码管上显示倒计时//
begin 
	case(recnt)
		4'b0000:qout_recnt<=7'b1000000;
		4'b0001:qout_recnt<=7'b1111001;
		4'b0010:qout_recnt<=7'b0100100;
		4'b0011:qout_recnt<=7'b0110000;
		4'b0100:qout_recnt<=7'b0011001;
		4'b0101:qout_recnt<=7'b0010010;
		4'b0110:qout_recnt<=7'b0000010;
		4'b0111:qout_recnt<=7'b1111000;
		4'b1000:qout_recnt<=7'b0000000;
		4'b1001:qout_recnt<=7'b0010000;
	default:	qout_recnt<=7'b1111111;
	endcase 
end 

//模块7：闹钟设定模块和闹钟触发模块//
//闹钟设定时间的可视化
reg [3:0]alarm_secL;
reg [3:0]alarm_secH;
reg [3:0]alarm_minL;
reg [3:0]alarm_minH;
reg [3:0]alarm_hourL;
reg [3:0]alarm_hourH;
//闹钟触发开始：判断闹钟设定时间 是否等于 现在的时间，如果是则灯亮//
reg [3:0]alarm_cnt;
always@(secL)
begin
	alarm_sound<=1'b0;
	if( minL==alarm_minL && minH==alarm_minH && hourL==alarm_hourL && hourH==alarm_hourH)
	begin
		alarm_sound<=1'b1;
	end
end
//模块8：可视化数码管模块//
always@(secL or alarm_secL)
begin
	if(set_alarm==0)
	begin
		case(secL)
			4'b0000:qout_1<=7'b1000000;
			4'b0001:qout_1<=7'b1111001;
			4'b0010:qout_1<=7'b0100100;
			4'b0011:qout_1<=7'b0110000;
			4'b0100:qout_1<=7'b0011001;
			4'b0101:qout_1<=7'b0010010;
			4'b0110:qout_1<=7'b0000010;
			4'b0111:qout_1<=7'b1111000;
			4'b1000:qout_1<=7'b0000000;
			4'b1001:qout_1<=7'b0010000;
		default:qout_1<=7'b1111111;
		endcase
	end 
	else if(set_alarm==1)
	begin
		case(alarm_secL)
			4'b0000:qout_1<=7'b1000000;
			4'b0001:qout_1<=7'b1111001;
			4'b0010:qout_1<=7'b0100100;
			4'b0011:qout_1<=7'b0110000;
			4'b0100:qout_1<=7'b0011001;
			4'b0101:qout_1<=7'b0010010;
			4'b0110:qout_1<=7'b0000010;
			4'b0111:qout_1<=7'b1111000;
			4'b1000:qout_1<=7'b0000000;
			4'b1001:qout_1<=7'b0010000;
		default:qout_1<=7'b1111111;
		endcase
	end 
end



always@(secH or alarm_secH)
begin
	if(set_alarm==0)
	begin
		case(secH)
			4'b0000:qout_2<=7'b1000000;
			4'b0001:qout_2<=7'b1111001;
			4'b0010:qout_2<=7'b0100100;
			4'b0011:qout_2<=7'b0110000;
			4'b0100:qout_2<=7'b0011001;
			4'b0101:qout_2<=7'b0010010;
			4'b0110:qout_2<=7'b0000010;
			4'b0111:qout_2<=7'b1111000;
			4'b1000:qout_2<=7'b0000000;
			4'b1001:qout_2<=7'b0010000;
		default:qout_2<=7'b1111111;
		endcase
	end
	else if(set_alarm==1)
	begin
		case(alarm_secH)
			4'b0000:qout_2<=7'b1000000;
			4'b0001:qout_2<=7'b1111001;
			4'b0010:qout_2<=7'b0100100;
			4'b0011:qout_2<=7'b0110000;
			4'b0100:qout_2<=7'b0011001;
			4'b0101:qout_2<=7'b0010010;
			4'b0110:qout_2<=7'b0000010;
			4'b0111:qout_2<=7'b1111000;
			4'b1000:qout_2<=7'b0000000;
			4'b1001:qout_2<=7'b0010000;
		default:qout_2<=7'b1111111;
		endcase
	end 
end

always@(minL)
begin
	if(set_alarm==0)
	begin
		case(minL)
			4'b0000:qout_3<=7'b1000000;
			4'b0001:qout_3<=7'b1111001;
			4'b0010:qout_3<=7'b0100100;
			4'b0011:qout_3<=7'b0110000;
			4'b0100:qout_3<=7'b0011001;
			4'b0101:qout_3<=7'b0010010;
			4'b0110:qout_3<=7'b0000010;
			4'b0111:qout_3<=7'b1111000;
			4'b1000:qout_3<=7'b0000000;
			4'b1001:qout_3<=7'b0010000;
		default:qout_3<=7'b1111111;
		endcase
	end
	else if(set_alarm==1)
	begin
		case(alarm_minL)
			4'b0000:qout_3<=7'b1000000;
			4'b0001:qout_3<=7'b1111001;
			4'b0010:qout_3<=7'b0100100;
			4'b0011:qout_3<=7'b0110000;
			4'b0100:qout_3<=7'b0011001;
			4'b0101:qout_3<=7'b0010010;
			4'b0110:qout_3<=7'b0000010;
			4'b0111:qout_3<=7'b1111000;
			4'b1000:qout_3<=7'b0000000;
			4'b1001:qout_3<=7'b0010000;
		default:qout_3<=7'b1111111;
		endcase
	end
end

always@(minH)
begin
	if(set_alarm==0)
	begin
		case(minH)
			4'b0000:qout_4<=7'b1000000;
			4'b0001:qout_4<=7'b1111001;
			4'b0010:qout_4<=7'b0100100;
			4'b0011:qout_4<=7'b0110000;
			4'b0100:qout_4<=7'b0011001;
			4'b0101:qout_4<=7'b0010010;
			4'b0110:qout_4<=7'b0000010;
			4'b0111:qout_4<=7'b1111000;
			4'b1000:qout_4<=7'b0000000;
			4'b1001:qout_4<=7'b0010000;
		default:qout_4<=7'b1111111;
		endcase
	end
	else if(set_alarm==1)
	begin
		case(alarm_minH)
			4'b0000:qout_4<=7'b1000000;
			4'b0001:qout_4<=7'b1111001;
			4'b0010:qout_4<=7'b0100100;
			4'b0011:qout_4<=7'b0110000;
			4'b0100:qout_4<=7'b0011001;
			4'b0101:qout_4<=7'b0010010;
			4'b0110:qout_4<=7'b0000010;
			4'b0111:qout_4<=7'b1111000;
			4'b1000:qout_4<=7'b0000000;
			4'b1001:qout_4<=7'b0010000;
		default:qout_4<=7'b1111111;
		endcase
	end 
end

always@(hourL)
begin
	if(set_alarm==0)
	begin
		case(hourL)
			4'b0000:qout_5<=7'b1000000;
			4'b0001:qout_5<=7'b1111001;
			4'b0010:qout_5<=7'b0100100;
			4'b0011:qout_5<=7'b0110000;
			4'b0100:qout_5<=7'b0011001;
			4'b0101:qout_5<=7'b0010010;
			4'b0110:qout_5<=7'b0000010;
			4'b0111:qout_5<=7'b1111000;
			4'b1000:qout_5<=7'b0000000;
			4'b1001:qout_5<=7'b0010000;
		default:qout_5<=7'b1111111;
		endcase
	end
	else if(set_alarm==1)
	begin
		case(alarm_hourL)
			4'b0000:qout_5<=7'b1000000;
			4'b0001:qout_5<=7'b1111001;
			4'b0010:qout_5<=7'b0100100;
			4'b0011:qout_5<=7'b0110000;
			4'b0100:qout_5<=7'b0011001;
			4'b0101:qout_5<=7'b0010010;
			4'b0110:qout_5<=7'b0000010;
			4'b0111:qout_5<=7'b1111000;
			4'b1000:qout_5<=7'b0000000;
			4'b1001:qout_5<=7'b0010000;
		default:qout_5<=7'b1111111;
		endcase
	end
end

always@(hourH)
begin
	if(set_alarm==0)
	begin
		case(hourH)
			4'b0000:qout_6<=7'b1000000;
			4'b0001:qout_6<=7'b1111001;
			4'b0010:qout_6<=7'b0100100;
			4'b0011:qout_6<=7'b0110000;
			4'b0100:qout_6<=7'b0011001;
			4'b0101:qout_6<=7'b0010010;
			4'b0110:qout_6<=7'b0000010;
			4'b0111:qout_6<=7'b1111000;
			4'b1000:qout_6<=7'b0000000;
			4'b1001:qout_6<=7'b0010000;
		default:qout_6<=7'b1111111;
		endcase
	end 
	else if(set_alarm==1)
	begin
		case(alarm_hourH)
			4'b0000:qout_6<=7'b1000000;
			4'b0001:qout_6<=7'b1111001;
			4'b0010:qout_6<=7'b0100100;
			4'b0011:qout_6<=7'b0110000;
			4'b0100:qout_6<=7'b0011001;
			4'b0101:qout_6<=7'b0010010;
			4'b0110:qout_6<=7'b0000010;
			4'b0111:qout_6<=7'b1111000;
			4'b1000:qout_6<=7'b0000000;
			4'b1001:qout_6<=7'b0010000;
		default:qout_6<=7'b1111111;
		endcase
	end 
end



//模块9:lcd液晶屏显示//



//-----------------lcd显示开始---------------------
//译码开始
reg [7:0]secL_lcd;
reg [7:0]secH_lcd;
reg [7:0]minL_lcd;
reg [7:0]minH_lcd;
reg [7:0]hourL_lcd;
reg [7:0]hourH_lcd;

always@(secL)
begin
	begin
		case(secL)
			4'b0000:secL_lcd<=8'b00110000;
			4'b0001:secL_lcd<=8'b00110001;
			4'b0010:secL_lcd<=8'b00110010;
			4'b0011:secL_lcd<=8'b00110011;
			4'b0100:secL_lcd<=8'b00110100;
			4'b0101:secL_lcd<=8'b00110101;
			4'b0110:secL_lcd<=8'b00110110;
			4'b0111:secL_lcd<=8'b00110111;
			4'b1000:secL_lcd<=8'b00111000;
			4'b1001:secL_lcd<=8'b00111001;
		default:secL_lcd<=8'b00100000;
		endcase
	end 
end

always@(secH)
begin
	begin
		case(secH)
			4'b0000:secH_lcd<=8'b00110000;
			4'b0001:secH_lcd<=8'b00110001;
			4'b0010:secH_lcd<=8'b00110010;
			4'b0011:secH_lcd<=8'b00110011;
			4'b0100:secH_lcd<=8'b00110100;
			4'b0101:secH_lcd<=8'b00110101;
			4'b0110:secH_lcd<=8'b00110110;
			4'b0111:secH_lcd<=8'b00110111;
			4'b1000:secH_lcd<=8'b00111000;
			4'b1001:secH_lcd<=8'b00111001;
		default:secH_lcd<=8'b00100000;
		endcase
	end 
end

always@(minL)
begin
	begin
		case(minL)
			4'b0000:minL_lcd<=8'b00110000;
			4'b0001:minL_lcd<=8'b00110001;
			4'b0010:minL_lcd<=8'b00110010;
			4'b0011:minL_lcd<=8'b00110011;
			4'b0100:minL_lcd<=8'b00110100;
			4'b0101:minL_lcd<=8'b00110101;
			4'b0110:minL_lcd<=8'b00110110;
			4'b0111:minL_lcd<=8'b00110111;
			4'b1000:minL_lcd<=8'b00111000;
			4'b1001:minL_lcd<=8'b00111001;
		default:minL_lcd<=8'b00100000;
		endcase
	end 
end

always@(minH)
begin
	begin
		case(minH)
			4'b0000:minH_lcd<=8'b00110000;
			4'b0001:minH_lcd<=8'b00110001;
			4'b0010:minH_lcd<=8'b00110010;
			4'b0011:minH_lcd<=8'b00110011;
			4'b0100:minH_lcd<=8'b00110100;
			4'b0101:minH_lcd<=8'b00110101;
			4'b0110:minH_lcd<=8'b00110110;
			4'b0111:minH_lcd<=8'b00110111;
			4'b1000:minH_lcd<=8'b00111000;
			4'b1001:minH_lcd<=8'b00111001;
		default:minH_lcd<=8'b00100000;
		endcase
	end 
end

always@(hourL)
begin
	begin
		case(hourL)
			4'b0000:hourL_lcd<=8'b00110000;
			4'b0001:hourL_lcd<=8'b00110001;
			4'b0010:hourL_lcd<=8'b00110010;
			4'b0011:hourL_lcd<=8'b00110011;
			4'b0100:hourL_lcd<=8'b00110100;
			4'b0101:hourL_lcd<=8'b00110101;
			4'b0110:hourL_lcd<=8'b00110110;
			4'b0111:hourL_lcd<=8'b00110111;
			4'b1000:hourL_lcd<=8'b00111000;
			4'b1001:hourL_lcd<=8'b00111001;
		default:hourL_lcd<=8'b00100000;
		endcase
	end 
end

always@(hourH)
begin
	begin
		case(hourH)
			4'b0000:hourH_lcd<=8'b00110000;
			4'b0001:hourH_lcd<=8'b00110001;
			4'b0010:hourH_lcd<=8'b00110010;
			4'b0011:hourH_lcd<=8'b00110011;
			4'b0100:hourH_lcd<=8'b00110100;
			4'b0101:hourH_lcd<=8'b00110101;
			4'b0110:hourH_lcd<=8'b00110110;
			4'b0111:hourH_lcd<=8'b00110111;
			4'b1000:hourH_lcd<=8'b00111000;
			4'b1001:hourH_lcd<=8'b00111001;
		default:hourH_lcd<=8'b00100000;
		endcase
	end 
end
//译码结束	

reg LCD_EN_Sel;
wire[127:0] data_row1,data_row2;
assign  LCD_ON = 1'b1;
	
//------------------------------------//
//输入时钟50MHz  输出周期2ms
//分频模块
reg [15:0]lcd_count;
reg clk_2ms;//2ms输出时钟
always @ (posedge clk)
begin
	if(lcd_count <16'd50_000)
		lcd_count <= lcd_count + 1'b1;
	else
	begin
		lcd_count <= 16'd1;
		clk_2ms <= ~clk_2ms;
	end
end
	
//---------------------------------------//
reg     [127:0] Data_Buf;   	//液晶显示的数据缓存
reg     [4:0] disp_count;
reg     [3:0] state;

parameter   Clear_Lcd		  = 4'b0000, //清屏并光标复位 
      		Set_Disp_Mode     = 4'b0001, //设置显示模式：8位2行5x7点阵   
           	Disp_On           = 4'b0010, //显示器开、光标不显示、光标不允许闪烁
            Shift_Down        = 4'b0011, //文字不动，光标自动右移
            Write_Addr        = 4'b0100, //写入显示起始地址
            Write_Data_First  = 4'b0101, //写入第一行显示的数据
            Write_Data_Second = 4'b0110; //写入第二行显示的数据		
		
assign  RW = 1'b0;  	//RW=0时对LCD模块执行写操作(一直保持写状态）
assign  LCD_EN = LCD_EN_Sel ? clk_2ms : 1'b0;//通过LCD_EN_Sel信号来控制LCD_EN的开启与关闭
assign  data_row1="YANGTIMING-TIME:";
assign  data_row2 = {{4{8'b00100000}},hourH_lcd,hourL_lcd,{8'b00111010},minH_lcd,minL_lcd,{8'b00111010},secH_lcd,secL_lcd,{4{8'b00100000}}};//"####HH:MM:SS####"

always @(posedge clk_2ms or posedge rst)
begin
	if(rst)
	begin
		state <= Clear_Lcd;  //复位：清屏并光标复位   
		RS <= 1'b1;          //复位：RS=1时为读指令；                       
		DB8 <= 8'b0;         //复位：使DB8总线输出全0
		LCD_EN_Sel <= 1'b0;  //复位：关液晶使能信号
		disp_count <= 5'b0;
		//---------下面是测试数据------------------------//
	end
	else 
	begin
		case(state)         //初始化LCD模块
				
			Clear_Lcd:
	        begin
				LCD_EN_Sel <= 1'b1;		//开使能
				RS <= 1'b0;				//写指令
	            DB8 <= 8'b0000_0001;  	//清屏并光标复位
				state <= Set_Disp_Mode;
	        end
			
			Set_Disp_Mode:
			begin
				DB8 <= 8'b0011_1000;   	//设置显示模式：8位2行5x8点阵 
				state <= Disp_On;
			end
					
			Disp_On:
			begin
				DB8 <= 8'b0000_1100;   	//显示器开、光标不显示、光标不允许闪烁 
				state <= Shift_Down;
			end
					
			Shift_Down:
			begin
				DB8 <= 8'b0000_0110;    	//文字不动，光标自动右移    
				state <= Write_Addr;
			end
					
			//---------------------------------显示循环------------------------------------//		
			Write_Addr:
			begin
				RS <= 1'b0;//写指令
				DB8 <= 8'b1000_0000;      //写入第一行显示起始地址：第一行第1个位置    
				Data_Buf <= data_row1;     //将第一行显示的数据赋给Data_First_Buf
				state <= Write_Data_First;
			end
					
			Write_Data_First:  //写第一行数据
			begin
				if(disp_count == 5'd16)    //disp_count等于15时表示第一行数据已写完
				begin
					RS <= 1'b0;//写指令
					DB8 <= 8'b1100_0000;     //送入写第二行的指令,第2行第1个位置
					disp_count <= 5'b00000; //计数清0
					Data_Buf <= data_row2;//将第2行显示的数据赋给Data_First_Buf
					state <= Write_Data_Second;   //写完第一行进入写第二行状态
				end
				else//没写够16字节
				begin
					RS <= 1'b1;    //RS=1表示写数据
					DB8 <= Data_Buf[127:120];
					Data_Buf <= (Data_Buf << 8);
					disp_count <= disp_count + 1'b1;
					state <= Write_Data_First;
				end
			end
					
			Write_Data_Second: //写第二行数据
			begin
				if(disp_count == 5'd16)//数据写完了
				begin
					RS <= 1'b0;//写指令
					DB8 <= 8'b1000_0000;      //写入第一行显示起始地址：第一行第1个位置
					disp_count <= 5'b00000; 
					state <= Write_Addr;   //重新循环
				end
				else//
				begin		
					RS <= 1'b1;
					DB8 <= Data_Buf[127:120];
					Data_Buf <= (Data_Buf << 8);
					disp_count <= disp_count + 1'b1;
					state <= Write_Data_Second; 
				end              
			end
					
			//--------------------------------------------------------------------------//		
			default:  state <= Clear_Lcd; //若state为其他值，则将state置为Clear_Lcd 
		endcase 
	end
end






endmodule

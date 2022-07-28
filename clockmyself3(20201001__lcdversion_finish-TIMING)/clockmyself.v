module clockmyself(
	input 		clk,					 //			--�ܵ�clk����50mhz��ʯӢ����			------->PIN_N2 
	input 		option_pattern,	    	 //			�����ֶ�����ʱ����İ�ť				--------->KEY3--PIN_W2
	input 		up_switch,				//			����ѡ���ֶ�ʱ����a=a+1����			-------->KEY2--PIN_p23
	
	input 		set_mod,				//													--------->sw1--PIN_N26
	
	input 		set_alarm,				//*			 �Զ���ʱ��set_mod==1					--------->sw0--PIN_N25
										//* 		�ֶ���ʱ��set_mod==0 �� set_alarm==0//
										//* 		�ֶ��������ӣ�set_mod==0 �� set_alarm==1//
										
	output reg  blink,       			//          ���㱨ʱģ��output->blinking//			--------->LEDR0--PIN_AE23
	
	
    output reg 	[6:0]qout_recnt,		//          ���������������ʾ����ʱ//        				==>HEX0����ɣ�
	input	   	recout,         		//          �����Ƿ񵹼�ʱ//						--------->SW17--PIN_V2
	output reg 	alarm_sound,    		//			��ʾ�����Ƿ���״̬.led show//			--------->LEDR1--PIN_AF23

	
	//ʱ�������������
	output reg [6:0]qout_1,		//==>HEX2����ɣ�
	output reg [6:0]qout_2,		//==>HEX3����ɣ�
	output reg [6:0]qout_3,		//==>HEX4����ɣ�
	output reg [6:0]qout_4,		//==>HEX5����ɣ�
	output reg [6:0]qout_5,		//==>HEX6����ɣ�
	output reg [6:0]qout_6,		//==>HEX7����ɣ�
	output reg clk_div,			//fenping
	output reg [1:0]option_1,   //chice led
	
	
	
	
	//lcd��input��output
			input   rst,       			//rstΪȫ�ָ�λ�źţ��ߵ�ƽ��Ч��
	
			output  LCD_EN,LCD_ON,		//LCD_ENΪLCDģ���ʹ���źţ��½��ش�����
			output  reg RS,					//RS=0ʱΪдָ�RS=1ʱΪд����
			output  RW,					//RW=0ʱ��LCDģ��ִ��д������RW=1ʱ��LCDģ��ִ�ж�����
			output reg [7:0] DB8		//8λָ�����������
	
	);
	

	//---��Ƶģ��1--//
parameter n= 49999999;//--ѡ��50Mhz��ʯӢ����--//
reg [30:0]div_cnt;
//reg clk_div;
always @(posedge clk )
begin 
	if(div_cnt==n)
	begin 
		div_cnt<=0;
		clk_div<=1;//--��50mHZ�ֳ�50m��---//
	end
	
	else
	begin 
		div_cnt<=div_cnt+1;
		clk_div<=0;
	end
end





//--ģ��2���Զ���ʱģ��--//
//--ʵ�� 00��00��00 ==> 23��59��59 ��ѭ����ʱ���ʱ--//
//����һ��flag�������ƴ�ģ��//
	
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
	//23��59��59
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
	//--no-23��59��59->����//
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
	//--���ֶ��������ʱ������Զ���ʱ--//
	secL_1<=secL_2;
	secH_1<=secH_2;
	minL_1<=minL_2;
	minH_1<=minH_2;
	hourL_1<=hourL_2;
	hourH_1<=hourH_2;
	
end
end



//--ģ��3:�ֶ���ʱģ��--//
//--ģ��3_1:�ֶ�����ʱ����ѡ��--//
//--pattern_set==0��ʾ�ֶ�����;	pattern_set==1��ʾ�ֶ�����;	pattern_set==2��ʾ��ʱ-//

always@(posedge option_pattern)
begin
	if(option_1==3)
		begin option_1<=0; end
	else
	begin 	option_1<=option_1+1; end
end



//--ģ��3_2:�ֶ�����ʱģ��--//

reg [3:0]secL_2;
reg [3:0]secH_2;
reg [3:0]minL_2;
reg [3:0]minH_2;
reg [3:0]hourL_2;
reg [3:0]hourH_2;

always@(posedge  up_switch)
begin

//�ֶ�Уʱģʽ
if(set_mod==0 && set_alarm==0)		//--�ֶ���ʱ��set_mod==0 �� set_alarm==0--//
begin 
	//23��59��59//
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
	//--no-23��59��59->����--//
	//option_1==0-->����//
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

	//option_1==1-->����//
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
	//--option_1==1-->��ʱ--//
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



if(set_mod==0 && set_alarm==1)	//�ֶ��������ӣ�set_mod==0 �� set_alarm==1//
begin
	//23��59��59//
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
	//--no-23��59��59->����--//
	//����
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
	//����
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
	//��ʱ
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


//ģ��4����ʱ���ģ��//
	//��Ϊ����ܵ�����
reg [3:0]secL;
reg [3:0]secH;
reg  [3:0]minL;
reg [3:0]minH;
reg [3:0]hourL;
reg [3:0]hourH;
// ��ģ����������1s����һ�Σ�������ϵ�ʾ��Ҳ������1s����һ�� //
always@(secL_1 or secH_1 or minL_1 or minH_1 or hourL_1 or hourH_1 or secL_2 or secH_2 or minL_2 or minH_2 or hourL_2 or hourH_2)
begin
	//�Զ�����ģʽ
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
	//�ֶ�����ģʽ
	if(set_mod==0 && set_alarm==0)		//�ֶ���ʱ��set_mod==0 �� set_alarm==0//
	begin
		secL<=secL_2;
		secH<=secH_2;
		minL<=minL_2;
		minH<=minH_2;
		hourL<=hourL_2;
		hourH<=hourH_2;
	end
end


//ģ��5�����㱨ʱģ��//

//--��59��50��00��00��������1Ϊ��ʼ��0-1���У���Ӧָʾ�Ƽ��Ϊ2s����˸--//
always @(secL)
begin
	if(minH==5 && minL== 9 && secH== 5) //--�첽��˸--//
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

//ģ��6������ʱģ��//
//����ʱ��˸ģ��//
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
always @(recnt)//���������������ʾ����ʱ//
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

//ģ��7�������趨ģ������Ӵ���ģ��//
//�����趨ʱ��Ŀ��ӻ�
reg [3:0]alarm_secL;
reg [3:0]alarm_secH;
reg [3:0]alarm_minL;
reg [3:0]alarm_minH;
reg [3:0]alarm_hourL;
reg [3:0]alarm_hourH;
//���Ӵ�����ʼ���ж������趨ʱ�� �Ƿ���� ���ڵ�ʱ�䣬����������//
reg [3:0]alarm_cnt;
always@(secL)
begin
	alarm_sound<=1'b0;
	if( minL==alarm_minL && minH==alarm_minH && hourL==alarm_hourL && hourH==alarm_hourH)
	begin
		alarm_sound<=1'b1;
	end
end
//ģ��8�����ӻ������ģ��//
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



//ģ��9:lcdҺ������ʾ//



//-----------------lcd��ʾ��ʼ---------------------
//���뿪ʼ
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
//�������	

reg LCD_EN_Sel;
wire[127:0] data_row1,data_row2;
assign  LCD_ON = 1'b1;
	
//------------------------------------//
//����ʱ��50MHz  �������2ms
//��Ƶģ��
reg [15:0]lcd_count;
reg clk_2ms;//2ms���ʱ��
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
reg     [127:0] Data_Buf;   	//Һ����ʾ�����ݻ���
reg     [4:0] disp_count;
reg     [3:0] state;

parameter   Clear_Lcd		  = 4'b0000, //��������긴λ 
      		Set_Disp_Mode     = 4'b0001, //������ʾģʽ��8λ2��5x7����   
           	Disp_On           = 4'b0010, //��ʾ��������겻��ʾ����겻������˸
            Shift_Down        = 4'b0011, //���ֲ���������Զ�����
            Write_Addr        = 4'b0100, //д����ʾ��ʼ��ַ
            Write_Data_First  = 4'b0101, //д���һ����ʾ������
            Write_Data_Second = 4'b0110; //д��ڶ�����ʾ������		
		
assign  RW = 1'b0;  	//RW=0ʱ��LCDģ��ִ��д����(һֱ����д״̬��
assign  LCD_EN = LCD_EN_Sel ? clk_2ms : 1'b0;//ͨ��LCD_EN_Sel�ź�������LCD_EN�Ŀ�����ر�
assign  data_row1="YANGTIMING-TIME:";
assign  data_row2 = {{4{8'b00100000}},hourH_lcd,hourL_lcd,{8'b00111010},minH_lcd,minL_lcd,{8'b00111010},secH_lcd,secL_lcd,{4{8'b00100000}}};//"####HH:MM:SS####"

always @(posedge clk_2ms or posedge rst)
begin
	if(rst)
	begin
		state <= Clear_Lcd;  //��λ����������긴λ   
		RS <= 1'b1;          //��λ��RS=1ʱΪ��ָ�                       
		DB8 <= 8'b0;         //��λ��ʹDB8�������ȫ0
		LCD_EN_Sel <= 1'b0;  //��λ����Һ��ʹ���ź�
		disp_count <= 5'b0;
		//---------�����ǲ�������------------------------//
	end
	else 
	begin
		case(state)         //��ʼ��LCDģ��
				
			Clear_Lcd:
	        begin
				LCD_EN_Sel <= 1'b1;		//��ʹ��
				RS <= 1'b0;				//дָ��
	            DB8 <= 8'b0000_0001;  	//��������긴λ
				state <= Set_Disp_Mode;
	        end
			
			Set_Disp_Mode:
			begin
				DB8 <= 8'b0011_1000;   	//������ʾģʽ��8λ2��5x8���� 
				state <= Disp_On;
			end
					
			Disp_On:
			begin
				DB8 <= 8'b0000_1100;   	//��ʾ��������겻��ʾ����겻������˸ 
				state <= Shift_Down;
			end
					
			Shift_Down:
			begin
				DB8 <= 8'b0000_0110;    	//���ֲ���������Զ�����    
				state <= Write_Addr;
			end
					
			//---------------------------------��ʾѭ��------------------------------------//		
			Write_Addr:
			begin
				RS <= 1'b0;//дָ��
				DB8 <= 8'b1000_0000;      //д���һ����ʾ��ʼ��ַ����һ�е�1��λ��    
				Data_Buf <= data_row1;     //����һ����ʾ�����ݸ���Data_First_Buf
				state <= Write_Data_First;
			end
					
			Write_Data_First:  //д��һ������
			begin
				if(disp_count == 5'd16)    //disp_count����15ʱ��ʾ��һ��������д��
				begin
					RS <= 1'b0;//дָ��
					DB8 <= 8'b1100_0000;     //����д�ڶ��е�ָ��,��2�е�1��λ��
					disp_count <= 5'b00000; //������0
					Data_Buf <= data_row2;//����2����ʾ�����ݸ���Data_First_Buf
					state <= Write_Data_Second;   //д���һ�н���д�ڶ���״̬
				end
				else//ûд��16�ֽ�
				begin
					RS <= 1'b1;    //RS=1��ʾд����
					DB8 <= Data_Buf[127:120];
					Data_Buf <= (Data_Buf << 8);
					disp_count <= disp_count + 1'b1;
					state <= Write_Data_First;
				end
			end
					
			Write_Data_Second: //д�ڶ�������
			begin
				if(disp_count == 5'd16)//����д����
				begin
					RS <= 1'b0;//дָ��
					DB8 <= 8'b1000_0000;      //д���һ����ʾ��ʼ��ַ����һ�е�1��λ��
					disp_count <= 5'b00000; 
					state <= Write_Addr;   //����ѭ��
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
			default:  state <= Clear_Lcd; //��stateΪ����ֵ����state��ΪClear_Lcd 
		endcase 
	end
end






endmodule

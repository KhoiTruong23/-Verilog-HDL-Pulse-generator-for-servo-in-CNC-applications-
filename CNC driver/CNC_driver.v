module CNC_driver (clk,WR,LS,Nx,N,Pulse,flag_T,clk1,pinout,acc,buffer1,buffer2,buffer3,buffer4,Nbuff,flag_full,Nx_temp_test,temp1,temp2,temp3,temp4,allow_once,wait_to_write);
input clk,WR,LS;
input [7:0] N,Nx;
output Pulse;
//output reg [7:0] Nx_temp; 
output wire [7:0] Nx_temp_test; 
output reg flag_T;
output reg  clk1,pinout;
output reg allow_once; 
output reg [7:0] wait_to_write; 
output reg [7:0] acc,buffer1,buffer2,buffer3,buffer4;
reg [15:0] cnt1,cnt2;
output reg [2:0] Nbuff;
output reg flag_full; 
reg [2:0] posi; 
 reg pre_flag_full; 
reg pre_flag,pre_WR,pre_WR_clk1 ;
output reg [7:0] temp1; 
reg just_return; 
reg pre_LS; 
output reg [7:0] temp2; 
output reg [7:0] temp3; 
output reg [7:0] temp4; 

initial begin
Nbuff <= 0;
	temp1 = 8'h00; 
	temp2 = 8'h00; 
	temp3 = 8'h00; 
	temp4 = 8'h00;
posi <= 1; 
//{pre_flag_full,flag_full} <= 2'b00;
end
always@(posedge clk) begin 		
	
	pre_flag_full <= flag_full;
	pre_WR <= WR;
	
	if (LS == 1) begin 
	buffer1 = 0; 
	buffer2 = 0; 
	buffer3 = 0; 
	buffer4 = 0; 

	end
	

		//done
	cnt1 <= cnt1 +1;
	if (cnt1 <1000)
		flag_T <= 1;
	else if (cnt1 ==2000) 
		cnt1 <=0;
	else 
		flag_T <= 0;
	cnt2 <= cnt2 +1;
	if (cnt2 <50)
		clk1 <= 0;
	else if (cnt2 ==99) 
		cnt2 <=0;
	else 
		clk1 <= 1;

		
if ({pre_flag,flag_T} == 2'b10 || {pre_flag,flag_T} == 2'b01) begin // I use N_temp as wire for DDA algorithm cause I want to update N_temp immediately right after cycle 

	
	allow_once = 1;  // use to know done 1 cycle

	if (Nbuff ==5 && allow_once ==1) begin  // when Nbuff is 5 and we done current cycle, we reset Nbuff to 0, pull down flag_full and pull up just_return flag
		Nbuff =0;
		flag_full = 0;
		just_return = 1; 
		end

	if (wait_to_write == 0 && Nx ==0 && allow_once ==1  ) begin  // when Nbuff is 5 and we done current cycle, we reset Nbuff to 0, pull down flag_full and pull up just_return flag
		Nbuff =0;
		just_return = 1; 
		end
	
	if(posi == 1 & buffer1 != 0) begin 	
	temp1 = 8'hff; 
	temp2 = 8'h00; 
	temp3 = 8'h00; 
	temp4 = 8'h00; 
	
	end
	
	else if(posi == 2 & buffer2 != 0) begin  
	temp2 = 8'hff; 
	temp1 = 8'h00; 
	temp3 = 8'h00; 
	temp4 = 8'h00; 
	end
	
	else if(posi == 3 & buffer3 != 0) begin
	temp3 = 8'hff; 
	temp1 = 8'h00; 
	temp2 = 8'h00; 
	temp4 = 8'h00; 
	
	 end
	 
	else if(posi == 4 & buffer4 != 0) begin
	 temp4 = 8'hff; 
	 temp1 = 8'h00; 
	 temp2 = 8'h00; 
	 temp3 = 8'h00; 
		 end

		
end
else begin allow_once = 0; end

if ({pre_WR,WR} == 2'b01 && buffer1 == 0 && buffer2 == 0 && buffer3 == 0 && buffer4 == 0 && LS == 0) begin 
	Nbuff = 0; end
	

if ({pre_WR,WR} == 2'b01 ) begin 

	if(Nbuff< 5  ) begin
			case (Nbuff)
			3'b000: begin 
					buffer1 = Nx;
					
					end
			3'b001: begin 
					buffer2 = Nx;
	
					end
			3'b010: begin 
					buffer3 = Nx;
				
					end
			3'b011: begin 
					buffer4 = Nx;
					flag_full =1; 
				
					end
		endcase
		end
		if  ( Nbuff<5)begin	
			if(just_return == 0) begin 	
			Nbuff=Nbuff +1; end
			else if(just_return == 1) begin 	//when Nbuff just return to 0 when flag_full is down, dont add 1 to Nbuff yet 
			just_return =0;
			Nbuff=Nbuff +1; 
			end 
			end
		
end

if(wait_to_write ==0 && Nbuff == 0 && Nx ==0 ) begin  // when Nbuff = 0 and Nx = 0 and not any waiting buffer , pulse is forced to be 0; 
	buffer1 = 0; 
	buffer2 = 0; 
	buffer3 = 0; 
	buffer4 = 0; 
	temp1 = 8'h00; 
	temp2 = 8'h00; 
	temp3 = 8'h00; 
	temp4 = 8'h00; 
	end 

end

always@(posedge clk1) begin     /// ONLY FOR DDA
pre_flag <= flag_T;
pre_WR_clk1 <= pre_WR_clk1;
	pre_LS <= LS; 


if ({pre_WR_clk1,WR} == 2'b01 ) begin 
	
if(flag_full ==0)begin wait_to_write = wait_to_write +1; end  // Use to know how many buffer we still need to generate pulse
 
end

if ({pre_LS,LS} == 2'b01) begin
	wait_to_write = 0; end
if ({pre_LS,LS} == 2'b10) begin
	posi = 1; end
		
if ({pre_flag,flag_T} == 2'b10 || {pre_flag,flag_T} == 2'b01) begin

	
	if(posi == 1 & buffer1 != 0) begin 
	acc = N;  
	posi=posi +1;
	if (wait_to_write>=0)begin
	wait_to_write = wait_to_write -1; end
	end
	
	else if(posi == 2 & buffer2 != 0) begin 
	acc = N; 
	
	 posi=posi +1;
	 if (wait_to_write>=0)begin
	wait_to_write = wait_to_write -1; end
	end
	
	else if(posi == 3 & buffer3 != 0) begin
	 acc = N; 
	 posi=posi +1;
	if (wait_to_write>=0)begin
	wait_to_write = wait_to_write -1; end
	 end
	 
	else if(posi == 4 & buffer4 != 0) begin
	acc = N; 
	 posi=1;
	 if (wait_to_write>=0)begin
	wait_to_write = wait_to_write -1; end
	 end
end 
	
	
	if(posi >4) begin posi = 0; end		
		acc = acc + Nx_temp_test;	
		if (acc>N) begin	
			acc = acc - N;
			pinout=1;
		end
		else pinout=0;
	end

	




assign Nx_temp_test = (buffer1 & temp1 ) | (buffer2 & temp2 ) | (buffer3 & temp3 ) | (buffer4 & temp4 ) ;
assign Pulse = (~clk1 & pinout) && ~LS;
endmodule

`timescale 1ns/1ns

module vendingMachine(clock, reset, coin_c, MnM, KitKat, Lays, Doritos, Coke, prod_out, hex0, hex1, hex2, hex3, hex4, hex5, change);
	
	input clock;
	input reset;
	input wire [2:0]coin_c;
	input MnM, KitKat, Lays, Doritos, Coke;
	
	output reg prod_out;
	output reg [7:0] hex0, hex1, hex2, hex3, hex4, hex5;
	
	reg [2:0]state,next_state;
	reg prod; 
	output reg [2:0]change;
	
	wire out_en;
	wire [63:0] out;
	wire A, B, C, D, E;
	wire [2:0]coin;
	
	//Change defined as parameter
	parameter [2:0] zero=3'b000;
	parameter [2:0] nickel=3'b001;
	parameter [2:0] dime=3'b010;
	parameter [2:0] nickel_dime=3'b011;
	parameter [2:0] dime_dime=3'b100;
	parameter [2:0] quarter=3'b101;

	//States defined as parameter
	parameter [2:0] IDLE=3'b000;
	parameter [2:0] FIVE=3'b001;
	parameter [2:0] TEN=3'b010;
	parameter [2:0] FIFTEEN=3'b011;
	parameter [2:0] TWENTY=3'b100;
	parameter [2:0] TWENTYFIVE=3'b101;
	parameter [2:0] THIRTY = 3'b110;
	

	//Coins defined as parameter
	parameter [2:0] Ni = 3'b001;
	parameter [2:0] Di = 3'b010;
	parameter [2:0] Qu = 3'b100;


	//Debouced module (written below) instantiated here for products and input currencies
	debounce Adb(MnM,clock,reset,A);
	debounce Bdb(KitKat,clock,reset,B);
	debounce Cdb(Lays,clock,reset,C);
	debounce Ddb(Doritos,clock,reset,D);
	debounce Edb(Coke,clock,reset,E);
	debounce Dimedb(coin_c[1],clock,reset,coin[1]);
	debounce Nickeldb(coin_c[0],clock,reset,coin[0]);
	debounce Quarterdb(coin_c[2],clock,reset,coin[2]);
	

	//FSM design
	always @(state or coin)
	begin 
	case(state)
		IDLE: case(coin) 
			Ni: next_state=FIVE;
			Di: next_state=TEN;
			Qu: next_state=TWENTYFIVE;
			default: next_state=IDLE;
	endcase
		FIVE: case(coin) 
			Ni: next_state=TEN;
			Di: next_state=FIFTEEN;
			Qu: next_state=TWENTYFIVE; 
			default: next_state=FIVE;
	endcase
		TEN: case(coin) 
			Ni: next_state=FIFTEEN;
			Di: next_state=TWENTY;
			Qu: next_state=TWENTYFIVE;
			default: next_state=TEN;
	endcase
		FIFTEEN: case(coin)
			Ni: next_state=TWENTY;
			Di: next_state=TWENTYFIVE;
			Qu: next_state=TWENTYFIVE; 
			default: next_state=FIFTEEN;
	endcase
		TWENTY: case(coin) 
			Ni: next_state=TWENTYFIVE;
			Di: next_state=THIRTY; 
			Qu: next_state=TWENTYFIVE; 
			default: next_state=TWENTY;
	endcase
		TWENTYFIVE: next_state=TWENTYFIVE;
		THIRTY: next_state=THIRTY;
		default : next_state=IDLE;
	endcase
	end
	

	always @(posedge clock)
	begin 
		if(reset) begin
			state <= IDLE;
			
		end
		else begin 
			state <= next_state;end
		end
	
	//prod_flag holds the state until the required amount is received
	reg [4:0] prod_flag;
	always @(posedge clock)
	begin
		if(reset) begin
			prod_flag <= 5'b00000;
			end
		else begin
			case({A,B,C,D,E})
				5'b00001: prod_flag <= 5'b00001;
				5'b00010: prod_flag <= 5'b00010;
				5'b00100: prod_flag <= 5'b00100;
				5'b01000: prod_flag <= 5'b01000;
				5'b10000: prod_flag <= 5'b10000;
				default : prod_flag <= prod_flag;
			endcase
		end
	end
	
	//counter c1(clock, prod, reset , out, out_en);
	always @(posedge clock)
	begin
		if(reset)
			prod_out <= 1'b0;
		else if(prod==1'b1)
			prod_out <= 1'b1;
		else 
			prod_out <= prod_out;
	end

	always @ (state or prod_flag) begin
	
	
	if(prod_flag==5'b00000) begin
		prod <= 1'b0;
		hex5 <= 8'b10111111; hex4 <= 8'b10111111;
		hex3 <= 8'b10111111;hex2 <= 8'b10111111;
		hex1 <= 8'b10111111;hex0 <= 8'b10111111;
	end

	// Product is Coke and price is 25 cents
	
	if (prod_flag==5'b00001) begin

		hex5 <= 8'b10100100; hex4 <= 8'b10010010;
		
		case (state)
			IDLE: begin 
				prod <= 1'b0; 
				change <=3'd0;
				hex3 <= 8'b10111111; hex2 <= 8'b10111111;
				hex1 <= 8'b10111111; hex0 <= 8'b10111111;
			end
			FIVE: begin 
				prod <= 1'b0;
				hex3 <= 8'b11000000; hex2 <= 8'b10010010;
				if (coin==quarter) begin 
					change <=nickel;
					hex3 <= 8'b10110000; hex2 <= 8'b11000000; 
					hex1 <= 8'b11000000; hex0 <= 8'b10010010;
				end
				else begin 
					change <=3'd0;
					hex1 <= 8'b11111001; hex0 <= 8'b10101011; 
				end 
			end
			TEN: begin 
				prod <= 1'b0;
				hex3 <= 8'b11111001; hex2 <= 8'b11000000;
				if (coin==quarter) begin 
					hex3 <= 8'b10110000; hex2 <= 8'b10010010;
					change <=dime;
					hex1 <= 8'b11111001; hex0 <= 8'b11000000; 
				end 
				else begin 
				change <= 3'd0; 
				hex1 <= 8'b11111001; hex0 <= 8'b10101011;
				end 
			end
			FIFTEEN : begin 
				prod <= 1'b0;
				hex3 <= 8'b11111001; hex2 <= 8'b10010010; 
				if (coin==quarter) begin 
					change <=nickel_dime; 
					hex3 <= 8'b10011001; hex2 <= 8'b11000000; 
					hex1 <= 11111001; hex0 <= 10010010; 
				end 
				else begin 
					change <= 3'd0; 
					hex1 <= 8'b11111001; hex0 <= 8'b10101011;
				end 
			end
			TWENTY : begin 
				prod <= 1'b0;
				hex3 <= 8'b10100100; hex2 <= 8'b11000000; 
				if (coin==dime) begin 
					change <=nickel; 
					hex3 <= 8'b10110000; hex2 <= 8'b11000000; 
					hex1 <= 8'b11000000; hex0 <= 8'b10010010;
				end 
				else if (coin==quarter) begin 
					hex3 <= 8'b10011001; hex2 <= 8'b10010010; 
					change <=dime_dime; 
					hex1 <= 8'b10100100; hex0 <= 8'b11000000;
				end 
				else begin 
					change <= 3'd0; 
					hex1 <= 8'b11111001; hex0 <= 8'b10101011;
				end 
			end
			TWENTYFIVE : begin 
				prod <= 1'b1; change <=3'd0; 
				hex3 <= 8'b10100100; hex2 <= 8'b10010010; 
				hex1 <= 8'b11000000; hex0 <= 8'b11000000; 
			end
			THIRTY : begin 
				prod <= 1'b1; change <= nickel; 
				hex3 <= 8'b10110000; hex2 <= 8'b11000000;
				hex1 <= 8'b11000000; hex0 <= 8'b10010010;
			end
			default: prod <= 1'b0;
		endcase
	end
	
	// Product is Doritos and price is 20 cents
	
	if (prod_flag==5'b00010) begin

		hex5 <= 8'b10100100; hex4 <= 8'b11000000;

		case (state) 
			IDLE: begin 
				prod <= 1'b0; change <=3'd0; 
				hex3 <= 8'b10111111; hex2 <= 8'b10111111; 
				hex1 <= 8'b10111111; hex0 <= 8'b10111111; 
			end
			FIVE: begin 
				prod <= 1'b0; 
				hex3 <= 8'b11000000; hex2 <= 8'b10010010;
				if (coin==quarter) begin 
					change <=dime; 
					hex3 <= 8'b10110000; hex2 <= 8'b11000000; 
					hex1 <= 8'b11111001; hex0 <= 8'b11000000;
				end 
				else begin 
					change <=3'd0; 
					hex1<= 8'b11111001; hex0 <= 8'b10101011; 
				end 
			end
			TEN: begin 
				prod <= 1'b0; 
				hex3 <= 8'b11111001; hex2 <= 8'b11000000; 
				if (coin==quarter) begin 
					change <=nickel_dime; 
					hex3 <= 8'b10110000; hex2 <= 8'b10010010; 
					hex1 <= 8'b11111001; hex0 <= 8'b10010010; 
				end  
				else begin 
					change <= 3'd0; 
					hex1<= 8'b11111001; hex0 <= 8'b10101011; 
				end  
			end
			FIFTEEN : begin 
				prod <= 1'b0; 
				hex3 <= 8'b11111001; hex2 <= 8'b10010010; 
				if(coin==dime) begin 
					change <=nickel; 
					hex3 <= 8'b10100100; hex2 <= 8'b10010010; 
					hex1 <= 8'b11000000; hex0 <= 8'b10010010;
				end 
				else if(coin==quarter) begin 
					change<= dime_dime; 
					hex3 <= 8'b10011001; hex2 <= 8'b11000000; 
					hex1<= 8'b10100100; hex0 <= 8'b11000000;
				end 
				else begin 
					change <= 3'd0; 
					hex1<= 8'b11111001; hex0 <= 8'b10101011; 
				end 
			end
			TWENTY : begin 
				prod <= 1'b1; change<= 3'd0; 
				hex3 <= 8'b10100100; hex2 <= 8'b11000000; 
				hex1 <= 8'b11000000; hex0 <= 8'b11000000;
			end
			TWENTYFIVE : begin 
				prod <= 1'b1; change <=nickel; 
				hex3 <= 8'b10100100; hex2 <= 8'b10010010; 
				hex1 <= 8'b11000000; hex0 <= 8'b10010010; 
			end
			default: prod <= 1'b0;
		endcase
	end

	// Product is Lays and price is 15 cents
	
	if (prod_flag==5'b00100) begin

		hex5 <= 8'b11111001; hex4 <= 8'b10010010;

		case (state)
			IDLE: begin 
				prod <= 1'b0; change <=3'd0; 
				hex3 <= 8'b10111111; hex2 <= 8'b10111111; 
				hex1 <= 8'b10111111; hex0 <= 8'b10111111;
			end
			FIVE: begin 
				prod <= 1'b0; 
				hex3 <= 8'b11000000; hex2 <= 8'b10010010;
				if (coin==quarter) begin 
					change <=nickel_dime; 
					hex3 <= 8'b10110000; hex2 <= 8'b11000000; 
					hex1 <= 8'b11111001; hex0 <= 8'b10100100;
				end 
				else begin 
					change <=3'd0; 
					hex1 <= 8'b11111001; hex0 <= 8'b10101011;
				end  
			end
			TEN: begin 
				prod <= 1'b0;
				hex3 <= 8'b11111001; hex2 <= 8'b11000000;
				if(coin==dime) begin 
					change <=nickel; 
					hex3 <= 8'b10100100; hex2 <= 8'b11000000;
					hex1 <= 8'b11000000;hex0 <= 8'b10010010; end
				else if(coin==quarter) begin
					change<= dime_dime; 
					hex3 <= 8'b10110000; hex2 <= 8'b10010010;
					hex1 <= 8'b10100100; hex0 <= 8'b11000000; end
				else begin change <=3'd0;
				hex1 <= 8'b11111001; hex0 <= 8'b10101011; 
				end 
			end
			FIFTEEN : begin 
				prod <= 1'b1;change<= 3'd0; 
				hex3 <= 8'b11111001; hex2 <= 8'b10010010; 
				hex1 <= 8'b11000000; hex0 <= 8'b11000000;
			end
			TWENTY : begin 
				prod <= 1'b1; change<= nickel;
				hex3 <= 8'b10100100; hex2 <= 8'b11000000; 
				hex1 <= 8'b11000000; hex0 <= 8'b10010010; 
			end
			TWENTYFIVE : begin 
				prod <= 1'b1; change <=dime;
				hex3 <= 8'b10100100; hex2 <= 8'b10010010;
				hex1 <= 8'b11111001; hex0 <= 8'b11000000;
			end
			default: prod <= 1'b0;
		endcase
	end
	
	//Product is KitKat and price is 10 cents

	if (prod_flag==5'b01000) begin

		hex5 <= 8'b11111001; hex4 <= 8'b11000000;

		case (state) 
			IDLE: begin 
				prod <= 1'b0; change <= 3'd0;
				hex3 <= 8'b10111111; hex2 <= 8'b10111111; 
				hex1 <= 8'b10111111; hex0 <= 8'b10111111;
			end
			FIVE: begin 
				prod <= 1'b0; 
				hex3 <= 8'b11000000; hex2 <= 8'b10010010; 
				if (coin==quarter) begin 
					change <=dime_dime; 
					hex3 <= 8'b10110000; hex2 <= 8'b11000000; 
					hex1 <= 8'b10100100; hex0 <= 8'b11000000; 
				end else begin 
					change <=3'd0; 
					hex1 <= 8'b11111001; hex0 <= 8'b10101011;
				end 
			end
			TEN: begin 
				prod <= 1'b1; change <= 3'd0; 
				hex3 <= 8'b11111001; hex2 <= 8'b11000000; 
				hex1 <= 8'b11000000; hex0 <= 8'b11000000; 
			end
			TWENTYFIVE : begin 
				prod <= 1'b1; change <=nickel_dime; 
				hex3 <= 8'b10100100; hex2 <= 8'b10010010; 
				hex1 <= 8'b11111001; hex0 <= 8'b10010010; 
			end
			default: prod <= 1'b0;
		endcase
	end
	
	//Product is MnM and price is 5 cents

	if (prod_flag==5'b10000) begin

		hex5 <= 8'b11000000; hex4 <= 8'b10010010;

		case (state) 
		IDLE: begin 
			prod <= 1'b0; change <=3'd0; 
			hex3 <= 8'b10111111; hex2 <= 8'b10111111; 
			hex1 <= 8'b10111111; hex0 <= 8'b10111111; 
		end
		FIVE: begin 
			prod <= 1'b1; change <= 3'd0;
			hex3 <= 8'b11000000; hex2 <= 8'b10010010; 
			hex1 <= 8'b11000000; hex0 <= 8'b11000000; 
		end
		TEN: begin 
			prod <= 1'b1; change <= nickel; 
			hex3 <= 8'b11111001; hex2 <= 8'b11000000; 
			hex1 <= 8'b11000000; hex0 <= 8'b10010010; 
		end
		TWENTYFIVE : begin 
			prod <= 1'b1; change <= dime_dime;
			hex3 <= 8'b10100100; hex2 <= 8'b10010010; 
			hex1 <= 8'b10100100; hex0 <= 8'b11000000; 
		end
		default: prod <= 1'b0; 
		endcase
	end
	end
	
endmodule


//Module to Debouce the input single

module debounce(in,clk,reset,out);
	input in,clk,reset;
	output out;
	reg dff1,dff2;

	always @(posedge clk)
	begin
		if(reset)
			{dff2,dff1} <= 2'b00;
		else
			{dff2,dff1} <= {dff1,in};
	end

	assign out = (dff1 & ~dff2);
endmodule

/*
//Module for counter

module counter (clk_50mhz, prod, reset , out, out_en);
	input clk_50mhz, reset,prod;
	output reg [63:0] out;
	output reg out_en;
	reg en;

	always @(posedge clk_50mhz)
	begin
		if(reset)
			en <= 1'b0;
		else if(prod==1'b1)
			en <= 1'b1;
		else 
			en <= en;
	end

	always @(posedge clk_50mhz) 
	begin
		if(reset) begin
			out <= 1'b0; out_en <= 1'b0; end
		else begin
			if(en) begin
				if (out == (50000000*2)) begin
					out <= out; out_en <= 1'b1; 
				end
				else if (out != (50000000*2)) begin
					out <= out + 64'h00000001; out_en <= 1'b0;
				end
			end
			else 
				out <= 'b0; out_en <= 1'b0;
		end 
	end
endmodule
*/
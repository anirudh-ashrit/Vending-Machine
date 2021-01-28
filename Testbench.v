`timescale 1ns/1ns

//Testbench for Vending Machine
module vendingMachine_tb();

	reg clock, reset, MnM, KitKat, Lays, Doritos, Coke;
	reg [2:0] coin_c;
	wire vend_out;
	wire [2:0] change;
	wire [7:0] hex0, hex1, hex2, hex3, hex4, hex5;
	
	//instantiating the design code for Vending Machine

	vendingMachine(clock, reset, coin_c, MnM, KitKat, Lays, Doritos, Coke, vend_out, hex0, hex1, hex2, hex3, hex4, hex5, change);

	initial begin
	clock =1;
	forever #10 clock =~clock;
	end

	initial begin
		coin_c = 3'b000;
		MnM =1;
		KitKat =0;
		Lays =0;
		Doritos =0;
		Coke =0;
		
		reset = 1;
		#18;
		reset = 0;
		coin_c = 3'b000;	
	//Testing for Product MnM. The price is 5 cents
	//Amount inserted is: 1 Nickel
		MnM = 1;
		#20;
		MnM = 0;
		coin_c=3'b010;
		#20;
		coin_c=3'b000;
		#60;

		reset = 1;
		#18;
		reset = 0;
		coin_c = 3'b000;
	//Testing for Product KitKat. The price is 10 cents
	//Amount inserted is: 1 Nickel
		KitKat = 1;
		#20;
		KitKat = 0;
		coin_c = 3'b001;
		#20;
		coin_c = 3'b000;
		#60;

		reset = 1;
		#18;
		reset = 0;
		coin_c = 3'b000;
	//Testing for Product Doritos. The price is 20 cents
	//Amount inserted is: 1 Quarter
		Doritos= 1;
		#20;
		Doritos = 0;
		coin_c = 3'b100;
		#20;
		coin_c = 3'b000;
		#60;

		reset = 1;
		#18;
		reset = 0;
		coin_c = 3'b000;
	//Testing for Product Coke. The price is 25 cents
	//Total amount inserted is: 3 Dimes.
		Coke =1;
		#20;
		Coke = 0;
		coin_c=3'b010;
		#20;
		coin_c=3'b000;
		#20;
		coin_c=3'b010;
		#20;
		coin_c=3'b000;
		#20;
		coin_c=3'b010;
		#20;
		coin_c=3'b000;
		#60;

		reset = 1;
		#12;
		reset = 0;
		coin_c = 3'b000;
	//Testing for Product Lays. The price is 15 cents
	//Amount inserted is: 1 Dime and 1 Nickel
		Lays = 1;
		#20;
		Lays = 0;
		coin_c = 3'b010;
		#20;
		coin_c = 3'b000;
		#20;
		coin_c = 3'b001;
		#20;
		coin_c = 3'b000;
		#60;

		reset = 1;
		#18;
		reset = 0;
		coin_c = 3'b000;
		#1000 $finish;
	end

	initial begin
		$dumpfile("vm.vcd");
		$dumpvars(0,vm_tb);
	end

endmodule
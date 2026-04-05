`define HEX_DIS_BLANK 7'b1111111
`define HEX_DIS_DASH 7'b0111111
`define HEX_DIS_0 7'b1000000
`define HEX_DIS_1 7'b1111001
`define HEX_DIS_2 7'b0100100
`define HEX_DIS_3 7'b0110000
`define HEX_DIS_4 7'b0011001
`define HEX_DIS_5 7'b0010010
`define HEX_DIS_6 7'b0000010
`define HEX_DIS_7 7'b1111000
`define HEX_DIS_8 7'b0000000
`define HEX_DIS_9 7'b0010000
`define HEX_DIS_A 7'b0001000
`define HEX_DIS_B 7'b0000011
`define HEX_DIS_C 7'b1001110
`define HEX_DIS_D 7'b0100001
`define HEX_DIS_E 7'b0000110
`define HEX_DIS_F 7'b0001110
`define RST_STATE 3'd0
`define WAIT_STATE 3'd1
`define START_CRACK_STATE 3'd2
`define CRACKING_STATE 3'd4
`define DONE_STATE 3'd5
`define STALL_CRACK_STATE 3'd3


module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

	logic [23:0] crack_key;
	logic [7:0] ct_addr, ct_rddata;
	logic [3:0] key_HEX0, key_HEX1, key_HEX2, key_HEX3, key_HEX4, key_HEX5;
	logic [2:0] state, next_state;  
	logic crack_key_valid, crack_en, crack_rdy;

	ct_mem ct( .address(ct_addr), .clock(CLOCK_50), .data(8'd5), .wren(1'd0), .q(ct_rddata) );
	crack c( .clk(CLOCK_50), .rst_n(KEY[3]),
             .en(crack_en), .rdy(crack_rdy),
             .key(crack_key), .key_valid(crack_key_valid),
             .ct_addr(ct_addr), .ct_rddata(ct_rddata));

	always_ff @(posedge CLOCK_50)begin
		if(!KEY[3]) begin
			state <= 3'd0;
		end
		else begin
			state <= next_state;
		end
	end

	//next-state logic
	always_comb begin
		case(state)
			`RST_STATE: begin
				next_state = state + 3'd1;
			end
			`WAIT_STATE: begin
				if(crack_rdy) next_state = state + 3'd1;
				else next_state = state;
			end
			`START_CRACK_STATE: begin
				next_state = state + 3'd1;
			end
			`STALL_CRACK_STATE: begin
				next_state = state + 3'd1;
			end
			`CRACKING_STATE: begin
				if(crack_rdy) next_state = state + 3'd1;
				else next_state = state;
			end
			`DONE_STATE: begin
				next_state = state;
			end
			default begin
				next_state = state;
			end
		endcase
	end
	//output logic
	always_comb begin
		//crack_en logic
		if(state == `START_CRACK_STATE) crack_en = 1'd1;
		else crack_en = 1'd0;
		//LEDR unused
		LEDR = 10'd0;
		//For breaking key value into hex numbers for display
		key_HEX0 = crack_key[3:0];
		key_HEX1 = crack_key[7:4];
		key_HEX2 = crack_key[11:8];
		key_HEX3 = crack_key[15:12];
		key_HEX4 = crack_key[19:16];
		key_HEX5 = crack_key[23:20];
		//defining hex display behaviour based on state, key_valid, and key via the key_HEXxs
		if(state == `DONE_STATE)begin
			if(crack_key_valid) begin
				case(key_HEX0)
					4'h0: HEX0 = `HEX_DIS_0;
					4'h1: HEX0 = `HEX_DIS_1;
					4'h2: HEX0 = `HEX_DIS_2;
					4'h3: HEX0 = `HEX_DIS_3;
					4'h4: HEX0 = `HEX_DIS_4;
					4'h5: HEX0 = `HEX_DIS_5;
					4'h6: HEX0 = `HEX_DIS_6;
					4'h7: HEX0 = `HEX_DIS_7;
					4'h8: HEX0 = `HEX_DIS_8;
					4'h9: HEX0 = `HEX_DIS_9;
					4'hA: HEX0 = `HEX_DIS_A;
					4'hB: HEX0 = `HEX_DIS_B;
					4'hC: HEX0 = `HEX_DIS_C;
					4'hD: HEX0 = `HEX_DIS_D;
					4'hE: HEX0 = `HEX_DIS_E;
					4'hF: HEX0 = `HEX_DIS_F;
					default: HEX0 = `HEX_DIS_BLANK;
				endcase
				case(key_HEX1)
					4'h0: HEX1 = `HEX_DIS_0;
					4'h1: HEX1 = `HEX_DIS_1;
					4'h2: HEX1 = `HEX_DIS_2;
					4'h3: HEX1 = `HEX_DIS_3;
					4'h4: HEX1 = `HEX_DIS_4;
					4'h5: HEX1 = `HEX_DIS_5;
					4'h6: HEX1 = `HEX_DIS_6;
					4'h7: HEX1 = `HEX_DIS_7;
					4'h8: HEX1 = `HEX_DIS_8;
					4'h9: HEX1 = `HEX_DIS_9;
					4'hA: HEX1 = `HEX_DIS_A;
					4'hB: HEX1 = `HEX_DIS_B;
					4'hC: HEX1 = `HEX_DIS_C;
					4'hD: HEX1 = `HEX_DIS_D;
					4'hE: HEX1 = `HEX_DIS_E;
					4'hF: HEX1 = `HEX_DIS_F;
					default: HEX1 = `HEX_DIS_BLANK;
				endcase
				case(key_HEX2)
					4'h0: HEX2 = `HEX_DIS_0;
					4'h1: HEX2 = `HEX_DIS_1;
					4'h2: HEX2 = `HEX_DIS_2;
					4'h3: HEX2 = `HEX_DIS_3;
					4'h4: HEX2 = `HEX_DIS_4;
					4'h5: HEX2 = `HEX_DIS_5;
					4'h6: HEX2 = `HEX_DIS_6;
					4'h7: HEX2 = `HEX_DIS_7;
					4'h8: HEX2 = `HEX_DIS_8;
					4'h9: HEX2 = `HEX_DIS_9;
					4'hA: HEX2 = `HEX_DIS_A;
					4'hB: HEX2 = `HEX_DIS_B;
					4'hC: HEX2 = `HEX_DIS_C;
					4'hD: HEX2 = `HEX_DIS_D;
					4'hE: HEX2 = `HEX_DIS_E;
					4'hF: HEX2 = `HEX_DIS_F;
					default: HEX2 = `HEX_DIS_BLANK;
				endcase
				case(key_HEX3)
					4'h0: HEX3 = `HEX_DIS_0;
					4'h1: HEX3 = `HEX_DIS_1;
					4'h2: HEX3 = `HEX_DIS_2;
					4'h3: HEX3 = `HEX_DIS_3;
					4'h4: HEX3 = `HEX_DIS_4;
					4'h5: HEX3 = `HEX_DIS_5;
					4'h6: HEX3 = `HEX_DIS_6;
					4'h7: HEX3 = `HEX_DIS_7;
					4'h8: HEX3 = `HEX_DIS_8;
					4'h9: HEX3 = `HEX_DIS_9;
					4'hA: HEX3 = `HEX_DIS_A;
					4'hB: HEX3 = `HEX_DIS_B;
					4'hC: HEX3 = `HEX_DIS_C;
					4'hD: HEX3 = `HEX_DIS_D;
					4'hE: HEX3 = `HEX_DIS_E;
					4'hF: HEX3 = `HEX_DIS_F;
					default: HEX3 = `HEX_DIS_BLANK;
				endcase
				case(key_HEX4)
					4'h0: HEX4 = `HEX_DIS_0;
					4'h1: HEX4 = `HEX_DIS_1;
					4'h2: HEX4 = `HEX_DIS_2;
					4'h3: HEX4 = `HEX_DIS_3;
					4'h4: HEX4 = `HEX_DIS_4;
					4'h5: HEX4 = `HEX_DIS_5;
					4'h6: HEX4 = `HEX_DIS_6;
					4'h7: HEX4 = `HEX_DIS_7;
					4'h8: HEX4 = `HEX_DIS_8;
					4'h9: HEX4 = `HEX_DIS_9;
					4'hA: HEX4 = `HEX_DIS_A;
					4'hB: HEX4 = `HEX_DIS_B;
					4'hC: HEX4 = `HEX_DIS_C;
					4'hD: HEX4 = `HEX_DIS_D;
					4'hE: HEX4 = `HEX_DIS_E;
					4'hF: HEX4 = `HEX_DIS_F;
					default: HEX4 = `HEX_DIS_BLANK;
				endcase
				case(key_HEX5)
					4'h0: HEX5 = `HEX_DIS_0;
					4'h1: HEX5 = `HEX_DIS_1;
					4'h2: HEX5 = `HEX_DIS_2;
					4'h3: HEX5 = `HEX_DIS_3;
					4'h4: HEX5 = `HEX_DIS_4;
					4'h5: HEX5 = `HEX_DIS_5;
					4'h6: HEX5 = `HEX_DIS_6;
					4'h7: HEX5 = `HEX_DIS_7;
					4'h8: HEX5 = `HEX_DIS_8;
					4'h9: HEX5 = `HEX_DIS_9;
					4'hA: HEX5 = `HEX_DIS_A;
					4'hB: HEX5 = `HEX_DIS_B;
					4'hC: HEX5 = `HEX_DIS_C;
					4'hD: HEX5 = `HEX_DIS_D;
					4'hE: HEX5 = `HEX_DIS_E;
					4'hF: HEX5 = `HEX_DIS_F;
					default: HEX5 = `HEX_DIS_BLANK;
				endcase
			end
			else begin
				HEX0 = `HEX_DIS_DASH;
				HEX1 = `HEX_DIS_DASH;
				HEX2 = `HEX_DIS_DASH;
				HEX3 = `HEX_DIS_DASH;
				HEX4 = `HEX_DIS_DASH;
				HEX5 = `HEX_DIS_DASH;
			end
		end
		else begin
			HEX0 = `HEX_DIS_BLANK;
			HEX1 = `HEX_DIS_BLANK;
			HEX2 = `HEX_DIS_BLANK;
			HEX3 = `HEX_DIS_BLANK;
			HEX4 = `HEX_DIS_BLANK;
			HEX5 = `HEX_DIS_BLANK;
		end
	end

endmodule: task4

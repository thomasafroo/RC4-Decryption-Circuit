
`define RST_STATE 3'd0
`define LOAD_NEXT_KEY_STATE 3'd1
`define STARTING_ARC4_STATE 3'd2
`define TRYING_KEY_STATE 3'd3
`define KEY_FOUND_STATE 3'd4

module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

	logic [23:0] next_key;
	logic [7:0] pt_addr, pt_rddata, pt_wrdata;
	logic pt_wren, arc4_rdy, arc4_en, arc4_rst_n;

	logic [2:0] state, next_state;

	always_ff @(posedge clk) begin
		if(!rst_n) begin
			state <= 3'd0;
			key <= 24'd0;
		end
		else begin
			state <= next_state;
			key <= next_key;
		end
	end

	always_comb begin
		case(state)
			`RST_STATE: begin
				if(en) next_state = state + 3'd1;
				else next_state = state;
				next_key = key;
			end 
			`LOAD_NEXT_KEY_STATE: begin
				if(arc4_rdy) next_state = state + 3'd1;
				else  next_state = state;
				next_key = key;
			end
			`STARTING_ARC4_STATE: begin
				next_state = state + 3'd1;
				next_key = key;
			end
			`TRYING_KEY_STATE: begin
				if(((pt_wrdata < 8'h20)||(pt_wrdata > 8'h7E))&& (pt_wren) && (pt_wrdata !== 0)) begin
					next_state = `LOAD_NEXT_KEY_STATE;
					next_key = key + 24'd1;
				end
				else begin
					if(arc4_rdy) begin
						next_state = state + 3'd1;
						next_key = key;
					end
					else begin
						next_state = state;
						next_key = key;
					end
				end
			end
			`KEY_FOUND_STATE: begin
				if(en) begin
					next_state = `LOAD_NEXT_KEY_STATE;
					next_key = 24'd0;
				end
				else begin
					next_state = state;
					next_key = key;
				end
			end
			default: begin
				next_state = state;
				next_key = key;
			end
		endcase
	end

	always_comb begin
		case(state)
			`RST_STATE: begin
				key_valid = 1'd0;
				rdy = 1'd1;
				arc4_rst_n = 1'd0;
				arc4_en = 1'd0;
			end 
			`LOAD_NEXT_KEY_STATE: begin
				key_valid = 1'd0;
				rdy = 1'd0;
				arc4_rst_n = 1'd1;
				arc4_en = 1'd1; // 0 before 
			end
			`STARTING_ARC4_STATE: begin
				key_valid = 1'd0;
				rdy = 1'd0;
				arc4_rst_n = 1'd1;
				arc4_en = 1'd0; // 1 before
			end
			`TRYING_KEY_STATE: begin
				if(((pt_wrdata < 8'h20)||(pt_wrdata > 8'h7E))&&/*(pt_addr != 8'd0)*/ (pt_wren) )begin
					key_valid = 1'd0;
					rdy = 1'd0;
					arc4_rst_n = 1'd0;
				end
				else begin
					key_valid = 1'd0;
					rdy = 1'd0;
					arc4_rst_n = 1'd1;
				end
				arc4_en = 1'd0;
			end
			`KEY_FOUND_STATE: begin
				key_valid = 1'd1;
				rdy = 1'd1;
				if(en) arc4_rst_n = 1'd0;
				else arc4_rst_n = 1'd1;
				arc4_en = 1'd0;
			end
			default: begin
				key_valid = 1'd0;
				rdy = 1'd0;
				arc4_rst_n = 1'd1;
				arc4_en = 1'd0;
			end
		endcase
	end	

    // this memory must have the length-prefixed plaintext if key_valid
	pt_mem pt( .address(pt_addr), .clock(clk), .data(pt_wrdata), .wren(pt_wren), .q(pt_rddata) );
	arc4 a4(.clk(clk), .rst_n(arc4_rst_n),
            .en(arc4_en), .rdy(arc4_rdy),
            .key(key),
            .ct_addr(ct_addr), .ct_rddata(ct_rddata),
            .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    // your code here

endmodule: crack
 
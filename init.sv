module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

	logic [7:0] next_addr;
	logic [1:0] gen_state, next_gen_state;

	//using addr as the state machine
	always_ff @(posedge clk)begin	
		if(!rst_n)begin
			addr = 8'd0;
			gen_state = 2'd0;
		end
		else begin
			gen_state = next_gen_state;
			addr = next_addr;
		end
	end

	//nextstate logic
	always_comb begin
		case(gen_state)
			2'd0: begin
				if(en) next_gen_state = 2'd1;
				else next_gen_state = 2'd0;
				next_addr = 8'd0;
			end
			2'd1: begin
				if(addr >= 8'd255) begin 
					next_gen_state = 2'd0;
					next_addr = 8'd0;
				end
				else begin
					next_gen_state = 2'd1;
					next_addr = addr + 8'd1;
				end
			end
			default begin
				next_gen_state = 2'd0;
				next_addr = 8'd0;
			end
		endcase
	end

	//output logic
	always_comb begin
		case(gen_state)
			2'd0: rdy = 1'd1;
			default: rdy = 1'd0;
		endcase
		wrdata = addr;
		if(gen_state == 2'd1) wren = 1'd1;
		else wren = 1'd0;
		
	end

endmodule: init
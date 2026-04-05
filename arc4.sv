module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    logic [7:0] s_addr,s_wrdata;
	logic s_wren;
	logic [7:0] s_data_out;

	logic init_en, ksa_en, prga_en;
	logic init_rdy, ksa_rdy, prga_rdy;
	logic [7:0] init_addr, init_wrdata, ksa_addr, ksa_wrdata, prga_s_wrdata, prga_s_addr;
	logic init_wren, ksa_wren, prga_s_wren;

	s_mem s( .address(s_addr), .clock(clk), .data(s_wrdata), .wren(s_wren), .q(s_data_out));
	init i( .clk(clk), .rst_n(rst_n),
            .en(init_en), .rdy(init_rdy),
            .addr(init_addr), .wrdata(init_wrdata), .wren(init_wren));
	ksa k( .clk(clk), .rst_n(rst_n),
           .en(ksa_en), .rdy(ksa_rdy),
           .key(key),
           .addr(ksa_addr), .rddata(s_data_out), .wrdata(ksa_wrdata), .wren(ksa_wren));
	prga p( .clk(clk), .rst_n(rst_n),
            .en(prga_en), .rdy(prga_rdy),
            .key(key),
            .s_addr(prga_s_addr), .s_rddata(s_data_out), .s_wrdata(prga_s_wrdata), .s_wren(prga_s_wren),
            .ct_addr(ct_addr), .ct_rddata(ct_rddata),
            .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

	logic [3:0] state, next_state;
	always_ff @(posedge clk) begin
		if(!rst_n)begin
			state <= 4'd0;
		end
		else begin
			state <= next_state;
		end
	end
	assign rdy = (state == 4'd0);
	always_comb begin
		case(state) 
			4'd0: begin
				if(en) next_state = state + 4'd1;
				else next_state = state;
			end
			4'd1: begin
				if(init_rdy) next_state = state + 4'd1;
				else next_state = state;
			end
			4'd2: begin
				next_state = state + 4'd1;
			end
			4'd3: begin
				if(init_rdy) next_state = state + 4'd1;
				else next_state = state;
			end
			4'd4: begin
				if(ksa_rdy) next_state = state + 4'd1;
				else next_state = state;
			end
			4'd5: begin
				next_state = state + 4'd1;
			end
			4'd6: begin
				if(ksa_rdy) next_state = state + 4'd1;
				else next_state = state;
			end
			4'd7: begin
				if(prga_rdy) next_state = state + 4'd1;
				else next_state = state;
			end
			4'd8: begin
				next_state = state + 4'd1;
			end
			4'd9: begin
				if(prga_rdy) next_state = 4'd0;
				else next_state = 4'd9;
			end
			default: next_state = state;
		endcase
	end

	always_comb begin
		case(state) 
			4'd0: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd1: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd2: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd1; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd3: begin
				s_addr = init_addr;
				s_wrdata = init_wrdata;
				s_wren = init_wren;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd4: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd5: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd1;
				prga_en = 1'd0;
			end
			4'd6: begin
				s_addr = ksa_addr;
				s_wrdata = ksa_wrdata;
				s_wren = ksa_wren;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd7: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			4'd8: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd1;
			end
			4'd9: begin
				s_addr = prga_s_addr;
				s_wrdata = prga_s_wrdata;
				s_wren = prga_s_wren;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
			default: begin 
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				init_en = 1'd0; 
				ksa_en = 1'd0;
				prga_en = 1'd0;
			end
		endcase
	end

endmodule: arc4


`define RST_STATE 4'd0
`define SAVE_MSG_LEN_STATE 4'd1
`define GET_Si_STATE 4'd2
`define GET_Sj_STATE 4'd3
`define SAVE_Si_STATE 4'd4
`define SAVE_Sj_STATE 4'd5
`define GET_Sstr_STATE 4'd6
`define SAVE_PT_STATE 4'd7

module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

	logic [7:0] msg_len, next_msg_len, k_val, next_k_val, i_val, next_i_val, j_val, next_j_val, saved_si_val, next_saved_si_val, saved_sj_val, next_saved_sj_val;
	logic [3:0] gen_state, next_gen_state;
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			gen_state <= 4'd0;
			msg_len <= 8'd0;
			k_val <= 8'd1;
			i_val <= 8'd0;
			j_val <= 8'd0;
			saved_si_val <= 8'd0;
			saved_sj_val <= 8'd0;
		end
		else begin
			gen_state <= next_gen_state;
			msg_len <= next_msg_len;
			k_val <= next_k_val;
			i_val <= next_i_val;
			j_val <= next_j_val;
			saved_si_val <= next_saved_si_val;
			saved_sj_val <= next_saved_sj_val;
		end
	end

	//next state logic
	always_comb begin
		case(gen_state)
			`RST_STATE: begin
				if(en) next_gen_state = gen_state + 4'd1;
				else next_gen_state = gen_state;
				next_msg_len = 8'd0;
				next_k_val = 8'd1;
				next_i_val = 8'd0;
				next_j_val = 8'd0;
				next_saved_si_val = 8'd0;
				next_saved_sj_val = 8'd0;
			end
			`SAVE_MSG_LEN_STATE: begin
				next_gen_state = gen_state + 4'd1;
				next_msg_len = msg_len;
				next_k_val = k_val;
				next_i_val = i_val;
				next_j_val = j_val;
				next_saved_si_val = saved_si_val;
				next_saved_sj_val = saved_sj_val;
			end
			`GET_Si_STATE: begin
				next_gen_state = gen_state + 4'd1;
				next_msg_len = ct_rddata;
				next_k_val = k_val;
				next_i_val = i_val + 1'd1;
				next_j_val = j_val;
				next_saved_si_val = saved_si_val;
				next_saved_sj_val = saved_sj_val;
			end
			`GET_Sj_STATE: begin
				next_gen_state = gen_state + 4'd1;
				next_msg_len = msg_len;
				next_k_val = k_val;
				next_i_val = i_val;
				next_j_val = j_val + s_rddata;
				next_saved_si_val = s_rddata;
				next_saved_sj_val = saved_sj_val;
			end
			`SAVE_Si_STATE: begin
				next_gen_state = gen_state + 4'd1;
				next_msg_len = msg_len;
				next_k_val = k_val;
				next_i_val = i_val;
				next_j_val = j_val;
				next_saved_si_val = saved_si_val;
				next_saved_sj_val = s_rddata;
			end
			`SAVE_Sj_STATE: begin
				next_gen_state = gen_state + 4'd1;
				next_msg_len = msg_len;
				next_k_val = k_val;
				next_i_val = i_val;
				next_j_val = j_val;
				next_saved_si_val = saved_si_val;
				next_saved_sj_val = saved_sj_val;
			end
			`GET_Sstr_STATE: begin
				next_gen_state = gen_state + 4'd1;
				next_msg_len = msg_len;
				next_k_val = k_val;
				next_i_val = i_val;
				next_j_val = j_val;
				next_saved_si_val = saved_si_val;
				next_saved_sj_val = saved_sj_val;
			end
			`SAVE_PT_STATE: begin
				if(k_val < msg_len) begin
					next_gen_state = `GET_Si_STATE;
					next_k_val = k_val + 8'd1;
				end
				else begin
					next_gen_state = `RST_STATE;
					next_k_val = 8'd1;
				end
				next_msg_len = msg_len;
				next_i_val = i_val;
				next_j_val = j_val;
				next_saved_si_val = saved_si_val;
				next_saved_sj_val = saved_sj_val;
			end
			default: begin
				next_gen_state = gen_state;
				next_msg_len = 8'd0;
				next_k_val = 8'd1;
				next_i_val = 8'd0;
				next_j_val = 8'd0;
				next_saved_si_val = 8'd0;
				next_saved_sj_val = 8'd0;
			end
		endcase
	end

	//output logic
	always_comb begin
		if(gen_state == `RST_STATE) begin
			ct_addr = 8'd0;
			rdy = 1'd1;
		end
		else begin
			ct_addr = k_val;
			rdy = 1'd0;
		end
		if((gen_state == `SAVE_MSG_LEN_STATE) || (gen_state == `RST_STATE)) pt_addr = 8'd0;
		else pt_addr = k_val;
		case(gen_state)
			`RST_STATE: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
			`SAVE_MSG_LEN_STATE: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = ct_rddata;
				pt_wren  = 1'd1;
			end
			`GET_Si_STATE: begin
				s_addr = i_val + 8'd1;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
			`GET_Sj_STATE: begin
				s_addr = j_val + s_rddata;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
			`SAVE_Si_STATE: begin
				s_addr = i_val;
				s_wrdata = s_rddata;
				s_wren = 1'd1;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
			`SAVE_Sj_STATE: begin
				s_addr = j_val;
				s_wrdata = saved_si_val;
				s_wren = 1'd1;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
			`GET_Sstr_STATE: begin
				s_addr = saved_si_val + saved_sj_val;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
			`SAVE_PT_STATE: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = s_rddata ^ ct_rddata;
				pt_wren  = 1'd1;
			end
			default: begin
				s_addr = 8'd0;
				s_wrdata = 8'd0;
				s_wren = 1'd0;
				pt_wrdata = 8'd0;
				pt_wren  = 1'd0;
			end
		endcase
	end
endmodule: prga

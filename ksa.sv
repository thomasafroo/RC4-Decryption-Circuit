`define RST_STATE        3'd0
`define GET_Si_STATE     3'd1
`define GET_Sj_STATE     3'd2
`define SAVE_TO_Si_STATE 3'd3
`define SAVE_TO_Sj_STATE 3'd4

module ksa(
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    output logic rdy, 
    input  logic [23:0] key,
    output logic [7:0] addr,
    input  logic [7:0] rddata,
    output logic [7:0] wrdata,
    output logic wren
);

    // State registers
    logic [2:0] gen_state, next_gen_state;
    logic [7:0] i_val, next_i_val;
    logic [7:0] j_val, next_j_val;
    logic [7:0] saved_i_val, next_saved_i_val;
    logic [7:0] igor;  // i mod 3

    // Sequential logic (state + datapath registers)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            gen_state <= `RST_STATE;
            i_val <= 8'd0;
            j_val <= 8'd0;
            saved_i_val <= 8'd0;
        end
        else begin
            gen_state <= next_gen_state;
            i_val <= next_i_val;
            j_val <= next_j_val;
            saved_i_val <= next_saved_i_val;
        end
    end

    // Next-state logic
    always_comb begin
        // defaults: hold previous values
        next_gen_state = gen_state;
        next_i_val = i_val;
        next_j_val = j_val;
        next_saved_i_val = saved_i_val;

        // key index: i mod 3
        igor = i_val % 8'd3;

        case (gen_state)
            // Idle / reset state: rdy=1, wait for en=1 to start KSA
            `RST_STATE: begin
                if (en) begin
                    next_gen_state = `GET_Si_STATE;
                    next_i_val = 8'd0;
                    next_j_val = 8'd0;
                    next_saved_i_val = 8'd0;
                end
            end

            // 1st cycle of iteration: read S[i]
            `GET_Si_STATE: begin
                next_gen_state = `GET_Sj_STATE;
                // i_val, j_val unchanged
            end

            // 2nd cycle: rddata = S[i], compute j and save S[i]
            `GET_Sj_STATE: begin
                next_gen_state = `SAVE_TO_Si_STATE;
                case (igor)
                    8'd0: next_j_val = j_val + rddata + key[23:16];
                    8'd1: next_j_val = j_val + rddata + key[15:8];
                    8'd2: next_j_val = j_val + rddata + key[7:0];
                    default: next_j_val = j_val; // shouldn't hit
                endcase
                next_saved_i_val = rddata;     // hold S[i]
            end

            // 3rd cycle: rddata = S[j], write S[j] into S[i]
            `SAVE_TO_Si_STATE: begin
                next_gen_state = `SAVE_TO_Sj_STATE;
                // values already set in previous state
            end

            // 4th cycle: write saved S[i] into S[j]; advance i or finish
            `SAVE_TO_Sj_STATE: begin
                if (i_val == 8'd255) begin
                    // finished all 256 swaps, go idle
                    next_gen_state = `RST_STATE;
                    // datapath contents don't matter once done
                end
                else begin
                    // next iteration
                    next_gen_state = `GET_Si_STATE;
                    next_i_val = i_val + 8'd1;
                    // j and saved_i_val carry through
                end
            end

            default: begin
                next_gen_state = `RST_STATE;
                next_i_val = 8'd0;
                next_j_val = 8'd0;
                next_saved_i_val = 8'd0;
            end
        endcase
    end

    // Output logic
    always_comb begin
        // safe defaults
        rdy = 1'b0;
        addr = 8'd0;
        wrdata = 8'd0;
        wren = 1'b0;

        case (gen_state)
            `RST_STATE: begin
                rdy = 1'b1;    // ready / idle
            end

            `GET_Si_STATE: begin
                addr = i_val;   // read S[i]
            end

            `GET_Sj_STATE: begin
                // rddata = S[i] here; we re-use same expression as for next_j_val
                case (igor)
                    8'd0: addr = j_val + rddata + key[23:16];
                    8'd1: addr = j_val + rddata + key[15:8];
                    8'd2: addr = j_val + rddata + key[7:0];
                    default: addr = 8'hF0;
                endcase
            end

            `SAVE_TO_Si_STATE: begin
                // rddata = S[j]; write it into S[i]
                addr = i_val;
                wrdata = rddata;  // S[j]
                wren = 1'b1;
            end

            `SAVE_TO_Sj_STATE: begin
                // write saved S[i] into S[j]
                addr = j_val;
                wrdata = saved_i_val;
                wren = 1'b1;
            end

            default: begin
                // already covered by defaults
            end
        endcase
    end

endmodule : ksa


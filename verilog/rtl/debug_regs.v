// module that has registers used for debug
module debug_regs #(
    parameter FIRST_ADDR = 32'h4100_0000,		
    parameter SECOND_ADDR = 32'h4100_0004
)(    
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o);

    reg [31:0] debug_reg_1;
    reg [31:0] debug_reg_2;

    // write
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            debug_reg_1 <=0;
            debug_reg_2 <=0;
            wbs_dat_o   <=0;
            wbs_ack_o   <=0;
        end else if (wbs_cyc_i && wbs_stb_i && wbs_we_i && !wbs_ack_o)begin // write
            if (wbs_adr_i == FIRST_ADDR ) begin
                // write to reg1
                debug_reg_1[7:0]    <= wbs_sel_i[0] ? wbs_dat_i[7:0]   :debug_reg_1[7:0];
                debug_reg_1[15:8]   <= wbs_sel_i[1] ? wbs_dat_i[15:8]  :debug_reg_1[15:8];
                debug_reg_1[23:16]  <= wbs_sel_i[2] ? wbs_dat_i[23:16] :debug_reg_1[23:16];
                debug_reg_1[31:24]  <= wbs_sel_i[3] ? wbs_dat_i[31:24] :debug_reg_1[31:24];
                wbs_ack_o <= 1;
            end else if (wbs_adr_i == SECOND_ADDR ) begin
                // write to reg2
                debug_reg_2[7:0]    <= wbs_sel_i[0] ? wbs_dat_i[7:0]   :debug_reg_2[7:0];
                debug_reg_2[15:8]   <= wbs_sel_i[1] ? wbs_dat_i[15:8]  :debug_reg_2[15:8];
                debug_reg_2[23:16]  <= wbs_sel_i[2] ? wbs_dat_i[23:16] :debug_reg_2[23:16];
                debug_reg_2[31:24]  <= wbs_sel_i[3] ? wbs_dat_i[31:24] :debug_reg_2[31:24];
                wbs_ack_o <= 1;
            end
        end else if (wbs_cyc_i && wbs_stb_i && !wbs_we_i && !wbs_ack_o ) begin // read 
            if (wbs_adr_i == FIRST_ADDR || wbs_adr_i == SECOND_ADDR) begin
                wbs_dat_o <= ((wbs_adr_i == SECOND_ADDR)) ? debug_reg_2 : debug_reg_1; 
                wbs_ack_o <= 1;
            end
        end else begin 
            wbs_ack_o <= 0;
            wbs_dat_o <= 0;
        end
    end
endmodule

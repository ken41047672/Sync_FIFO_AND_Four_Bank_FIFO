`timescale 1ns / 10ps

`include "FIFO_sync.v"


module FourBankFIFO(
    input           clk         ,
    input           rst         ,
    input           wr_en_M0    ,
    input  [7:0]    data_in_M0  ,
    input           rd_en_M0    ,
    input  [1:0]    rd_id_M0    ,
    input           wr_en_M1    ,
    input  [7:0]    data_in_M1  ,
    input           rd_en_M1    ,
    input  [1:0]    rd_id_M1    ,
    output [7:0]    data_out_M0 ,
    output [7:0]    data_out_M1 ,
    output reg          valid_M0,
    output reg          valid_M1
);


    wire GigaChad_check_rd_en_M0;
    wire GigaChad_check_rd_en_M1;
    wire GigaChad_check_wr_en_M0;
    wire GigaChad_check_wr_en_M1;
    

    reg [1:0] LRU_ORDER [0:3];
    reg [1:0] LRU_order_buffer;
    


    wire M0_req; 
    wire M1_req;
    
    assign M0_req = wr_en_M0 || rd_en_M0;
    assign M1_req = wr_en_M1 || rd_en_M1;


    wire full_0;
    wire full_1;
    wire full_2;
    wire full_3;


    wire empty_0;
    wire empty_1;
    wire empty_2;
    wire empty_3;

    wire [7:0] data_in_0;
    wire [7:0] data_in_1;
    wire [7:0] data_in_2;
    wire [7:0] data_in_3;

    wire [7:0] data_out_0;
    wire [7:0] data_out_1;
    wire [7:0] data_out_2;
    wire [7:0] data_out_3;

    wire wr_en_0;
    wire wr_en_1;
    wire wr_en_2;
    wire wr_en_3;
    
    wire rd_en_0;
    wire rd_en_1;
    wire rd_en_2;
    wire rd_en_3;

   
    
    reg wholastTime;

    
    wire writeSuccess;
    
    reg read_from_0;
    reg read_from_1;
    reg read_from_2;
    reg read_from_3;

    assign data_out_M0 = (read_from_0) ? data_out_0 : (read_from_1) ? data_out_1 : (read_from_2) ? data_out_2 : (read_from_3) ? data_out_3 : 8'd0;
    assign data_out_M1 = (read_from_0) ? data_out_0 : (read_from_1) ? data_out_1 : (read_from_2) ? data_out_2 : (read_from_3) ? data_out_3 : 8'd0;
    


    assign GigaChad_check_rd_en_M0 = (M0_req & M1_req) ? (wholastTime) & rd_en_M0 : (M0_req) ? rd_en_M0 : 1'b0;
    assign GigaChad_check_wr_en_M0 = (M0_req & M1_req) ? (wholastTime) & wr_en_M0 : (M0_req) ? wr_en_M0 : 1'b0;
    assign GigaChad_check_rd_en_M1 = (M0_req & M1_req) ?(~wholastTime) & rd_en_M1 : (M1_req) ? rd_en_M1 : 1'b0;
    assign GigaChad_check_wr_en_M1 = (M0_req & M1_req) ?(~wholastTime) & wr_en_M1 : (M1_req) ? wr_en_M1 : 1'b0;



    assign rd_en_3 = ((~empty_3 && GigaChad_check_rd_en_M0) && (rd_id_M0 == 2'b11) ) ? 1'b1 : ((~empty_3 && GigaChad_check_rd_en_M1) && (rd_id_M1 == 2'b11) ) ? 1'b1 : 1'b0;
    assign rd_en_2 = ((~empty_2 && GigaChad_check_rd_en_M0) && (rd_id_M0 == 2'b10) ) ? 1'b1 : ((~empty_2 && GigaChad_check_rd_en_M1) && (rd_id_M1 == 2'b10) ) ? 1'b1 : 1'b0;
    assign rd_en_1 = ((~empty_1 && GigaChad_check_rd_en_M0) && (rd_id_M0 == 2'b01) ) ? 1'b1 : ((~empty_1 && GigaChad_check_rd_en_M1) && (rd_id_M1 == 2'b01) ) ? 1'b1 : 1'b0;
    assign rd_en_0 = ((~empty_0 && GigaChad_check_rd_en_M0) && (rd_id_M0 == 2'b00) ) ? 1'b1 : ((~empty_0 && GigaChad_check_rd_en_M1) && (rd_id_M1 == 2'b00) ) ? 1'b1 : 1'b0;

    assign wr_en_3 = ((~full_3 && GigaChad_check_wr_en_M0) && (LRU_ORDER[0] == 2'b11) ) ? 1'b1 : ((~full_3 && GigaChad_check_wr_en_M1) && (LRU_ORDER[0] == 2'b11) ) ? 1'b1 : 1'b0;
    assign wr_en_2 = ((~full_2 && GigaChad_check_wr_en_M0) && (LRU_ORDER[0] == 2'b10) ) ? 1'b1 : ((~full_2 && GigaChad_check_wr_en_M1) && (LRU_ORDER[0] == 2'b10) ) ? 1'b1 : 1'b0;
    assign wr_en_1 = ((~full_1 && GigaChad_check_wr_en_M0) && (LRU_ORDER[0] == 2'b01) ) ? 1'b1 : ((~full_1 && GigaChad_check_wr_en_M1) && (LRU_ORDER[0] == 2'b01) ) ? 1'b1 : 1'b0;
    assign wr_en_0 = ((~full_0 && GigaChad_check_wr_en_M0) && (LRU_ORDER[0] == 2'b00) ) ? 1'b1 : ((~full_0 && GigaChad_check_wr_en_M1) && (LRU_ORDER[0] == 2'b00) ) ? 1'b1 : 1'b0;

    assign writeSuccess = (wr_en_0 || wr_en_1 || wr_en_2 || wr_en_3) ? 1'b1 : 1'b0;

    assign data_in_0 = wr_en_0 ? GigaChad_check_wr_en_M0 ? data_in_M0 : GigaChad_check_wr_en_M1 ? data_in_M1 : 8'd0 : 8'd0;
    assign data_in_1 = wr_en_1 ? GigaChad_check_wr_en_M0 ? data_in_M0 : GigaChad_check_wr_en_M1 ? data_in_M1 : 8'd0 : 8'd0;
    assign data_in_2 = wr_en_2 ? GigaChad_check_wr_en_M0 ? data_in_M0 : GigaChad_check_wr_en_M1 ? data_in_M1 : 8'd0 : 8'd0;
    assign data_in_3 = wr_en_3 ? GigaChad_check_wr_en_M0 ? data_in_M0 : GigaChad_check_wr_en_M1 ? data_in_M1 : 8'd0 : 8'd0;


    FIFO_sync f0(
  	    .clk(clk),
        .rst(rst),
        .wr_en(wr_en_0),
        .rd_en(rd_en_0),
        .data_in(data_in_0),
        .full(full_0),
        .empty(empty_0),
        .data_out(data_out_0)
    );
    FIFO_sync f1(
  	    .clk(clk),
        .rst(rst),
        .wr_en(wr_en_1),
        .rd_en(rd_en_1),
        .data_in(data_in_1),
        .full(full_1),
        .empty(empty_1),
        .data_out(data_out_1)
    );
    FIFO_sync f2(
  	    .clk(clk),
        .rst(rst),
        .wr_en(wr_en_2),
        .rd_en(rd_en_2),
        .data_in(data_in_2),
        .full(full_2),
        .empty(empty_2),
        .data_out(data_out_2)
    );
    FIFO_sync f3(
  	    .clk(clk),
        .rst(rst),
        .wr_en(wr_en_3),
        .rd_en(rd_en_3),
        .data_in(data_in_3),
        .full(full_3),
        .empty(empty_3),
        .data_out(data_out_3)
    );
 
   
    


    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            LRU_ORDER[0] = 0;
            LRU_ORDER[1] = 1;
            LRU_ORDER[2] = 2;
            LRU_ORDER[3] = 3;

            valid_M0     = 0;
            valid_M1     = 0;
            
          
            wholastTime = 1;
        end
        else begin
           
            

            read_from_0 = rd_en_0;
            read_from_1 = rd_en_1;
            read_from_2 = rd_en_2;
            read_from_3 = rd_en_3;

            valid_M0 = GigaChad_check_rd_en_M0 & ( (rd_id_M0 == 2'b00 & ~empty_0) | (rd_id_M0 == 2'b01 & ~empty_1) | (rd_id_M0 == 2'b10 & ~empty_2) | (rd_id_M0 == 2'b11 & ~empty_3) );
            valid_M1 = GigaChad_check_rd_en_M1 & ( (rd_id_M1 == 2'b00 & ~empty_0) | (rd_id_M1 == 2'b01 & ~empty_1) | (rd_id_M1 == 2'b10 & ~empty_2) | (rd_id_M1 == 2'b11 & ~empty_3) );
          
           

            if(writeSuccess) begin
                LRU_order_buffer = LRU_ORDER[0];
                LRU_ORDER[0]     = LRU_ORDER[1];
                LRU_ORDER[1]     = LRU_ORDER[2];
                LRU_ORDER[2]     = LRU_ORDER[3];
                LRU_ORDER[3]     = LRU_order_buffer;
            end else begin end    
           
           case ({M0_req, M1_req})
                2'b11:  wholastTime = ~wholastTime;  // both request → alternate user
                2'b10:  wholastTime = 1'b0;          // only M0
                2'b01:  wholastTime = 1'b1;          // only M1
                default: wholastTime = wholastTime;
            endcase
        end
    end
endmodule
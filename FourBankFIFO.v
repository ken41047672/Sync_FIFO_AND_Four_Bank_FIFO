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
    // ,

    // output  [7:0] out_debug_data_out_0,
    // output  [7:0] out_debug_data_out_1,
    // output  [7:0] out_debug_data_out_2,
    // output  [7:0] out_debug_data_out_3,

    // output  [7:0] out_debug_write_addr2,
    // output  [7:0] out_debug_read_addr2,
    // output  [5:0] out_debug_counter2,
    // output        out_debug_ok_to_write2,
    // output        out_debug_ok_to_read2,
    // output [31:0] debug_step,


    // output debug_wr_en_0,
    // output debug_wr_en_1,
    // output debug_wr_en_2,
    // output debug_wr_en_3,

    // output debug_rd_en_0,
    // output debug_rd_en_1,
    // output debug_rd_en_2,
    // output debug_rd_en_3,
    // output debug_whoThisTime,
    // output debug_check_rd_en_M0,
    // output debug_check_rd_en_M1,
    // output debug_check_wr_en_M0,
    // output debug_check_wr_en_M1,

    // output debug_M0_req,
    // output debug_M1_req
);


    wire GigaChad_check_rd_en_M0;
    wire GigaChad_check_rd_en_M1;
    wire GigaChad_check_wr_en_M0;
    wire GigaChad_check_wr_en_M1;
    

    reg [1:0] LRU_ORDER [0:3];
    reg [1:0] LRU_order_buffer;
    



    // wire [255:0] debug_memory_out_0;
    // wire [255:0] debug_memory_out_1;        
    // wire [255:0] debug_memory_out_2;
    // wire [255:0] debug_memory_out_3;

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

    reg [7:0] data_in_0;
    reg [7:0] data_in_1;
    reg [7:0] data_in_2;
    reg [7:0] data_in_3;

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

    //reg [31:0] step;
    
    reg wholastTime;

    //assign debug_whoThisTime = wholastTime;
    //assign out_debug_data_out_3 = data_out_3;


    /*
    GigaChad g(
        .clk(clk),
        .reset(rst),
        .in_rd_en_M0(rd_en_M0),
        .in_rd_en_M1(rd_en_M1),
        .in_wr_en_M0(wr_en_M0),
        .in_wr_en_M1(wr_en_M1),
        .out_rd_en_M0(GigaChad_check_rd_en_M0),
        .out_rd_en_M1(GigaChad_check_rd_en_M1),
        .out_wr_en_M0(GigaChad_check_wr_en_M0),
        .out_wr_en_M1(GigaChad_check_wr_en_M1)
    );
    */

    // wire [7:0] debug_write_addr0;
    // wire [7:0] debug_read_addr0;
    // wire [5:0] debug_counter0;
    // wire       debug_ok_to_write0;
    // wire       debug_ok_to_read0;

    // wire [7:0] debug_write_addr1;
    // wire [7:0] debug_read_addr1;
    // wire [5:0] debug_counter1;
    // wire       debug_ok_to_write1;
    // wire       debug_ok_to_read1;

    // wire [7:0] debug_write_addr2;
    // wire [7:0] debug_read_addr2;
    // wire [5:0] debug_counter2;
    // wire       debug_ok_to_write2;
    // wire       debug_ok_to_read2;

    // wire [7:0] debug_write_addr3;
    // wire [7:0] debug_read_addr3;
    // wire [5:0] debug_counter3;
    // wire       debug_ok_to_write3;
    // wire       debug_ok_to_read3;

  
    reg writeSuccess;
    
    reg read_from_0;
    reg read_from_1;
    reg read_from_2;
    reg read_from_3;

    assign data_out_M0 = (read_from_0) ? data_out_0 : (read_from_1) ? data_out_1 : (read_from_2) ? data_out_2 : (read_from_3) ? data_out_3 : 8'd0;
    assign data_out_M1 = (read_from_0) ? data_out_0 : (read_from_1) ? data_out_1 : (read_from_2) ? data_out_2 : (read_from_3) ? data_out_3 : 8'd0;
    
    // assign out_debug_data_out_0 = data_out_0;
    // assign out_debug_data_out_1 = data_out_1;
    // assign out_debug_data_out_2 = data_out_2;
    // assign out_debug_data_out_3 = data_out_3;

    assign GigaChad_check_rd_en_M0 = (M0_req & M1_req) ? (wholastTime) & rd_en_M0 : (M0_req) ? rd_en_M0 : 1'b0;

    assign GigaChad_check_wr_en_M0 = (M0_req & M1_req) ? (wholastTime) & wr_en_M0 : (M0_req) ? wr_en_M0 : 1'b0;
 
    assign GigaChad_check_rd_en_M1 = (M0_req & M1_req) ?(~wholastTime) & rd_en_M1 : (M1_req) ? rd_en_M1 : 1'b0;
  
    assign GigaChad_check_wr_en_M1 = (M0_req & M1_req) ?(~wholastTime) & wr_en_M1 : (M1_req) ? wr_en_M1 : 1'b0;


    //assign {rd_en_3, rd_en_2, rd_en_1, rd_en_0} = (GigaChad_check_rd_en_M0) ? (4'b0001 << rd_id_M0) : (GigaChad_check_rd_en_M1) ? (4'b0001 << rd_id_M1) : 4'b0000;

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



    // assign valid_M0 = GigaChad_check_rd_en_M0 & ( (rd_id_M0 == 2'b00 & ~empty_0) | (rd_id_M0 == 2'b01 & ~empty_1) | (rd_id_M0 == 2'b10 & ~empty_2) | (rd_id_M0 == 2'b11 & ~empty_3) );
    // assign valid_M1 = GigaChad_check_rd_en_M1 & ( (rd_id_M1 == 2'b00 & ~empty_0) | (rd_id_M1 == 2'b01 & ~empty_1) | (rd_id_M1 == 2'b10 & ~empty_2) | (rd_id_M1 == 2'b11 & ~empty_3) );

    // assign debug_wr_en_0 = wr_en_0;
    // assign debug_wr_en_1 = wr_en_1;
    // assign debug_wr_en_2 = wr_en_2;
    // assign debug_wr_en_3 = wr_en_3;

    // assign debug_rd_en_0 = rd_en_0;
    // assign debug_rd_en_1 = rd_en_1;
    // assign debug_rd_en_2 = rd_en_2;
    // assign debug_rd_en_3 = rd_en_3;

    // assign out_debug_write_addr2 = debug_write_addr2;
    // assign out_debug_read_addr2  = debug_read_addr2;
    // assign out_debug_counter2    = debug_counter2;
    // assign out_debug_ok_to_write2 = debug_ok_to_write2;
    // assign out_debug_ok_to_read2  = debug_ok_to_read2;
    // assign debug_step = step;
    // assign out_debug_data_out_2 = data_out_2;

    // assign debug_check_rd_en_M0 = GigaChad_check_rd_en_M0;
    // assign debug_check_rd_en_M1 = GigaChad_check_rd_en_M1;
    // assign debug_check_wr_en_M0 = GigaChad_check_wr_en_M0;
    // assign debug_check_wr_en_M1 = GigaChad_check_wr_en_M1;

    // assign debug_M0_req = M0_req;
    // assign debug_M1_req = M1_req;   

    FIFO_sync f0(
  	    .clk(clk),
        .rst(rst),
        .wr_en(wr_en_0),
        .rd_en(rd_en_0),
        .data_in(data_in_0),
        .full(full_0),
        .empty(empty_0),
        .data_out(data_out_0)
        // ,
        // .debug_data_out(debug_memory_out_0),
        // .debug_write_addr(debug_write_addr0),
        // .debug_read_addr(debug_read_addr0),
        // .debug_counter(debug_counter0),
        // .debug_ok_to_write(debug_ok_to_write0),
        // .debug_ok_to_read(debug_ok_to_read0)
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
        // ,
        // .debug_data_out(debug_memory_out_1),
        // .debug_write_addr(debug_write_addr1),
        // .debug_read_addr(debug_read_addr1),
        // .debug_counter(debug_counter1),
        // .debug_ok_to_write(debug_ok_to_write1),
        // .debug_ok_to_read(debug_ok_to_read1)
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
        // ,
        // .debug_data_out(debug_memory_out_2),
        // .debug_write_addr(debug_write_addr2),
        // .debug_read_addr(debug_read_addr2),
        // .debug_counter(debug_counter2),
        // .debug_ok_to_write(debug_ok_to_write2),
        // .debug_ok_to_read(debug_ok_to_read2)
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
        // ,
        // .debug_data_out(debug_memory_out_3),
        // .debug_write_addr(debug_write_addr3),
        // .debug_read_addr(debug_read_addr3),
        // .debug_counter(debug_counter3),
        // .debug_ok_to_write(debug_ok_to_write3),
        // .debug_ok_to_read(debug_ok_to_read3)
    );
 
   
    


    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            //step = 0;
            LRU_ORDER[0] = 0;
            LRU_ORDER[1] = 1;
            LRU_ORDER[2] = 2;
            LRU_ORDER[3] = 3;

            valid_M0     = 0;
            valid_M1     = 0;
            
            //data_out_M0  = 0;
            //data_out_M1  = 0;
            writeSuccess = 0;
            wholastTime = 1;

            // wr_en_0 = 0;
            // wr_en_1 = 0;
            // wr_en_2 = 0;
            // wr_en_3 = 0;

            // rd_en_0 = 0;
            // rd_en_1 = 0;
            // rd_en_2 = 0;
            // rd_en_3 = 0;
        end
        else begin
           
            
            //step = step + 1;

            // wr_en_0 = 0;
            // wr_en_1 = 0;
            // wr_en_2 = 0;
            // wr_en_3 = 0;

            read_from_0 = rd_en_0;
            read_from_1 = rd_en_1;
            read_from_2 = rd_en_2;
            read_from_3 = rd_en_3;

            valid_M0 = GigaChad_check_rd_en_M0 & ( (rd_id_M0 == 2'b00 & ~empty_0) | (rd_id_M0 == 2'b01 & ~empty_1) | (rd_id_M0 == 2'b10 & ~empty_2) | (rd_id_M0 == 2'b11 & ~empty_3) );
            valid_M1 = GigaChad_check_rd_en_M1 & ( (rd_id_M1 == 2'b00 & ~empty_0) | (rd_id_M1 == 2'b01 & ~empty_1) | (rd_id_M1 == 2'b10 & ~empty_2) | (rd_id_M1 == 2'b11 & ~empty_3) );

            //if(step == 1307)
            //$display("before GigaChad, step = %d, op = %d %d %d %d, lastone = %d", step, wr_en_M0, rd_en_M0, wr_en_M1, rd_en_M1, whoThisTime);


            //if(step >= 1300 && step <= 1310)
            //   $display("at step %d {M0_req, M1_req, wholastTime} = {%b, %b, %b}", step, M0_req, M1_req, wholastTime);
            // case({M0_req, M1_req, wholastTime})
            //     3'b110: wholastTime = 0; 
            //     3'b111: wholastTime = 1; 
            //     3'b101: wholastTime = ~wholastTime; 
            //     3'b010: wholastTime = ~wholastTime; 
            //     default: wholastTime = wholastTime; 
            // endcase
            
            


            // if(step >= 1300 && step <= 1310)
            // $display("GigaChad toggle wholastTime to %d at step %d", wholastTime, step);
        
           

            if ( (GigaChad_check_rd_en_M0 || GigaChad_check_wr_en_M0) ) begin
                
                if ( GigaChad_check_rd_en_M0 ) begin
                /*
                    if(step == 1302)
                    $display("M0 request read : Read id = %d", rd_id_M0);
                    case(rd_id_M0)
                        2'b00: begin
                            if( !empty_0 )begin
                                //rd_en_0 = 1;
                                read_state = 1;
                                read_to_who = 0;
                                read_from_who = 0;
                            end
                        end
                        2'b01: begin
                            if( !empty_1 )begin
                                //rd_en_1 = 1;
                                read_state = 1;
                                read_to_who = 0;
                                read_from_who = 1;
                            end

                        end
                        2'b10: begin
                            if( !empty_2 )begin
                                //rd_en_2 = 1;
                                read_state = 1;
                                read_to_who = 0;
                                read_from_who = 2;
                                // if(step <= 1320) begin
                                //     $display("-----request read state-----");
                                //     $display("step %d", step);
                                //     $display("read data out: from mem %d to masterM%d with value %h", read_from_who, read_to_who, data_out_2);
                                //     $display("memory 2 data = %h, %h, %h, %h, full = %d, empty = %d, wr_en_2 = %d, rd_en_2 = %d", 
                            
                                //     debug_memory_out_2[255:248], debug_memory_out_2[247:240], debug_memory_out_2[239:232], debug_memory_out_2[231:224]
                                //     , full_2, empty_2, wr_en_2, rd_en_2
                                //     );
                                //     $display("memory 2 state : write addr = %d, read addr = %d, counter = %d, ok_to_write = %d, ok_to_read = %d", 
                                //         debug_write_addr2, debug_read_addr2, debug_counter2, debug_ok_to_write2, debug_ok_to_read2
                                //     );
                                   
                                   
                                //     $display("----------------------------");
                                // end
                                    
                               
                            end
                        end
                        2'b11: begin
                            if( !empty_3 )begin
                                //rd_en_3 = 1;
                                read_state = 1;
                                read_to_who = 0;
                                read_from_who = 3;
                            end
                        end
                    endcase

                  */
                end
                if(GigaChad_check_wr_en_M0) begin
                    //if(step <= 10)
                    //$display("step %d, M0 write : LRU order = %d %d %d %d, write value %h", step, LRU_ORDER[0], LRU_ORDER[1], LRU_ORDER[2], LRU_ORDER[3], data_in_M0);
                    // case(LRU_ORDER[0])
                    //     2'b00: begin
                    //         if( !full_0 ) begin
                    //             wr_en_0 = 1;
                    //             data_in_0 = data_in_M0;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    //     2'b01: begin
                    //         if(!full_1) begin
                    //             wr_en_1 = 1;
                    //             data_in_1 = data_in_M0;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    //     2'b10: begin
                    //         if(!full_2) begin
                    //             wr_en_2 = 1;
                    //             data_in_2 = data_in_M0;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    //     2'b11: begin
                    //         if(!full_3) begin
                    //             wr_en_3 = 1;
                    //             data_in_3 = data_in_M0;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    // endcase

                    if(writeSuccess) begin
                        LRU_order_buffer = LRU_ORDER[0];
                        LRU_ORDER[0]     = LRU_ORDER[1];
                        LRU_ORDER[1]     = LRU_ORDER[2];
                        LRU_ORDER[2]     = LRU_ORDER[3];
                        LRU_ORDER[3]     = LRU_order_buffer;
                        writeSuccess = 0;
                    end        
                end
            end
            //m1 do
            else if(  (GigaChad_check_rd_en_M1 || GigaChad_check_wr_en_M1) ) begin
                
                if ( GigaChad_check_rd_en_M1 ) begin
                    /*
                    case(rd_id_M1)
                        2'b00: begin
                            if( !empty_0 )begin
                                //rd_en_0 = 1;
                                read_state = 1;
                                read_to_who = 1;
                                read_from_who = 0;
                            end
                        end
                        2'b01: begin
                            if( !empty_1 )begin
                                //rd_en_1 = 1;
                                read_state = 1;
                                read_to_who = 1;
                                read_from_who = 1;
                            end

                        end
                        2'b10: begin
                            if( !empty_2 )begin
                                //rd_en_2 = 1;
                                read_state = 1;
                                read_to_who = 1;
                                read_from_who = 2;
                            end
                        end
                        2'b11: begin
                            if( !empty_3 )begin
                                //rd_en_3 = 1;
                                read_state = 1;
                                read_to_who = 1;
                                read_from_who = 3;

                                   if(step <= 1320) begin
                                    $display("-----request read state-----");
                                    $display("step %d", step);
                                    $display("read data out: from mem %d to masterM%d with value %h", read_from_who, read_to_who, data_out_3);
                                    $display("memory 3 data = %h, %h, %h, %h, full = %d, empty = %d, wr_en_3 = %d, rd_en_3 = %d", 
                            
                                    debug_memory_out_3[255:248], debug_memory_out_3[247:240], debug_memory_out_3[239:232], debug_memory_out_3[231:224]
                                    , full_3, empty_3, wr_en_3, rd_en_3
                                    );
                                    $display("memory 3 state : write addr = %d, read addr = %d, counter = %d, ok_to_write = %d, ok_to_read = %d", 
                                        debug_write_addr3, debug_read_addr3, debug_counter3, debug_ok_to_write3, debug_ok_to_read3
                                    );
                                   
                                   
                                    $display("----------------------------");
                                end
                                    
                            end
                        end

                    endcase
                    
                    //if(step <= 1340)
                    //$display("step %d, M1 read : Read id = %d, read value %h", step, rd_id_M1, data_out_M1);
                    */
                end
                if(GigaChad_check_wr_en_M1) begin
                    //if(step <= 100)
                    //$display("step %d, M1 write : LRU order = %d %d %d %d, write value %h",step, LRU_ORDER[0], LRU_ORDER[1], LRU_ORDER[2], LRU_ORDER[3], data_in_M1);
                    
                    // case(LRU_ORDER[0])
                    //     2'b00: begin
                    //         if(!full_0) begin
                    //             wr_en_0 = 1;
                    //             data_in_0 = data_in_M1;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    //     2'b01: begin
                    //         if(!full_1) begin
                    //             wr_en_1 = 1;
                    //             data_in_1 = data_in_M1;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    //     2'b10: begin
                    //         if(!full_2) begin
                    //             wr_en_2 = 1;
                    //             data_in_2 = data_in_M1;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    //     2'b11: begin
                    //         if(!full_3) begin
                    //             wr_en_3 = 1;
                    //             data_in_3 = data_in_M1;
                    //             writeSuccess = 1;
                    //         end
                    //     end
                    // endcase

                    if(writeSuccess) begin
                        LRU_order_buffer = LRU_ORDER[0];
                        LRU_ORDER[0]     = LRU_ORDER[1];
                        LRU_ORDER[1]     = LRU_ORDER[2];
                        LRU_ORDER[2]     = LRU_ORDER[3];
                        LRU_ORDER[3]     = LRU_order_buffer;
                        writeSuccess = 0;
                    end
                end
            end


           case ({M0_req, M1_req})
                2'b11:  wholastTime = ~wholastTime;  // both request → alternate user
                2'b10:  wholastTime = 1'b0;          // only M0
                2'b01:  wholastTime = 1'b1;          // only M1
                default: wholastTime = wholastTime;
            endcase
        end
    end
endmodule
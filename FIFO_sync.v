module write_control (
	input clk,
	input reset,
	input wr_en,
	output reg [4:0] write_addr
);
	always @(posedge clk) begin
		if (reset)
			write_addr = 0;
		else begin
            if (wr_en)
			    write_addr <= write_addr + 1;
            else
                write_addr <= write_addr;
        end
    end
endmodule

module read_control (
	input clk,
	input reset,
	input rd_en,
	output reg [4:0] read_addr
);
	always @(posedge clk) begin
		if (reset)
			read_addr = 0;
		else begin
            if (rd_en)
			    read_addr <= read_addr + 1;
            else
                read_addr <= read_addr;
        end
    end
endmodule

module memoryory_block(
	input clk,
    input reset,

    input wr_en,
    input rd_en,

	input [7:0] data_in,
    input [4:0] write_addr,
    input [4:0] read_addr,
    

	output ok_to_write,
    output ok_to_read,

    output full,
    output empty,

    output reg [7:0] data_out
    // ,
    // output [255 : 0] debug_data_out,
    // output [7:0] debug_write_addr,
    // output [7:0] debug_read_addr,
    // output [5:0] debug_counter,
    // output debug_ok_to_write,
    // output debug_ok_to_read 

);
	reg [7:0] memory[0:31];
	reg [5:0] counter;

	assign ok_to_write = wr_en && !full;
    assign ok_to_read  = rd_en && !empty;
    // assign debug_write_addr = write_addr;
    // assign debug_read_addr = read_addr;
    // assign debug_ok_to_write = ok_to_write;
    // assign debug_ok_to_read = ok_to_read;
    // assign debug_counter = counter;

    // assign debug_data_out = {memory[0], memory[1], memory[2], memory[3],
    //                          memory[4], memory[5], memory[6], memory[7],
    //                          memory[8], memory[9], memory[10], memory[11],
    //                          memory[12], memory[13], memory[14], memory[15],
    //                          memory[16], memory[17], memory[18], memory[19],
    //                          memory[20], memory[21], memory[22], memory[23],
    //                          memory[24], memory[25], memory[26], memory[27],
    //                          memory[28], memory[29], memory[30], memory[31]};
    assign full  = (counter == 32);
    assign empty = (counter == 0);
	
	always @(posedge clk) begin
		if (reset) begin
			counter <= 0;
            data_out <= 0;
        end
		else begin

            if( ok_to_write && ! ok_to_read) begin
                memory[write_addr] <= data_in;
                counter <= counter + 1;
            end
            else if(! ok_to_write && ok_to_read) begin 
                data_out <= memory[read_addr];
                counter <= counter - 1;
            end
            else if(ok_to_write && ok_to_read) begin
                data_out <= memory[read_addr];
                memory[write_addr] <= data_in;
            end
            else begin 
                if(rd_en && empty)
                    data_out <= 0;
                else
                    data_out <= data_out;
            end
			
		end

	end
endmodule



module FIFO_sync(
	input             clk     ,
    input             rst     ,
    input             wr_en   ,
    input             rd_en   ,
    input       [7:0] data_in ,
    output            full    ,
    output            empty   ,
    output   [7:0] data_out
    // ,
    // output   [255 : 0] debug_data_out,
    // output [7:0] debug_write_addr,
    // output [7:0] debug_read_addr,
    // output [5:0] debug_counter,
    // output debug_ok_to_write,
    // output debug_ok_to_read 
);
	wire [4:0] write_addr;
    wire [4:0] read_addr;

    
	wire ok_to_write;
	wire ok_to_read;
	
    write_control a (
        .clk(clk),
        .reset(rst),
        .wr_en(ok_to_write),
        .write_addr(write_addr)
    );
    read_control b (
        .clk(clk),
        .reset(rst),
        .rd_en(ok_to_read),
        .read_addr(read_addr)
    );
    memoryory_block c (
    	.clk(clk),
        .reset(rst),
        
        .wr_en(wr_en),
        .rd_en(rd_en),

        .data_in(data_in),
        .write_addr(write_addr),
        .read_addr(read_addr),
        
        .ok_to_write (ok_to_write),
        .ok_to_read (ok_to_read),
        
        .full (full),
        .empty (empty),
        
        .data_out (data_out)
        // ,
        // .debug_data_out(debug_data_out),
        // .debug_counter(debug_counter),
        // .debug_read_addr(debug_read_addr),  
        // .debug_write_addr(debug_write_addr),
        // .debug_ok_to_read(debug_ok_to_read),
        // .debug_ok_to_write(debug_ok_to_write)

        
    );
endmodule

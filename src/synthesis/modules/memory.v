module memory #(
	parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input we,
    input [ADDR_WIDTH - 1:0] addr,
    input [DATA_WIDTH - 1:0] data,
    output reg [DATA_WIDTH - 1:0] out
);

	(* ram_init_file = FILE_NAME *) reg [DATA_WIDTH - 1:0] mem [2**ADDR_WIDTH - 1:0];

    integer i;

    initial begin
        mem[0]  = 16'h0000;
        mem[1]  = 16'h0000;
        mem[2]  = 16'h0000;
        mem[3]  = 16'h0000;
        mem[4]  = 16'h0000;
        mem[5]  = 16'h0000;
        mem[6]  = 16'h0000;
        mem[7]  = 16'h0000;
        mem[8]  = 16'h7101;  // IN A A = 8
        mem[9]  = 16'h8101;  // OUT A 8
        mem[10] = 16'h0210;  // MOV B, A B = 8
        mem[11] = 16'h1312;  // ADD C, A, B C = 8 + 8 = 16
        mem[12] = 16'h8301;  // OUT C 16
        mem[13] = 16'h7401;  // IN D D = 9
        mem[14] = 16'h2334;  // SUB C, C, D C = 16 - 9 = 7
        mem[15] = 16'h0530;  // MOV E, C E = 7
        mem[16] = 16'h8501;  // OUT E 7
        mem[17] = 16'h7301;  // IN C C = 3
        mem[18] = 16'h3553;  // MUL E, E, C E = 7 * 3 = 21
        mem[19] = 16'h8501;  // OUT E 21
        mem[20] = 16'hF000;  // STOP
        for (i = 21; i < 2 ** ADDR_WIDTH; i = i + 1) begin
            mem[i] = 8'b0000;
        end
    end

    always @(posedge clk) begin
        if (we) begin
            mem[addr] = data;
        end
        out <= mem[addr];
    end

endmodule

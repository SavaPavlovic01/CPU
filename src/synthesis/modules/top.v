module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16,
    parameter ADDR_HI = ADDR_WIDTH - 1,
    parameter DATA_HI = DATA_WIDTH - 1
) (
    input clk,
    input [2:0] btn,
    input [9:0] sw,
    output [9:0] led,
    output [27:0] hex
);

wire clk_div_wire;
assign rst_n = sw[9];

clk_div #(DIVISOR) CLK_DIV(
    .clk(clk),
    .rst_n(rst_n),
    .out(clk_div_wire)
);

wire [DATA_HI:0] mem_data, mem_in;
wire [ADDR_HI:0] mem_addr;
wire mem_we;
wire [10:0] cpu_out_visak;
wire [5:0] pc_out, sp_out;

cpu #(ADDR_WIDTH, DATA_WIDTH) CPU(
    .clk(clk_div_wire), //
    .rst_n(rst_n),
    .mem_in(mem_in),
    .in({{12{1'b0}},sw[3:0]}),
    .mem_we(mem_we),
    .mem_addr(mem_addr),
    .mem_data(mem_data),
    .out({cpu_out_visak, led[4:0]}),
    .pc(pc_out),
    .sp(sp_out)
);

memory #(FILE_NAME, ADDR_WIDTH, DATA_WIDTH) MEMORY(
    .clk(clk_div_wire), //
    .we(mem_we),
    .addr(mem_addr),
    .data(mem_data),
    .out(mem_in)
);


wire [5:0] BCD0_in, BCD1_in;
wire [3:0] BCD0_ones, BCD0_tens, BCD1_ones, BCD1_tens;
bcd BCD0 (
    .in(sp_out),
    .tens(BCD0_tens),
    .ones(BCD0_ones)
);
bcd BCD1 (
    .in(pc_out),
    .tens(BCD1_tens),
    .ones(BCD1_ones)
);

//assign BCD0.in = CPU.sp;
//assign BCD1.in = CPU.pc;

ssd SSD0 (
    .in(BCD0_tens),
    .out(hex[27:21]));
ssd SSD1 (
    .in(BCD0_ones),
    .out(hex[20:14]));
ssd SSD2 (
    .in(BCD1_tens),
    .out(hex[13:7]));
ssd SSD3 (
    .in(BCD1_ones),
    .out(hex[6:0]));


/*
assign SSD0.in = BCD0_tens;
assign SSD1.in = BCD0_ones;
assign SSD2.in = BCD1_tens;
assign SSD3.in = BCD1_ones;
*/
//assign hex[27:21] = SSD0.out;
//assign hex[20:14] = SSD1.out;
//assign hex[13:7]  = SSD2.out;
//assign hex[6:0]   = SSD3.out;

endmodule

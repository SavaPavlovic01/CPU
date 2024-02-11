module cpu_test ();

    reg dut_clk, dut_rst;
    wire dut_mem_we;
    wire [5:0] dut_mem_addr;
    wire [15:0] dut_mem_data;
    wire [15:0] dut_mem_out;
    reg [15:0] dut_in;
    wire [15:0] dut_out;
    wire [5:0] dut_pc;
    wire [5:0] dut_sp;

    memory mem(dut_clk,dut_mem_we,dut_mem_addr,dut_mem_data,dut_mem_out);

    cpu procesor(dut_clk,dut_rst,dut_mem_out,dut_in,dut_mem_we,dut_mem_addr,dut_mem_data,dut_out,dut_pc,dut_sp);

    initial begin
        dut_rst = 1'b0;
        dut_clk = 1'b0;
        dut_in = 8;
        #2;
        dut_rst = 1'b1;
        #50 dut_in = 9;
        #240 dut_in = 3;
        #2000 $finish;
    end

    initial begin
        // MEM_OUT i MEM_DATA SU HEX!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        $monitor("time = %4d, out = %4d, pc = %4d, sp = %4d, mem_addr = %4d, mem_out = %4h, mem_data = %4h, mem_we = %b", 
        $time, dut_out, dut_pc, dut_sp, dut_mem_addr, dut_mem_out, dut_mem_data, dut_mem_we);
    end

    always begin
        #5 dut_clk = ~dut_clk;
    end
endmodule
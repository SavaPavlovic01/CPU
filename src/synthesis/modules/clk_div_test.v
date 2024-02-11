module clk_div_test();
    reg dut_clk,dut_rst;
    wire out_clk;

    clk_div t(dut_clk,dut_rst,out_clk);

    initial begin
        dut_clk = 1'b0;
        dut_rst = 1'b0;
        #2 dut_rst = 1'b1;
        #500 $finish;
    end

    always begin
        #5 dut_clk = ~dut_clk;
    end

    always @(*) begin
        $strobe("clk = %b, out_clk = %b", dut_clk, out_clk);
    end
endmodule
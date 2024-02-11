module top ();
    reg [2:0] op;
    reg [3:0] first, second;
    wire [3:0] out;

    reg dut_clk,dut_rst_n,dut_cl,dut_ld,dut_inc,dut_dec,dut_sr,dut_ir,dut_sl,dut_il;
    reg [3:0] dut_in;
    wire [3:0] dut_out;

    alu t(.oc(op), .a(first), .b(second), .f(out));

    register t1(dut_clk,dut_rst_n,dut_cl,dut_ld,dut_in,dut_inc,dut_dec,dut_sr,dut_ir,dut_sl,dut_il,dut_out);

    integer i;

    initial begin
        op = 3'b000;
        first = 4'h0;
        second = 4'h0;

        for(i = 0; i<2**11; i = i + 1) begin
            if(i == 1024) $stop;
            {op,first,second} = i;
            #5;
        end
        $stop;

        dut_rst_n = 1'b0;
        dut_clk = 1'b0;
        dut_cl = 1'b0;
        dut_ld = 1'b0;
        dut_in = 4'h0;
        dut_inc = 1'b0;
        dut_dec = 1'b0;
        dut_sr = 1'b0;
        dut_ir = 1'b0;
        dut_sl = 1'b0;
        dut_il = 1'b0;
        #2 dut_rst_n = 1'b1;
        repeat(1000) begin
            #5;
            dut_ld = $urandom % 2;
            dut_cl = $urandom % 2;
            dut_in = $urandom_range(15);
            dut_inc = $urandom % 2;
            dut_dec = $urandom % 2;
            dut_sr = $urandom % 2;
            dut_ir = $urandom % 2;
            dut_sl = $urandom % 2;
            dut_il = $urandom % 2;

        end
        #10 $finish;
    end

    initial begin
        $monitor(
            "time = %4d, oc = %b, a = %4d, b = %4d, f = %4d",
            $time, op, first, second, out
        );
    end

    always begin
        #5 dut_clk = ~dut_clk;
    end

    always @(dut_out) begin
        $strobe(
            "time = %4d, ld = %b, cl = %b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, in = %4d, out = %4d ",
            $time, dut_ld, dut_cl, dut_inc, dut_dec, dut_sr, dut_ir, dut_sl, dut_il, dut_in, dut_out 
        );
    end
        

endmodule
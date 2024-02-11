module bcd_test ();
    reg [5:0] dut_in;
    wire [3:0] dut_ones, dut_tens;

    integer i;

    bcd t(dut_in,dut_ones,dut_tens);

    initial begin
        dut_in = 0;
        for(i = 0;i<2**6;i=i+1)begin
            dut_in = i;
            #5;
        end
        $finish;
    end

    initial begin
        $monitor("time = %4d, in = %4d, ones = %4d, tens = %4d", $time, dut_in, dut_ones, dut_tens);
    end
endmodule
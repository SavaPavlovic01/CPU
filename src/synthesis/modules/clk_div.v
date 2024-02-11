module clk_div #(parameter DIVISOR = 50000000)(clk,rst_n,out);
    input clk; 
    output reg out;
    reg[27:0] counter=28'd0;
    input rst_n;

    always @(posedge clk,negedge rst_n) begin
        if(!rst_n) begin
            counter <= 0;
            out <= 1'b0;
        end else begin
            counter <= counter + 28'd1;
            if(counter>=(DIVISOR-1))
                counter <= 28'd0;
            out <= (counter<DIVISOR/2)?1'b1:1'b0; 
        end
        
    end
endmodule
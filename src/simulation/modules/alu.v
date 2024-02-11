module alu (oc,a,b,f);
    input [2:0] oc;
    input [3:0] a,b;
    output reg [3:0] f;
    
    localparam ADD = 3'b000 ;
    localparam SUB = 3'b001 ;
    localparam MUL = 3'b010 ;
    localparam DIV = 3'b011 ;
    localparam NOT = 3'b100 ;
    localparam XOR = 3'b101 ;
    localparam OR  = 3'b110 ;
    localparam AND = 3'b111 ;
    
    always @(oc,a,b,f) begin
        case (oc)
            ADD: begin
                f = a + b;
            end
            SUB: begin
                f = a - b;
            end
            MUL: begin
                f = a * b;
            end
            DIV: begin
                if (b == 4'h0) begin
                    f = 0;
                end else begin
                    f = a / b;
                end       
            end
            NOT:begin
                f = ~a;
            end
            XOR:begin
                f = a^b;
            end
            OR:begin
                f = a | b; 
            end
            AND:begin
                f = a & b;
            end     
        endcase
    end
endmodule
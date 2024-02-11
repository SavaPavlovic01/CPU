module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (clk,rst_n,mem_in,in,mem_we,mem_addr,mem_data,out,pc,sp);

    input clk,rst_n;
    input [DATA_WIDTH-1:0] mem_in,in;
    output reg mem_we;
    output reg [ADDR_WIDTH-1:0] mem_addr;
    output [ADDR_WIDTH-1:0] pc,sp;
    output [DATA_WIDTH-1:0] out;
    output reg [DATA_WIDTH-1:0] mem_data;

    reg [27:0] cnt_reg, cnt_next;
    reg [DATA_WIDTH-1:0] out_reg,out_next;

    assign out = out_reg;

    reg cl_pc,ld_pc,inc_pc,dec_pc,sr_pc,ir_pc,sl_pc,il_pc;
    reg [5:0] in_pc;
    register #(.DATA_WIDTH(6)) reg_pc (clk,rst_n,cl_pc,ld_pc,in_pc,inc_pc,dec_pc,sr_pc,ir_pc,sl_pc,il_pc,pc);

    reg cl_sp,ld_sp,inc_sp,dec_sp,sr_sp,ir_sp,sl_sp,il_sp;
    reg [5:0] in_sp;
    register #(.DATA_WIDTH(6)) reg_sp (clk,rst_n,cl_sp,ld_sp,in_sp,inc_sp,dec_sp,sr_sp,ir_sp,sl_sp,il_sp,sp);

    reg cl_irl,ld_irl,inc_irl,dec_irl,sr_irl,ir_irl,sl_irl,il_irl;
    reg [15:0] in_irl;
    wire [15:0] out_irl;
    register #(.DATA_WIDTH(16)) reg_irl (clk,rst_n,cl_irl,ld_irl,in_irl,inc_irl,dec_irl,sr_irl,ir_irl,sl_irl,il_irl,out_irl);
    
    reg cl_irh,ld_irh,inc_irh,dec_irh,sr_irh,ir_irh,sl_irh,il_irh;
    reg [15:0] in_irh;
    wire [15:0] out_irh;
    register #(.DATA_WIDTH(16)) reg_irh (clk,rst_n,cl_irh,ld_irh,in_irh,inc_irh,dec_irh,sr_irh,ir_irh,sl_irh,il_irh,out_irh);

    reg cl_acc,ld_acc,inc_acc,dec_acc,sr_acc,ir_acc,sl_acc,il_acc;
    reg [31:0] in_acc;
    wire [31:0] out_acc;
    register #(.DATA_WIDTH(32)) reg_acc (clk,rst_n,cl_acc,ld_acc,in_acc,inc_acc,dec_acc,sr_acc,ir_acc,sl_acc,il_acc,out_acc);

    reg [2:0] oc_alu;
    reg[DATA_WIDTH-1:0] a_alu,b_alu;
    wire[DATA_WIDTH-1:0] f_alu;
    alu #(.DATA_WIDTH(DATA_WIDTH)) inst_alu(oc_alu,a_alu,b_alu,f_alu);

    localparam FETCH =  5'h00;
    localparam DECODE = 5'h01;
    localparam EXEC1 =  5'h02;
    localparam READING_ALU_FIRST_0 = 5'h03 ;
    localparam READING_ALU_FIRST_1 =  5'h04;
    localparam READING_ALU_SECOND_0 = 5'h05;
    localparam READING_ALU_SECOND_1 = 5'h06;
    localparam STORING_ALU_0 = 5'h07;
    localparam STORING_ALU_1 = 5'h08;
    localparam READING_OUT_0 = 5'h09;
    localparam READING_OUT_1 = 5'h0a;
    localparam START = 5'h0b;
    localparam STOP = 5'h0c;
    localparam STOP_FIRST_0 = 5'h0d;
    localparam STOP_FIRST_1 = 5'h0e;
    localparam STOP_SECOND_0 = 5'h0f;
    localparam STOP_SECOND_1 = 5'h10;
    localparam STOP_THIRD_0 = 5'h11;
    localparam STOP_THIRD_1 = 5'h12;

    localparam OPCODE_MOV = 4'h0;
    localparam OPCODE_ADD = 4'h1;
    localparam OPCODE_SUB = 4'h2;
    localparam OPCODE_MUL = 4'h3;
    localparam OPCODE_DIV = 4'h4;
    localparam OPCODE_IN = 4'h7;
    localparam OPCODE_OUT = 4'h8;
    localparam OPCODE_STOP = 4'hf;

    reg [4:0] state_next, state_reg;

    always @(posedge clk,negedge rst_n) begin
        if(!rst_n) begin
            state_reg = START;
        end else begin
            state_reg <= state_next;
            out_reg <= out_next;
        end
    end


    always @(*) begin
        state_next = state_reg;
        out_next = out_reg;

        mem_data = 0;
        mem_we = 0;
        mem_addr = 0;

        a_alu = 0;
        b_alu = 0;
        oc_alu = 0;

        ld_acc = 0;
        in_acc = 0;
        inc_acc = 0;
        dec_acc = 0;
        sr_acc = 0;
        sl_acc = 0;

        in_irl = 0;
        ld_irl = 0;
        inc_irl = 0;
        dec_irl = 0;
        sr_irl = 0;
        sl_irl = 0;

        in_irh = 0;
        ld_irh = 0;
        inc_irh = 0;
        dec_irh = 0;
        sr_irh = 0;
        sl_irh = 0;

        in_sp = 0;
        ld_sp = 0;
        inc_sp = 0;
        dec_sp = 0;
        sr_sp = 0;
        sl_sp = 0;

        in_pc = 0;
        ld_pc = 0;
        inc_pc = 0;
        dec_pc = 0;
        sr_pc = 0;
        sl_pc = 0;
        
        case (state_reg)
            START:begin
                ld_pc = 1;
                in_pc = 8;
                ld_sp = 1;
                in_sp = 63;
                state_next = FETCH;
            end

            FETCH: begin
                mem_addr = pc;
                inc_pc = 1'b1;
                state_next = DECODE;
            end

            DECODE: begin
                ld_irh = 1'b1;
                in_irh = mem_in;
                if(mem_in[15:12] == OPCODE_MOV && mem_in[3:0] == 4'b1000) begin
                    mem_addr = pc;
                    inc_pc = 1'b1;
                end
                state_next = EXEC1;
            end

            EXEC1: begin
                ld_irl = 1'b1; // ako treba zbog mov, ako nije mov onda samo imas isto u irl i irh
                in_irl = mem_in;
                
                case (out_irh[15:12])
                    OPCODE_ADD: begin
                        mem_addr = out_irh[6:4];
                        state_next = READING_ALU_FIRST_0;
                    end 
                    OPCODE_SUB: begin
                        mem_addr = out_irh[6:4];
                        state_next = READING_ALU_FIRST_0;
                    end
                    OPCODE_MUL: begin
                        mem_addr = out_irh[6:4];
                        state_next = READING_ALU_FIRST_0;
                    end
                    OPCODE_DIV: begin
                        state_next = FETCH;
                    end    
                    OPCODE_MOV: begin
                        if(out_irh[3:0] == 4'b1000) begin
                            ld_acc = 1'b1;
                            in_acc = mem_in;
                            state_next = STORING_ALU_0;
                        end else begin
                            mem_addr = out_irh[6:4];
                            state_next = READING_ALU_FIRST_0;
                        end
                    end
                    OPCODE_IN: begin
                        in_acc = in;
                        ld_acc = 1'b1;
                        state_next = STORING_ALU_0;
                    end
                    OPCODE_OUT: begin
                        mem_addr = out_irh[10:8];
                        state_next = READING_OUT_0;
                    end
                    OPCODE_STOP: begin
                        if(out_irh[11:8]!= 4'h0) begin
                            mem_addr = out_irh[10:8];
                            state_next = STOP_FIRST_0;
                        end else if(out_irh[7:4]!=4'h0) begin
                            mem_addr = out_irh[6:4];
                            state_next = STOP_SECOND_0;
                        end else if(out_irh[3:0]!=4'h0) begin
                            mem_addr = out_irh[2:0];
                            state_next = STOP_THIRD_0;
                        end else begin
                            state_next = STOP;
                        end
                    end
                endcase
            end

            READING_ALU_FIRST_0: begin
                if(!out_irh[7]) begin
                    ld_acc = 1'b1;
                    in_acc = mem_in;
                    mem_addr = out_irh[2:0];
                    if(out_irh[15:12] == OPCODE_MOV) begin
                        state_next = STORING_ALU_0;
                    end else begin
                       state_next = READING_ALU_SECOND_0; 
                    end
                       
                end else begin
                    mem_addr = mem_in;
                    state_next = READING_ALU_FIRST_1;
                end
            end

            READING_OUT_0: begin
                if(!out_irh[11]) begin
                    out_next = mem_in;
                    state_next = FETCH;
                end else begin
                    mem_addr = mem_in;
                    state_next = READING_OUT_1;
                end
            end

            READING_OUT_1: begin
                out_next = mem_in;
                state_next = FETCH;
            end

            READING_ALU_FIRST_1: begin
                ld_acc = 1'b1;
                in_acc = mem_in;
                mem_addr = out_irh[2:0];
                if(out_irh[15:12] == OPCODE_MOV) begin
                    state_next = STORING_ALU_0;
                end else begin
                    state_next = READING_ALU_SECOND_0; 
                end
            end

            READING_ALU_SECOND_0:begin
                if(!out_irh[3]) begin
                    case(out_irh[15:12])
                        OPCODE_ADD: oc_alu = 3'b000;
                        OPCODE_SUB: oc_alu = 3'b001;
                        OPCODE_MUL: oc_alu = 3'b010;
                        OPCODE_DIV: oc_alu = 3'b011;
                    endcase
                    b_alu = mem_in;
                    a_alu = out_acc;
                    in_acc = f_alu;
                    ld_acc = 1'b1;  
                    mem_addr = out_irh[10:8];
                    state_next = STORING_ALU_0;      
                end else begin
                    mem_addr = mem_in;
                    state_next = READING_ALU_SECOND_1;
                end
            end

            READING_ALU_SECOND_1: begin
                case(out_irh[15:12])
                    OPCODE_ADD: oc_alu = 3'b000;
                    OPCODE_SUB: oc_alu = 3'b001;
                    OPCODE_MUL: oc_alu = 3'b010;
                    OPCODE_DIV: oc_alu = 3'b011;
                endcase
                b_alu = mem_in;
                a_alu = out_acc;
                in_acc = f_alu;
                ld_acc = 1'b1;
                mem_addr = out_irh[10:8];
                state_next = STORING_ALU_0; 
            end

            STORING_ALU_0: begin
                if(!out_irh[11]) begin
                    mem_addr = out_irh[10:8];
                    mem_we = 1'b1;
                    mem_data = out_acc;
                    state_next = FETCH;    
                end else begin
                    mem_addr = mem_in;
                    mem_we = 1'b1;
                    mem_data = out_acc;
                    state_next = FETCH;
                end
            end

            STOP: begin
                state_next = STOP;
            end

            STOP_FIRST_0: begin
                if(!out_irh[11]) begin
                    out_next = mem_in;
                    if(out_irh[7:4]!=4'h0) begin
                        mem_addr = out_irh[6:4];
                        state_next = STOP_SECOND_0;
                    end else if(out_irh[3:0]!=4'h0) begin
                        mem_addr = out_irh[2:0];
                        state_next = STOP_THIRD_0;
                    end else begin
                        state_next = STOP;
                    end    
                end else begin
                    mem_addr = mem_in;
                    state_next = STOP_FIRST_1;
                end
            end

            STOP_FIRST_1: begin
                out_next = mem_in;
                if(out_irh[7:4]!=4'h0) begin
                    mem_addr = out_irh[6:4];
                    state_next = STOP_SECOND_0;
                end else if(out_irh[3:0]!=4'h0) begin
                    mem_addr = out_irh[2:0];
                    state_next = STOP_THIRD_0;
                end else begin
                    state_next = STOP;
                end
            end

            STOP_SECOND_0: begin
                if(!out_irh[7]) begin
                    out_next = mem_in;
                    if(out_irh[3:0]!=4'h0) begin
                        mem_addr = out_irh[2:0];
                        state_next = STOP_THIRD_0;
                    end else begin
                        state_next = STOP;
                    end    
                end else begin
                    mem_addr = mem_in;
                    state_next = STOP_SECOND_1;
                end                
            end

            STOP_SECOND_1: begin
                out_next = mem_in;
                if(out_irh[3:0]!=4'h0) begin
                    mem_addr = out_irh[2:0];
                    state_next = STOP_THIRD_0;
                end else begin
                    state_next = STOP;
                end
            end

            STOP_THIRD_0: begin
                if(!out_irh[3]) begin   
                    out_next = mem_in;
                    state_next = STOP;    
                end else begin
                    mem_addr = mem_in;
                    state_next = STOP_THIRD_1;
                end                
            end

            STOP_THIRD_1: begin
                out_next = mem_in;
                state_next = STOP;
            end
        endcase
    end
endmodule
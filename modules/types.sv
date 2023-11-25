package Types;
    typedef logic [31:0] word;
    typedef logic [4:0] a_reg;
    typedef logic [6:0] p_reg;
    typedef struct {
        a_reg ARegAddrSrc0;
        a_reg ARegAddrSrc1;
        a_reg ARegAddrDst;
        word  immediate;
        // 3 bits for 6 ALU operations
        // 000 NOP
        // 001 ADD
        // 010 SUB
        // 011 XOR
        // 100 AND
        // 101 SRA
        logic [2:0] ALUOp;
        logic ALUSrc;
        logic RegWrite;
        logic MemRead;
        logic MemWrite;
        logic MemtoReg;
    } decode_struct;
    typedef struct {
        p_reg PRegAddrSrc0;
        p_reg PRegAddrSrc1;
        p_reg PRegAddrDst;
        p_reg OldPRegAddrDst;
        word  immediate;
        // 3 bits for 6 ALU operations
        // 000 NOP
        // 001 ADD
        // 010 SUB
        // 011 XOR
        // 100 AND
        // 101 SRA
        logic [2:0] ALUOp;
        logic ALUSrc;
        logic RegWrite;
        logic MemRead;
        logic MemWrite;
        logic MemtoReg;
    } rename_struct;
endpackage: Types
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

    typedef struct {
        word r_addr;
        word w_addr;
        word w_data;
        logic w_en;
    } memory_request;

    typedef struct {
        word r_data;
    } memory_response;

    typedef struct {
        logic valid;
        p_reg PRegAddrDst;
        p_reg OldPRegAddrDst;
        logic complete;
    } rob_row_struct;

    typedef struct {
        logic in_use;

        p_reg PRegAddrDst;
        p_reg OldPRegAddrDst;

        p_reg PRegAddrSrc0;
        logic Src0Ready;
        word  src0;
        
        p_reg PRegAddrSrc1;
        logic Src1Ready;
        word  src1;
        
        word immediate;

        logic [2:0] ALUOp;
        logic ALUSrc;
        logic RegWrite;
        logic MemRead;
        logic MemWrite;
        logic MemtoReg;

        // 2 bits for 3 functional units
        // 00 FU1
        // 01 FU2
        // 10 FU3 (mem only)
        logic [1:0] fu;
        // ROB has 16 rows (can change to have more if needed)
        logic [3:0] ROBNumber;
    } rs_row_struct;

    typedef struct {
        logic [3:0] ROBNumber;
        logic RegWrite;
        logic MemWrite;
        logic MemtoReg;
        logic ready;

        word FU_Result;
    } complete_stage_struct;
endpackage: Types
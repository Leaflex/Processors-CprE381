-------------------------------------------------------------------------
-- Lex Somers & Remington Greatline
-------------------------------------------------------------------------


-- ControlUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a control unit
-- for a pipelined processor
--
--
-- NOTES:
-- 4/25/23 by LS & RG::Design created.
-------------------------------------------------------------------------
-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity ControlUnit is
	port(
        i_opcode    : in std_logic_vector(5 downto 0);
        i_funct     : in std_logic_vector(5 downto 0);
        o_Ctrl_Unt  : out std_logic_vector(15 downto 0)
    );
end ControlUnit;

-------------------------------------- FORMAT of o_Ctrl_Unt --------------------------------------
-- " 15     14      13       12-8	      7	        6      5       4       3       2    1   0
-- " 0      0       0       00000          0         0      1       1       0       1    0"  0
-- " jr     jal     ALUSrc  ALUControl  MemtoReg  we_mem  we_reg  RegDst  Branch  SignExt j" Halt
--------------------------------------------------------------------------------------------------

-- architecture
architecture dataflow of ControlUnit is

    signal s_RTYPE : std_logic_vector(15 downto 0);

begin

    with i_funct select s_RTYPE <=
        "0000000100110100"  when "100000", -- add
        "0000001100110100"  when "100001", -- addu
        "0000010000110100"  when "100100", -- and
        "0000010100110100"  when "100111", -- nor
        "0000011000110100"  when "100110", -- xor
        "0000011100110100"  when "100101", -- or
        "0000110000110100"  when "101010", -- slt
        "0000110000110100"  when "101011", -- sltu (same as slt)
        "0000100100110100"  when "000000", -- sll
        "0000101000110000"  when "000010", -- srl
        "0000101100110100"  when "000011", -- sra
        "0000001000110100"  when "100010", -- sub
        "0000100000110100"  when "100011", -- subu
        "1000000000000110"  when "001000", -- jr
        "0000000000000000"  when others;

    with i_opcode select o_Ctrl_Unt <=
        s_RTYPE  	    when "000000", -- RTYPE
        "0010000100100100"  when "001000", -- addi

        "0000000000000001"  when "010100", -- halt

        "0010001100100100"  when "001001", -- addiu
        "0010010000100000"  when "001100", -- andi
        "0010011000100000"  when "001110", -- xori
        "0010011100100000"  when "001101", -- ori
        "0010110000100100"  when "001010", -- slti
        "0010110000100100"  when "001011", -- sltiu (same implementation as slti)
        "0010110100100100"  when "001111", -- lui
        "0000111000001100"  when "000100", -- beq
        "0000111100001100"  when "000101", -- bne
        "0001000000001100"  when "010110", -- bgez
        "0001000100001100"  when "000111", -- bgtz
        "0001001000001100"  when "000110", -- blez
        "0010000110100100"  when "100011", -- lw
        "0010000101000100"  when "101011", -- sw
        "0000000000000110"  when "000010", -- j
        "0100000000100110"  when "000011", -- jal
        "0000000000000000"  when others;

end dataflow;
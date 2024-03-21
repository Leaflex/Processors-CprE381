---------------------------------------------------------------------------------------------
-- Lex Somers & Remington Greatline
-- Department of Electrical and Computer Engineering
-- Iowa State University
---------------------------------------------------------------------------------------------
-- ALU.vhd
---------------------------------------------------------------------------------------------
-- DESCRIPTION: A toplevel Arithmetic logical Unit designed for a single Cycle MIPS Processor
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; --Is this for the arrays?

entity ALU is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
		i_Data1 	: in std_logic_vector(31 downto 0);
		i_Data2 	: in std_logic_vector(31 downto 0);
		i_ALUOp 	: in std_logic_vector(4 downto 0); --This is decoded into instructions for the ALU
		i_ShiftAmt 	: in std_logic_vector(4 downto 0); -- This is bits 10-6 of the Instruction. Specifies shift amount for the shifter.
		o_Zero 		: out std_logic; -- checks if two inputs are the same. used for branching
		o_Out 		: out std_logic_vector(31 downto 0);
		o_Overflow 	: out std_logic
	);
end ALU;

architecture hybrid of ALU is

	component alu_addersubtractor is
		port(
			nAdd_Sub	: in std_logic;
			i_A 		: in std_logic_vector(N-1 downto 0);
			i_B			: in std_logic_vector(N-1 downto 0);
			o_Y			: out std_logic_vector(N-1 downto 0);
			o_Overflow	: out std_logic
		);
	end component;

	component shifter is
		port(
			i_Input		: in std_logic_vector(31 downto 0);
			i_ShiftAmt	: in std_logic_vector (4 downto 0);
			i_ShiftType : in std_logic;	-- 0 == logical and 1 == arithmetic shift
			i_LeftRight	: in std_logic;	-- 0 == left shift and 1 == right shift
			o_Output	: out std_logic_vector(31 downto 0)
		);
	end component;

	component mux2t1_N is
		port(
			i_S          : in std_logic;
			i_D0         : in std_logic_vector(31 downto 0);
			i_D1         : in std_logic_vector(31 downto 0);
			o_O          : out std_logic_vector(31 downto 0)
		);
	end component;

	signal s_nAdd_Sub		: std_logic; -- Following "select when" cases defines this signal's value
	signal s_Add_Sub_Out	: std_logic_vector(N-1 downto 0); -- Holds ALU output from add/sub instructions
	signal s_AddSubZero		: std_logic; -- Holds whether or not the output of the adder subractor was zero or not. 0 when it was, 1 when it was not zero
	signal s_Data2			: std_logic_vector(31 downto 0); -- Holds the second input to addersubtractor chosen by the opcode

	signal s_Logical_Out	: std_logic_vector(N-1 downto 0); -- Holds ALU output from logical instructions

	signal s_ShiftType		: std_logic; -- Holds the shift type input specified from the opcode
	signal s_ShiftDir		: std_logic; -- Holds the shift direction input specified from the opcode
	signal s_Shifter_Out	: std_logic_vector(N-1 downto 0); -- Holds ALU output from shift instructions
	signal s_ShiftAmt		: std_logic_vector(4 downto 0); -- Holds the shift amount input chosen by opcode
	
	signal s_SLT_Out		: std_logic_vector(N-1 downto 0); -- Holds ALU output from slt and slti instructions. Also used for branch conditions. 1 when i_A is less than i_B, 0 when greater than or equal to zero

	signal s_MUX_ALU_Sel1	: std_logic; -- Selects either logic output or adder output intermediate ALU output
	signal s_MUX_ALU1_OUT	: std_logic_vector(N-1 downto 0); -- Holds the ALU_MUX1 output 
	signal s_MUX_ALU_Sel2	: std_logic; -- Selects either shifter output or s_MUX_ALU1_OUT as final ALU output
	signal s_MUX_ALU2_OUT	: std_logic_vector(N-1 downto 0); -- Holds the ALU_MUX2 output \
	signal s_MUX_ALU_Sel3	: std_logic; -- Selects either logic output or adder output intermediate ALU output

	signal s_Branch		: std_logic_vector(5 downto 0); -- Holds a a combination of the s_AddSubZero, i_ALUOp, and s_SLT_OUT that is to be used to check if you should branch.

begin

	with i_ALUOp select s_nAdd_Sub <= -- performs add and subtract operations. 1 means subtraction.
		'0' when "00001", -- add, addi, sw, lw
		'0' when "00011", -- addu, addiu

		'1' when "00010", -- sub
		'1' when "01000", -- subu (opcode is not 4 because I made a mistake on the control table and didn't want to change all the other instructions opcodes.)
		'1' when "01100", -- slt, slti
		'1' when "01110", -- beq
		'1' when "01111", -- bne
		--TODO: Implement more ALU operations
		'0' when others;

	with i_ALUOp select s_Data2 <= -- Takes hard coded zero value for data2 when instruction is any of the branches below
		32x"0" when "10000", -- bgez
		32x"0" when "10001", -- bgtz
		32x"0" when "10010", -- blez

		i_Data2 when others;


		
	with s_Add_Sub_Out select s_AddSubZero <= -- Sets s_AddSubZero to 0 if the difference of the two inputs to the addersubtractor were equal and reuslted in 0
		'0' when 32x"0", 
		'1' when others;
		
	with s_Add_Sub_Out(31) select s_SLT_Out <= -- Sets output to 1 if i_A is less than i_B
		32x"1" when '1', 
		32x"0" when others;



	with i_ALUOp select s_Logical_Out <= --performs logic operations
		i_Data1 and i_Data2 when "00100", -- and, andi
		i_Data1 nor i_Data2 when "00101", -- nor
		i_Data1 xor i_Data2 when "00110", -- xor, xori
		i_Data1 or  i_Data2 when "00111", -- or, ori
		32x"0" when others;



	with i_ALUOp select s_ShiftAmt <= -- Chooses to shift 16 for lui or shift the amount specified in bits 10-6 of the instruction.
		"10000" when "01101", -- lui

		i_ShiftAmt when others;

	with i_ALUOp select s_ShiftType <= -- Chooses what type of shift the shifter is to perform
		'0' when "01001", -- sll
		'0' when "01010", -- srl
		'0' when "01101", -- lui
		
		'1' when "01011", -- sra

		'0' when others;

	with i_ALUOp select s_ShiftDir <= -- Chooses what direction to shift the input to the shifter.
		'0' when "01001", -- sll
		'0' when "01101", -- lui

		'1' when "01010", -- srl
		'1' when "01011", -- sra

		'0' when others;



	with i_ALUOp select s_MUX_ALU_Sel1 <= -- Chooses select signal value for MUX_ALU_OUT1
		'0' when "00001", -- add, addi, sw, lw
		'0' when "00010", -- sub
		'0' when "00011", -- addu, addiu
		'0' when "01000", -- subu 

		'1' when "00100", -- and, andi
		'1' when "00101", -- nor
		'1' when "00110", -- xor, xori
		'1' when "00111", -- or, ori

		'0' when others;

	with i_ALUOp select s_MUX_ALU_Sel2 <= -- Chooses select signal value for MUX_ALU_OUT2 
		'1' when "01001", -- sll
		'1' when "01010", -- srl
		'1' when "01011", -- sra
		'1' when "01101", -- lui

		'0' when "01100", -- slt, slti

		'0' when others; -- non shifter using instructions

	with i_ALUOp select s_MUX_ALU_Sel3 <= -- Chooses select signal value for MUX_ALU_OUT3
		'0' when "00001", -- add, addi, sw, lw
		'0' when "00010", -- sub
		'0' when "00011", -- addu, addiu
		'0' when "01000", -- subu 
		'0' when "00100", -- and, andi
		'0' when "00101", -- nor
		'0' when "00110", -- xor, xori
		'0' when "00111", -- or, ori

		'1' when "01001", -- sll
		'1' when "01010", -- srl
		'1' when "01011", -- sra
		'1' when "01100", -- slt, slti
		'1' when "01101", -- lui

		'0' when others; -- when other instructions

	ADDER_SUBTRACTOR: alu_addersubtractor 
		port map( --Performs math 
			nAdd_Sub 	=> s_nAdd_Sub,
			i_A 		=> i_Data1,
			i_B 		=> i_Data2,
			o_Y 		=> s_Add_Sub_Out,
			o_Overflow 	=> o_Overflow
		);

	SHIFTER1: shifter --Had to change the name of the instance to "SHIFTER1" due to compile error 
		port map( -- Shifts input value i_ShiftAmt amount in s_ShiftDir direction for a shift of type s_ShiftType (logical or arithmetic)
			i_Input		=> i_Data2,
			i_ShiftAmt	=> s_ShiftAmt,
			i_ShiftType => s_ShiftType,
			i_LeftRight	=> s_ShiftDir,
			o_Output	=> s_Shifter_Out
		);



	s_Branch <= (s_AddSubZero & i_ALUOp); -- Holds a a combination of the s_AddSubZero, i_ALUOp, and s_SLT_OUT that is to be used to check if you should branch.

	with s_Branch select o_Zero <= -- Selects when to branch or not. "and link" branches are not included.
		'1' when "001110", -- beq
		'1' when "101111", -- bne
		--'1' when "X1000000000000000000000000000000000000", -- bgez
		--'1' when "11000100000000000000000000000000000000", -- bgtz

		--'1' when "010010XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", -- blez 1
		--'1' when "X1001000000000000000000000000000000000", -- blez 2

		'0' when others;



	MUX_ALU_OUT1: mux2t1_N 
		port map( --selects output of Addersubtracter or logic
			i_S 	=> s_MUX_ALU_Sel1,
			i_D0 	=> s_Add_Sub_Out,
			i_D1 	=> s_Logical_Out,
			o_O 	=> s_MUX_ALU1_OUT
		);

	MUX_ALU_OUT2: mux2t1_N
		port map( -- Selects output of ALU between the output of the shifter and the output of AdderSubtrator/Logic Mux
			i_S 	=> s_MUX_ALU_Sel2,
			i_D0 	=> s_SLT_Out,
			i_D1 	=> s_Shifter_Out,
			o_O 	=> s_MUX_ALU2_OUT
		);

	MUX_ALU_OUT3: mux2t1_N
		port map( -- Selects output of ALU between the output of the MUX_ALU_OUT 1 and 2
			i_S 	=> s_MUX_ALU_Sel3,
			i_D0 	=> s_MUX_ALU1_OUT,
			i_D1 	=> s_MUX_ALU2_OUT,
			o_O 	=> o_Out
		);

end hybrid;
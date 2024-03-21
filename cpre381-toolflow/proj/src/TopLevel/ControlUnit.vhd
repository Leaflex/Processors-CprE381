
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; --Is this for the arrays?

entity ControlUnit is
	port(
		i_Instr 	: in std_logic_vector(31 downto 0);
		o_RegDst	: out std_logic_vector(1 downto 0);
		o_Jump 		: out std_logic;
		o_Branch 	: out std_logic;
		--o_MemRead 	: out std_logic;
		o_MemtoReg 	: out std_logic_vector(1 downto 0);
		o_ALUOp 	: out std_logic_vector(4 downto 0); -- Controls what operation the ALU does and what it outputs
		o_MemWrite 	: out std_logic;
		o_ALUSrc 	: out std_logic;
		o_RegWrite 	: out std_logic;
		o_Jal		: out std_logic; --RG: TODO: Test for jal signal
		o_Jr		: out std_logic;
		o_Halt		: out std_logic -- TODO Connect this to whatever it needs to go to
	);
end ControlUnit;

architecture behavioral of ControlUnit is

	signal s_whenCondition : std_logic_vector(11 downto 0);
	signal s_o_ALUOp : std_logic_vector(9 downto 0); --RG: Used to determine which signal to use for o_ALUOp
	signal s_o_ALUOp_temp : std_logic_vector(5 downto 0); --RG: Also used to help with ALUOp statements
	signal s_o_RegWrite : std_logic_vector(1 downto 0); --RG: Helps with o_RegWrite processing
	signal s_o_RegWrite_tmp : std_logic; --RG: Same gig as line above
	signal s_o_Jump : std_logic_vector(1 downto 0);

begin

	s_whenCondition <= i_Instr(31 downto 26) & i_Instr(5 downto 0); --Op code in top 6 bits, Function code in bottom 6

			-------------------------------------------------------------------------
			with s_whenCondition select s_o_Jump(1) <= 
				'1' when 12b"000000001000", --jr
				'0' when others;

			with s_whenCondition(11 downto 6) select s_o_Jump(0) <=
				'1' when 6b"000011", --jal
				'1' when 6b"000010", --TG: TODO: Testing Jump
				'0' when others;

			o_Jump <= s_o_Jump(1) or s_o_Jump(0);

			--RG: The below block is defunct due do VHDL restrictions regarding "Don't care" bit regions within "when" statements
			/*with s_whenCondition select o_ALUOp <= 
				5b"00001" when 12b"000000100000", -- add
				5b"00010" when 12b"000000100010", -- sub
				5b"00011" when 12b"000000100001", -- addu
				5b"00100" when 12b"000000100100", -- and
				5b"00101" when 12b"000000100111", -- nor
				5b"00110" when 12b"000000100110", -- xor
				5b"00111" when 12b"000000100101", -- or
				5b"01000" when 12b"000000100011", -- subu
				5b"01001" when 12b"000000000000", -- sll
				5b"01010" when 12b"000000000010", -- srl
				5b"01011" when 12b"000000000011", -- sra
				5b"01100" when 12b"000000101010", -- slt
				--I types
				5b"00001" when 12b"001000XXXXXX", -- addi
				5b"00011" when 12b"001001XXXXXX", -- addiu
				5b"00100" when 12b"001100XXXXXX", -- andi
				5b"00110" when 12b"001110XXXXXX", -- xori
				5b"00111" when 12b"001101XXXXXX", -- ori
				5b"01100" when 12b"001010XXXXXX", -- slti
				5b"01101" when 12b"001111XXXXXX", -- lui
				5b"00001" when 12b"101011XXXXXX", -- sw
				5b"00001" when 12b"100011XXXXXX", -- lw
			*/
			--RG: TODO: This new "select-when" block MIGHT not work
			
			s_o_ALUOp_temp <= s_whenCondition(11 downto 6);

				--R types
			with s_whenCondition select s_o_ALUOp(9 downto 5) <= 
				5b"00001" when 12b"000000100000", -- add
				5b"00010" when 12b"000000100010", -- sub
				5b"00011" when 12b"000000100001", -- addu
				5b"00100" when 12b"000000100100", -- and
				5b"00101" when 12b"000000100111", -- nor
				5b"00110" when 12b"000000100110", -- xor
				5b"00111" when 12b"000000100101", -- or
				5b"01000" when 12b"000000100011", -- subu
				5b"01001" when 12b"000000000000", -- sll
				5b"01010" when 12b"000000000010", -- srl
				5b"01011" when 12b"000000000011", -- sra
				5b"01100" when 12b"000000101010", -- slt

				5x"0" when others;

			with s_whenCondition select o_Jr <=
				'1' when 12b"000000001000",
				'0' when others;

				--I types
			with s_o_ALUOp_temp select s_o_ALUOp(4 downto 0) <=
				5b"00001" when 6b"001000", -- addi
				5b"00011" when 6b"001001", -- addiu
				5b"00100" when 6b"001100", -- andi
				5b"00110" when 6b"001110", -- xori
				5b"00111" when 6b"001101", -- ori
				5b"01100" when 6b"001010", -- slti
				5b"01101" when 6b"001111", -- lui
				5b"00001" when 6b"101011", -- sw
				5b"00001" when 6b"100011", -- lw
				5b"01111" when 6b"000101", -- bne
				5b"01110" when 6b"000100", -- beq
				5b"10101" when 6b"000011", -- jal (To include base address)

				5x"0" when others;

			o_ALUOp <= s_o_ALUOp(9 downto 5) or s_o_ALUOp(4 downto 0); --RG: Sets o_ALUOp. This works since only one of the with-select blocks will output something above zero. If both did, then that would be quite another issue entirely


			with s_whenCondition(11 downto 6) select o_ALUSrc <= -- Will always take the register input, so '0'	
				'0' when 6b"000000", --R-type
				'0' when 6b"000100", --beq
				'0' when 6b"000101", --bne
				'1' when others;

			with s_whenCondition(11 downto 6) select o_RegDst <= 
				2b"01" when 6b"000000",
				2b"10" when 6b"000011", -- jal
				2b"00" when others;
			-------------------------------------------------------------------------

			-------------------------------------------------------------------------
			with s_whenCondition(11 downto 6) select o_Branch <= 
				'1' when 6b"000100", -- beq
				'1' when 6b"000101", -- bne
				'1' when 6b"010110", -- bgez
				'1' when 6b"000111", -- bgtz
				'1' when 6b"000110", -- blez
				'0' when others;

			with s_whenCondition(11 downto 6) select o_MemtoReg <= 
				2b"10" when 6b"000011", -- jal
				2b"01" when 6b"100011", -- lw
				2b"00" when others;

			with s_whenCondition(11 downto 6) select o_MemWrite <= 
				'1' when 6b"101011", -- sw
				'0' when others;
			
			--RG: Rework of o_RegWrite below
			with s_whenCondition select s_o_RegWrite(1) <= 
				'0' when 12b"000000001000", -- jr
				'1' when others;

			with s_whenCondition(11 downto 6) select s_o_RegWrite(0) <= 
				'0' when 6b"000100", -- beq
				'0' when 6b"000101", -- bne
				'0' when 6b"010110", -- bgez
				'0' when 6b"000111", -- bgtz
				'0' when 6b"000110", -- blez
				'0' when 6b"101011", -- sw
				'0' when 6b"000010", -- j

				'1' when others;

				s_o_RegWrite_tmp <= not(s_o_RegWrite(1)) or not(s_o_RegWrite(0));
				o_RegWrite <= not(s_o_RegWrite_tmp);



				with s_whenCondition(11 downto 6) select o_Halt <= -- RG: Stops CPU with Opcode: 01 0100
				'1' when 6b"010100",
				'0' when others;

				--J types
			with s_whenCondition(11 downto 6) select o_Jal <=
				'1' when 6b"000011",
				'0' when others;
			-------------------------------------------------------------------------
end behavioral;

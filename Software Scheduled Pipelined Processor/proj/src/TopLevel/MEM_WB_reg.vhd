-------------------------------------------------------------------------
-- Lex Somers & Remington Greatline
-------------------------------------------------------------------------


-- EX_MEM_reg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of IF/ID stage
-- of the pipelined processor
--
--
-- NOTES:
-- 4/24/23 by LS & RG::Design created.
-------------------------------------------------------------------------
-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity MEM_WB_reg is
	port(
		i_CLK			: in std_logic;
		i_RST			: in std_logic; -- (1 sets reg to 0)

		i_PC_4			: in std_logic_vector(31 downto 0);
		i_finalJumpAddr	: in std_logic_vector(31 downto 0);
		i_branchAddr	: in std_logic_vector(31 downto 0);
		i_memReadData 	: in std_logic_vector(31 downto 0);
		i_aluOut	 	: in std_logic_vector(31 downto 0);

		i_writeReg		: in std_logic_vector(4 downto 0);

		-- one bit inputs
		i_branchCheck	: in std_logic;
		i_overflow		: in std_logic;
		i_jal			: in std_logic;
		i_MemtoReg		: in std_logic;
		i_WrEReg			: in std_logic;
		i_j				: in std_logic;
		i_halt			: in std_logic;

		o_PC_4			: out std_logic_vector(31 downto 0);
		o_finalJumpAddr	: out std_logic_vector(31 downto 0);
		o_branchAddr	: out std_logic_vector(31 downto 0);
		o_memReadData	: out std_logic_vector(31 downto 0);
		o_aluOut		: out std_logic_vector(31 downto 0);

		o_writeReg		: out std_logic_vector(4 downto 0);

		-- one bit outputs
		o_branchCheck	: out std_logic;
		o_overflow		: out std_logic;
		o_jal			: out std_logic;
		o_MemtoReg		: out std_logic;
		o_weReg			: out std_logic;
		o_j				: out std_logic;
		o_halt			: out std_logic
	);
end MEM_WB_reg;

-- architecture
architecture structural of MEM_WB_reg is

	component dffg is
		port(
			i_CLK        : in std_logic; -- Clock input
			i_RST        : in std_logic; -- Reset input
			i_WE        : in std_logic; -- Write enable input
			i_D          : in std_logic; -- Data value input
			o_Q          : out std_logic -- Data value output
		);
	end component;

	component dffg_N is
		generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
		port(
			i_CLK        : in std_logic; -- Clock input
			i_RST        : in std_logic; -- Reset input
			i_WrE         : in std_logic; -- Write enable input
			i_D          : in std_logic_vector(N-1 downto 0); -- Data value input
			o_Q          : out std_logic_vector(N-1 downto 0) -- Data value output
		);
	end component;

begin

	x1_1: dffg_N
		generic map(N => 32)
		port map(
			i_CLK 	=> i_CLK,
			i_RST 	=> i_RST,
			i_WrE	=> '1',
			i_D		=> i_PC_4,
			o_Q		=> o_PC_4
		);

	x1_2: dffg_N
		generic map(N => 32)
		port map(
			i_CLK 	=> i_CLK,
			i_RST 	=> i_RST,
			i_WrE	=> '1',
			i_D		=> i_finalJumpAddr,
			o_Q		=> o_finalJumpAddr
		);

	x1_3: dffg_N
		generic map(N => 32)
		port map(
			i_CLK 	=> i_CLK,
			i_RST 	=> i_RST,
			i_WrE	=> '1',
			i_D		=> i_memReadData,
			o_Q		=> o_memReadData
		);

	x1_4: dffg_N
		generic map(N => 32)
		port map(
			i_CLK 	=> i_CLK,
			i_RST 	=> i_RST,
			i_WrE	=> '1',
			i_D		=> i_branchAddr,
			o_Q		=> o_branchAddr
		);

	x1_5: dffg_N
		generic map(N => 32)
		port map(
			i_CLK 	=> i_CLK,
			i_RST 	=> i_RST,
			i_WrE	=> '1',
			i_D		=> i_aluOut,
			o_Q		=> o_aluOut
		);

	x2_1: dffg_N
		generic map(N => 5)
		port map(
			i_CLK 	=> i_CLK,
			i_RST 	=> i_RST,
			i_WrE	=> '1',
			i_D		=> i_writeReg,
			o_Q		=> o_writeReg
		);

	x3_1: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_branchCheck,
		o_Q		=> o_branchCheck
	);

	x3_2: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_overflow,
		o_Q		=> o_overflow
	);

	x3_3: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_jal,
		o_Q		=> o_jal
	);

	x3_4: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_MemtoReg,
		o_Q		=> o_MemtoReg
	);


	x3_5: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_WrEReg,
		o_Q		=> o_weReg
	);


	x3_6: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_j,
		o_Q		=> o_j
	);

	x3_7: dffg port map(
		i_CLK 	=> i_CLK,
		i_RST 	=> i_RST,
		i_WE	=> '1',
		i_D		=> i_halt,
		o_Q		=> o_halt
	);

end structural;
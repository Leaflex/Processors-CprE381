-------------------------------------------------------------------------
-- John Brose, Andrew Deick, Rolf Anderson
-------------------------------------------------------------------------


-- IF_ID_reg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of IF/ID stage
-- of the pipelined processor
--
--
-- NOTES:
-- 04/19/21 by JB::Design created.
-------------------------------------------------------------------------
-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity ID_EX_reg is
	port(i_CLK		: in std_logic;
	     i_RST		: in std_logic; -- (1 sets reg to 0)

	     i_PC_4		: in std_logic_vector(31 downto 0);
	     i_readData1 	: in std_logic_vector(31 downto 0);
	     i_readData2 	: in std_logic_vector(31 downto 0);
	     i_signExtImmed 	: in std_logic_vector(31 downto 0);
	     i_jumpAddress 	: in std_logic_vector(31 downto 0);
		 i_regDst			: in std_logic_vector(4 downto 0);
	     i_control_bits 	: in std_logic_vector(15 downto 0);

	     o_PC_4		: out std_logic_vector(31 downto 0);
	     o_readData1 	: out std_logic_vector(31 downto 0);
	     o_readData2 	: out std_logic_vector(31 downto 0);
	     o_signExtImmed 	: out std_logic_vector(31 downto 0);
	     o_jumpAddress 	: out std_logic_vector(31 downto 0);
		 o_regDst			: out std_logic_vector(4 downto 0);
		 o_control_bits 	: out std_logic_vector(15 downto 0));
end ID_EX_reg;

-- architecture
architecture structural of ID_EX_reg is

  component dffg_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WrE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

begin

  x1: dffg_N
	generic map(N => 32)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_PC_4,
		 o_Q	=> o_PC_4);

  x2: dffg_N
	generic map(N => 32)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_readData1,
		 o_Q	=> o_readData1);

  x3: dffg_N
	generic map(N => 32)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_readData2,
		 o_Q	=> o_readData2);

  x4: dffg_N
	generic map(N => 32)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_signExtImmed,
		 o_Q	=> o_signExtImmed);

  x4_5: dffg_N
	generic map(N => 32)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_jumpAddress,
		 o_Q	=> o_jumpAddress);

  x6: dffg_N
	generic map(N => 5)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_regDst,
		 o_Q	=> o_regDst);

		
  x7: dffg_N
	generic map(N => 16)
	port map(i_CLK 	=> i_CLK,
		 i_RST 	=> i_RST,
		 i_WrE	=> '1',
		 i_D	=> i_control_bits,
		 o_Q	=> o_control_bits);

end structural;
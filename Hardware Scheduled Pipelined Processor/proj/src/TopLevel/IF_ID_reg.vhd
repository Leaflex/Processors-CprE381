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
entity IF_ID_reg is
	port(i_CLK		: in std_logic;
	     i_RST		: in std_logic; -- (1 sets reg to 0)
	     i_PC_4		: in std_logic_vector(31 downto 0);
	     i_instruction  	: in std_logic_vector(31 downto 0);
	     o_PC_4	  	: out std_logic_vector(31 downto 0);
	     o_instruction	: out std_logic_vector(31 downto 0));
end IF_ID_reg;

-- architecture
architecture structural of IF_ID_reg is

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
		 i_D	=> i_instruction,
		 o_Q	=> o_instruction);
		
end structural;
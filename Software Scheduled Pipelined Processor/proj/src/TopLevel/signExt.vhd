-------------------------------------------------------------------------
-- Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------

-- DESCRIPTION: 16 to 32 bit signed/unsigned extender
-- signExt.vhd
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity signExt is
	port(
		i_A	: in std_logic_vector(15 downto 0); --16 bit input; value that is to be extended
		i_S	: in std_logic; --0 is zero extend, 1 is to sign extend
		o_F : out std_logic_vector(31 downto 0) --32 bit extended value of i_D
	);
end signExt;

architecture dataflow of signExt is

	signal ext_bit	: std_logic;

begin

	with i_S select
	ext_bit <= '0' when '0', -- Extension bit will be 0 when i_S is 0,
			i_A(15) when others; -- Otherwise, it will match the MSB of the input

	G1: for i in 0 to 15 generate
		o_F(i) <= i_A(i);
	end generate;

	G2: for i in 16 to 31 generate
		o_F(i) <= ext_bit;
	end generate;

end dataflow;
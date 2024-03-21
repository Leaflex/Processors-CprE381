-------------------------------------------------------------------------
-- Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ShiftLeft2.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a N-bit shifter 
-- that shifts an input by 2.
--  
--Notes            
-- 3/29/2023 by Lex Somers::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ShiftLeft2 is
	generic(N : integer := 32);
	port(i_A : in std_logic_vector(N-1 downto 0);
	     o_F : out std_logic_vector(N-1 downto 0));
end ShiftLeft2;

architecture ShiftLeft2 of ShiftLeft2 is
begin
	
	o_F <= std_logic_vector(unsigned(i_A) sll 2);
	
end ShiftLeft2;
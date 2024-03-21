-------------------------------------------------------------------------
-- Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- shifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 32-bit shifter 
--using dataflow.
--  
--Notes            
-- 3/28/2023 by Lex Somers::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
	port(
		i_Input		: in std_logic_vector(31 downto 0);
		i_ShiftAmt	: in std_logic_vector (4 downto 0);
		i_ShiftType : in std_logic;						-- 0 == logical and 1 == arithmetic shift
		i_LeftRight	: in std_logic;						-- 0 == left shift and 1 == right shift
		o_Output	: out std_logic_vector(31 downto 0)
	);
end entity;

architecture dataflow of shifter is 
-- Goes with nonfunctional code block below
--	signal control: std_logic_vector(1 downto 0); -- controls which type of shift to use. Bit 0 is shiftType, bit 1 is shift left (on 0) or shift right (on 1)

begin
-- Attempt at making a shifter without a process statement. Code does not work, throws errors about infix exrpession.
--	control <= i_LeftRight & i_ShiftType;
--
--	with control(1 downto 0) select 
--		--o_Output(31 downto 0) <= shift_right(signed(i_Input), to_integer(unsigned(i_ShiftAmt))) when "11", -- sra
--		o_Output <= std_logic_vector(shift_right(unsigned(i_Input), to_integer(unsigned(i_ShiftAmt)))) when "10", -- srl
--		o_Output <= std_logic_vector(shift_left(unsigned(i_Input), to_integer(unsigned(i_ShiftAmt)))) when "00", -- sll
--		--o_Output(31 downto 0) <= shift_left(signed(i_Input), to_integer(unsigned(i_ShiftAmt))) when "01", -- sla
--			i_Input when others;


	shifter: process(i_Input, i_ShiftAmt, i_ShiftType, i_LeftRight)
begin
		if i_ShiftType = '1' then	--arithmetic shift
			if i_LeftRight = '1' then	-- right arithmetic shift(sra)
				o_Output <= std_logic_vector(shift_right(signed(i_Input), to_integer(unsigned(i_ShiftAmt))));
			else
				o_Output <= std_logic_vector(shift_left(unsigned(i_Input), to_integer(unsigned(i_ShiftAmt))));
			end if;
		else	-- logical shift
			if i_LeftRight = '1' then	-- shift right logilcal(srl)
				o_Output <= std_logic_vector(shift_right(unsigned(i_Input), to_integer(unsigned(i_ShiftAmt))));
			else	-- shift left logical (sll)
				o_Output <= std_logic_vector(shift_left(unsigned(i_Input), to_integer(unsigned(i_ShiftAmt))));
			end if;
		end if;

	end process shifter;

end dataflow;


		
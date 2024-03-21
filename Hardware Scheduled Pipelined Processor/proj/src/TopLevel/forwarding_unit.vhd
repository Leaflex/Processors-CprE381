-------------------------------------------------------------------------
-- Andrew Deick
-------------------------------------------------------------------------


-- control_unit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of the control unit
-- for the MIPS single cycle processor
--
--
-- NOTES:
-- 03/08/21 by JB::Design created.
-------------------------------------------------------------------------
-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;
-- entity
entity forwarding_unit is
	port(i_readAddr1  	  	: in std_logic_vector(4 downto 0);
	     i_readAddr2	  	: in std_logic_vector(4 downto 0);
	     i_writeAddr	  	: in std_logic_vector(4 downto 0);
         i_writeEnable      : in std_logic;
         o_fwdSwitch1		: out std_logic; --1 if forwarding should be used, 0 otherwise
         o_fwdSwitch2		: out std_logic);
end forwarding_unit;

-- architecture
architecture mixed of forwarding_unit is
begin
    process(i_readAddr1, i_readAddr2, i_writeAddr)
    begin
        if (i_readAddr1 = i_writeAddr AND i_writeEnable = '1' AND i_writeAddr /= "00000") then
            o_fwdSwitch1 <= '1';
        else
            o_fwdSwitch1 <= '0';
        end if;
        if (i_readAddr2 = i_writeAddr AND i_writeEnable = '1' AND i_writeAddr /= "00000") then
            o_fwdSwitch2 <= '1';
        else
            o_fwdSwitch2 <= '0';
        end if;
    end process;
end mixed;
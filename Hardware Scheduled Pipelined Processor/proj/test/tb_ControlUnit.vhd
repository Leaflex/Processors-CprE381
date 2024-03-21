library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_ControlUnit is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_ControlUnit;

architecture mixed of tb_ControlUnit is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N : integer := 32;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component ControlUnit is
	port(
    i_opcode    : in std_logic_vector(5 downto 0);
    i_funct     : in std_logic_vector(5 downto 0);
    o_Ctrl_Unt  : out std_logic_vector(15 downto 0)
);
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_i_opcode   : std_logic_vector(5 downto 0) := 6X"0";
signal s_i_funct    : std_logic_vector(5 downto 0) := 6x"0";
signal s_o_Ctrl_Unt   : std_logic_vector(15 downto 0) := 16x"0";

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: ControlUnit
  port map(
        --iCLK => CLK,
        i_opcode => s_i_opcode,
        i_funct => s_i_funct,
        o_Ctrl_Unt => s_o_Ctrl_Unt
        );
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  
  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  -- This process resets the sequential components of the design.
  -- It is held to be 1 across both the negative and positive edges of the clock
  -- so it works regardless of whether the design uses synchronous (pos or neg edge)
  -- or asynchronous resets.
  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  
  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    --R-Types
    -- Test case 1: add
    s_i_opcode <= "000000";
    s_i_funct <= "100000";
    wait for gCLK_HPER;
    -- Test case 2: addu
    s_i_opcode <= "000000";
    s_i_funct <= "100001";
    wait for gCLK_HPER;
    -- Test case 3: and
    s_i_opcode <= "000000";
    s_i_funct <= "100100";
    wait for gCLK_HPER;
    -- Test case 4: nor
    s_i_opcode <= "000000";
    s_i_funct <= "100111";
    wait for gCLK_HPER;
    -- Test case 5: xor
    s_i_opcode <= "000000";
    s_i_funct <= "100110";
    wait for gCLK_HPER;
    -- Test case 6: or
    s_i_opcode <= "000000";
    s_i_funct <= "100101";
    wait for gCLK_HPER;
    -- Test case 7: slt
    s_i_opcode <= "000000";
    s_i_funct <= "101010";
    wait for gCLK_HPER;
    -- Test case 8: sll
    s_i_opcode <= "000000";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 9: srl
    s_i_opcode <= "000000";
    s_i_funct <= "000010";
    wait for gCLK_HPER;
    -- Test case 10: sra
    s_i_opcode <= "000000";
    s_i_funct <= "000011";
    wait for gCLK_HPER;
    -- Test case 11: sub
    s_i_opcode <= "000000";
    s_i_funct <= "100010";
    wait for gCLK_HPER;
    -- Test case 12: subu
    s_i_opcode <= "000000";
    s_i_funct <= "100011";
    wait for gCLK_HPER;
    -- Test case 13: jr
    s_i_opcode <= "000000";
    s_i_funct <= "001000";
    wait for gCLK_HPER;

    --I-Type
    -- Test case 14: addi
    s_i_opcode <= "001000";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 15: addiu
    s_i_opcode <= "001001";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 16: andi
    s_i_opcode <= "001100";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 17: xori
    s_i_opcode <= "001110";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 18: ori
    s_i_opcode <= "001101";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 19: slti
    s_i_opcode <= "001010";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 20: lui
    s_i_opcode <= "001111";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 21: beq
    s_i_opcode <= "000100";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 22: bne
    s_i_opcode <= "000101";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 23: bgez
    s_i_opcode <= "010110";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 24: bgtz
    s_i_opcode <= "000111";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 25: blez
    s_i_opcode <= "000110";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 26: bgezal
    s_i_opcode <= "000001";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 27: bltzal
    s_i_opcode <= "010101";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 28: lw
    s_i_opcode <= "100011";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 29: sw
    s_i_opcode <= "101011";
    s_i_funct <= "000000";
    wait for gCLK_HPER;

    --J-Types
    -- Test case 30: j
    s_i_opcode <= "000010";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 31: jal
    s_i_opcode <= "000011";
    s_i_funct <= "000000";
    wait for gCLK_HPER;
    -- Test case 32: halt
    s_i_opcode <= "010100";
    s_i_funct <= "000000";
    wait for gCLK_HPER;

    wait;
  end process;

end mixed;

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

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component ControlUnit is
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
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_i_Instr   : std_logic_vector(31 downto 0) := 32X"0";
signal s_o_RegDst   : std_logic_vector(1 downto 0) := b"00";
signal s_o_Jump     : std_logic := '0';
signal s_o_Branch     : std_logic := '0';
signal s_o_MemtoReg     : std_logic_vector(1 downto 0) := b"00";
signal s_o_ALUOp        : std_logic_vector(4 downto 0) := b"00000";
signal s_o_MemWrite     : std_logic := '0';
signal s_o_ALUSrc     : std_logic := '0';
signal s_o_RegWrite     : std_logic := '0';
signal s_o_Jal     : std_logic := '0';
signal s_o_Jr     : std_logic := '0';
signal s_o_Halt     : std_logic := '0';

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: ControlUnit
  port map(
        --iCLK => CLK,
        i_Instr => s_i_Instr,
        o_RegDst => s_o_RegDst,
        o_Jump => s_o_Jump,
        o_Branch => s_o_Branch,
        o_MemtoReg => s_o_MemtoReg,
        o_ALUOp => s_o_ALUOp,
        o_MemWrite => s_o_MemWrite,
        o_ALUSrc => s_o_ALUSrc,
        o_RegWrite => s_o_RegWrite,
        o_Jal => s_o_Jal,
        o_Jr => s_o_Jr,
        o_Halt => s_o_Halt
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
    -- Test case 1:
    s_i_Instr <= "00000000000000000000000000100000"; --add
    wait for gCLK_HPER;
    -- Test case 2:
    s_i_Instr <= "00000000000000000000000000100001"; --addu
    wait for gCLK_HPER;
    -- Test case 3:
    s_i_Instr <= "00000000000000000000000000100100"; --and
    wait for gCLK_HPER;
    -- Test case 4:
    s_i_Instr <= "00000000000000000000000000100111"; --nor
    wait for gCLK_HPER;
    -- Test case 5:
    s_i_Instr <= "00000000000000000000000000100110"; --xor
    wait for gCLK_HPER;
    -- Test case 6:
    s_i_Instr <= "00000000000000000000000000100101"; --or
    wait for gCLK_HPER;
    -- Test case 7:
    s_i_Instr <= "00000000000000000000000000101010"; --slt
    wait for gCLK_HPER;
    -- Test case 8:
    s_i_Instr <= "00000000000000000000000000000000"; --sll
    wait for gCLK_HPER;
    -- Test case 9:
    s_i_Instr <= "00000000000000000000000000000010"; --srl
    wait for gCLK_HPER;
    -- Test case 10:
    s_i_Instr <= "00000000000000000000000000000011"; --sra
    wait for gCLK_HPER;
    -- Test case 11:
    s_i_Instr <= "00000000000000000000000000100010"; --sub
    wait for gCLK_HPER;
    -- Test case 12:
    s_i_Instr <= "00000000000000000000000000100011"; --subu
    wait for gCLK_HPER;
    -- Test case 13:
    s_i_Instr <= "00000000000000000000000000001000"; --jr
    wait for gCLK_HPER;

    --I-Type
    -- Test case 14:
    s_i_Instr <= "00100000000000000000000000000000"; --addi
    wait for gCLK_HPER;
    -- Test case 15:
    s_i_Instr <= "00100100000000000000000000000000"; --addiu
    wait for gCLK_HPER;
    -- Test case 16:
    s_i_Instr <= "00110000000000000000000000000000"; --andi
    wait for gCLK_HPER;
    -- Test case 17:
    s_i_Instr <= "00111000000000000000000000000000"; --xori
    wait for gCLK_HPER;
    -- Test case 18:
    s_i_Instr <= "00110100000000000000000000000000"; --ori
    wait for gCLK_HPER;
    -- Test case 19:
    s_i_Instr <= "00101000000000000000000000000000"; --slti
    wait for gCLK_HPER;
    -- Test case 20:
    s_i_Instr <= "00111100000000000000000000000000"; --lui
    wait for gCLK_HPER;
    -- Test case 21:
    s_i_Instr <= "00010000000000000000000000000000"; --beq
    wait for gCLK_HPER;
    -- Test case 22:
    s_i_Instr <= "00010100000000000000000000000000"; --bne
    wait for gCLK_HPER;
    -- Test case 23:
    s_i_Instr <= "01011000000000000000000000000000"; --bgez
    wait for gCLK_HPER;
    -- Test case 24:
    s_i_Instr <= "00011100000000000000000000000000"; --bgtz
    wait for gCLK_HPER;
    -- Test case 25:
    s_i_Instr <= "00011000000000000000000000000000"; --blez
    wait for gCLK_HPER;
    -- Test case 26:
    s_i_Instr <= "00000100000000000000000000000000"; --bgezal
    wait for gCLK_HPER;
    -- Test case 27:
    s_i_Instr <= "01010100000000000000000000000000"; --bltzal
    wait for gCLK_HPER;
    -- Test case 28:
    s_i_Instr <= "10001100000000000000000000000000"; --lw
    wait for gCLK_HPER;
    -- Test case 29:
    s_i_Instr <= "10101100000000000000000000000000"; --sw
    wait for gCLK_HPER;

    --J-Types
    -- Test case 30:
    s_i_Instr <= "00001000000000000000000000000000"; --j
    wait for gCLK_HPER;
    -- Test case 31:
    s_i_Instr <= "00001100000000000000000000000000"; --jal
    wait for gCLK_HPER;
    -- Test case 32:
    s_i_Instr <= "01010000000000000000000000000000"; --halt
    wait for gCLK_HPER;

    --stop; --RG: Used to simplify simulation workflow by not letting the TB loop infinitely  when one hits the "run all" button in Questasim
    wait;
  end process;

end mixed;

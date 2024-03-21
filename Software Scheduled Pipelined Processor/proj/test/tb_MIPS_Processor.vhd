library IEEE;
use IEEE.std_logic_1164.all;

entity tb_MIPS_processor is
    generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
  end  tb_MIPS_processor;

  architecture structure of tb_MIPS_processor is

    constant cCLK_PER  : time := gCLK_HPER * 2;

    component IF_ID_reg is 
		port(
			i_CLK			: in std_logic;
			i_RST			: in std_logic; -- (1 sets reg to 0)
			i_PC_4			: in std_logic_vector(31 downto 0);
			i_instruction  	: in std_logic_vector(31 downto 0);
			o_PC_4	  		: out std_logic_vector(31 downto 0);
			o_instruction	: out std_logic_vector(31 downto 0)
		);
	end component;

	component ID_EX_reg is 
		port(
			i_CLK			: in std_logic;
			i_RST			: in std_logic; -- (1 sets reg to 0)

			i_PC_4			: in std_logic_vector(31 downto 0);
			i_readData1 	: in std_logic_vector(31 downto 0);
			i_readData2 	: in std_logic_vector(31 downto 0);
			i_signExtImmed 	: in std_logic_vector(31 downto 0);
			i_jumpAddress 	: in std_logic_vector(31 downto 0);
			i_instr_20_16 	: in std_logic_vector(4 downto 0);
			i_instr_15_11 	: in std_logic_vector(4 downto 0);
			i_control_bits 	: in std_logic_vector(15 downto 0);

			o_PC_4			: out std_logic_vector(31 downto 0);
			o_readData1 	: out std_logic_vector(31 downto 0);
			o_readData2 	: out std_logic_vector(31 downto 0);
			o_signExtImmed 	: out std_logic_vector(31 downto 0);
			o_jumpAddress 	: out std_logic_vector(31 downto 0);
			o_instr_20_16 	: out std_logic_vector(4 downto 0);
			o_instr_15_11 	: out std_logic_vector(4 downto 0);
			o_control_bits 	: out std_logic_vector(15 downto 0)
		);
	end component;

	component EX_MEM_reg is 
		port(
			i_CLK			: in std_logic;
			i_RST			: in std_logic; -- (1 sets reg to 0)

			i_PC_4			: in std_logic_vector(31 downto 0);
			i_finalJumpAddr	: in std_logic_vector(31 downto 0);
			i_branchAddr	: in std_logic_vector(31 downto 0);
			i_readData2 	: in std_logic_vector(31 downto 0);
			i_aluOut	 	: in std_logic_vector(31 downto 0);

			i_writeReg 		: in std_logic_vector(4 downto 0);

		-- one bit inputs
			i_zero			: in std_logic;
			i_overflow		: in std_logic;
			i_jal			: in std_logic;
			i_MemtoReg		: in std_logic;
			i_weMem			: in std_logic;
			i_weReg			: in std_logic;
			i_branch		: in std_logic;
			i_j				: in std_logic;
			i_halt			: in std_logic;

			o_PC_4			: out std_logic_vector(31 downto 0);
			o_finalJumpAddr	: out std_logic_vector(31 downto 0);
			o_branchAddr	: out std_logic_vector(31 downto 0);
			o_readData2 	: out std_logic_vector(31 downto 0);
			o_aluOut	 	: out std_logic_vector(31 downto 0);

			o_writeReg 		: out std_logic_vector(4 downto 0);

		-- one bit outputs
			o_zero		 	: out std_logic;
			o_overflow		: out std_logic;
			o_jal			: out std_logic;
			o_MemtoReg		: out std_logic;
			o_weMem			: out std_logic;
			o_weReg			: out std_logic;
			o_branch		: out std_logic;
			o_j		    	: out std_logic;
			o_halt		  	: out std_logic
		);
	end component;

	component MEM_WB_reg is 
		port(
			i_CLK			: in std_logic;
			i_RST			: in std_logic; -- (1 sets reg to 0)

			i_PC_4			: in std_logic_vector(31 downto 0);
			i_finalJumpAddr	: in std_logic_vector(31 downto 0);
			i_branchAddr	: in std_logic_vector(31 downto 0);
			i_memReadData 	: in std_logic_vector(31 downto 0);
			i_aluOut	 	: in std_logic_vector(31 downto 0);

			i_writeReg 		: in std_logic_vector(4 downto 0);

		-- one bit inputs
			i_branchCheck	: in std_logic;
			i_overflow		: in std_logic;
			i_jal			: in std_logic;
			i_MemtoReg		: in std_logic;
			i_WrEReg		: in std_logic;
			i_j				: in std_logic;
			i_halt			: in std_logic;

			o_PC_4			: out std_logic_vector(31 downto 0);
			o_finalJumpAddr	: out std_logic_vector(31 downto 0);
			o_branchAddr	: out std_logic_vector(31 downto 0);
			o_memReadData 	: out std_logic_vector(31 downto 0);
			o_aluOut	 	: out std_logic_vector(31 downto 0);

			o_writeReg 		: out std_logic_vector(4 downto 0);

		-- one bit outputs
			o_branchCheck	: out std_logic;
			o_overflow		: out std_logic;
			o_jal			: out std_logic;
			o_MemtoReg		: out std_logic;
			o_weReg			: out std_logic;
			o_j				: out std_logic;
			o_halt			: out std_logic
		);
	end component;

    -- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';
    signal s_Inst : std_logic_vector(31 downto 0) := 32b"0";
    signal s_Inst_ID : std_logic_vector(31 downto 0) := 32b"0";
    signal s_Inst_EX : std_logic_vector(31 downto 0) := 32b"0";
    signal s_Inst_MEM : std_logic_vector(31 downto 0) := 32b"0";
    signal s_Inst_Wb : std_logic_vector(31 downto 0) := 32b"0";

begin

    DUT0: IF_ID_reg
    port map(
        i_CLK => CLK,
        i_RST => '0',
		i_PC_4 => 32b"0",
		i_instruction => s_Inst,
        o_instruction => s_Inst_ID
    );

    DUT1: ID_EX_reg
    port map(
        i_CLK => CLK,
		i_RST => '0',

		i_PC_4 => 32b"0",
		i_readData1 => 32b"0",
		i_readData2 => 32b"0",
		i_signExtImmed => 32b"0",
		i_jumpAddress => 32b"0",
		i_instr_20_16 => s_Inst_ID(4 downto 0),
		i_instr_15_11 => 5b"0",
		i_control_bits => 16b"0",

        o_instr_20_16 => s_Inst_EX(4 downto 0)
    );

    DUT2: EX_MEM_reg
    port map(
        i_CLK => CLK,
		i_RST => '0',

		i_PC_4 => s_Inst_EX,
		i_finalJumpAddr => 32b"0",
		i_branchAddr => 32b"0",
		i_readData2 => 32b"0",
		i_aluOut => 32b"0",

		i_writeReg => 5b"0",

        i_zero => '0',
		i_overflow => '0',
		i_jal => '0',
		i_MemtoReg	=> '0',
		i_weMem	 => '0',
		i_weReg	 => '0',
		i_branch => '0',
		i_j => '0',
		i_halt => '0',

        o_PC_4 => s_Inst_MEM

    );

    DUT3: MEM_WB_reg
    port map(
        i_CLK => CLK,
		i_RST => '0',

		i_PC_4 => s_Inst_MEM,
		i_finalJumpAddr => 32b"0",
		i_branchAddr => 32b"0",
		i_memReadData => 32b"0",
		i_aluOut => 32b"0",

		i_writeReg => 5b"0",

        i_branchCheck	 => '0',
		i_overflow		 => '0',
		i_jal			 => '0',
		i_MemtoReg		 => '0',
		i_WrEReg		 => '0',
		i_j				 => '0',
		i_halt			 => '0',

        o_PC_4           => s_Inst_WB

    );

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

    P_TEST_CASES: process
    begin
      wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges
  
      --R-Types
      -- Test case 1:
      s_Inst <= 32b"1";
      wait for gCLK_HPER;
  
      --stop; --RG: Used to simplify simulation workflow by not letting the TB loop infinitely  when one hits the "run all" button in Questasim
      wait;
    end process;

  end structure;

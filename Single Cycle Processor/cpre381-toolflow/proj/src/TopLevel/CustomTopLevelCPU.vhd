---------------------------------------------------------------------------------------------
-- Remington Greatline & Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
---------------------------------------------------------------------------------------------
-- CustomTopLevelCPU.vhd
---------------------------------------------------------------------------------------------
-- DESCRIPTION: A top level file implementing a Single Cycle MIPS Processor
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; --Is this for the arrays?

entity CustomTopLevelCPU is
	generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
	port(
		i_CLK: in std_logic;
		i_Inst: in std_logic_vector(31 downto 0);
		i_RST: in std_logic;
		i_PC: in std_logic_vector(31 downto 0);
		o_Overflow: out std_logic
	);

end CustomTopLevelCPU;

architecture structural of CustomTopLevelCPU is

--Insert components below
	component ControlUnit
		port(
			i_Instr 	: in std_logic_vector(31 downto 0);
			o_RegDst	: out std_logic; --Might be useful later but seems to only make sudo code viable
			o_Jump 		: out std_logic;
			o_Branch 	: out std_logic;
			--o_MemRead 	: out std_logic;
			o_MemtoReg 	: out std_logic;
			o_ALUOp 	: out std_logic_vector(3 downto 0); -- Controls what operation the ALU does and what it outputs
			o_MemWrite 	: out std_logic;
			o_ALUSrc 	: out std_logic;
			o_RegWrite 	: out std_logic
		);
	end component;



	component ALU
		port(
			i_Data1 	: in std_logic_vector(31 downto 0);
			i_Data2 	: in std_logic_vector(31 downto 0);
			i_ALUOp 	: in std_logic_vector(3 downto 0); --This is decoded into instructions for the ALU
			i_ShiftAmt  : in std_logic_vector(4 downto 0);
			o_Zero		: out std_logic;
			o_Out 		: out std_logic_vector(31 downto 0);
			o_Overflow 	: out std_logic
			--o_RegDst : out std_logic; --Might be useful later but seems to only make sudo code viable
		);
	end component;



	component reg_file is
		port(
			i_CLK, i_RST	          	: in std_logic; -- CLock and Reset Signal
			i_WrD	               		: in std_logic_vector(31 downto 0); -- Write Data
			i_WrAddr, i_RdS1, i_RdS2	: in std_logic_vector(4 downto 0); -- Write Address, Read Address 1, Read Address 2
			i_WrE	               		: in std_logic; -- Write enable
			o_RdD1, o_RdD2	          	: out std_logic_vector(31 downto 0) --Read Data 1, Read Data 2
		);
	end component;



	component mem
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port (
			i_Clk	: in std_logic;
			i_Addr	: in std_logic_vector((ADDR_WIDTH-1) downto 0);
			i_Data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			i_WrEn	: in std_logic := '1';
			o_Q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);
	end component;



	component signExt is
		port(
			i_A : in std_logic_vector(15 downto 0); --16 bit input; value that is to be extended
			i_S : in std_logic; --0 is zero extend, 1 is to sign extend
			o_F : out std_logic_vector(31 downto 0) --32 bit extended value of i
		);
	end component;



	component mux2t1_N is
		port(
			i_S		: in std_logic;
			i_D0 	: in std_logic_vector(N-1 downto 0);
			i_D1	: in std_logic_vector(N-1 downto 0);
			o_O		: out std_logic_vector(N-1 downto 0)
		);
	end component;

	component mux2t1_5 is
		port(
			i_S		: in std_logic;
			i_D0 	: in std_logic_vector(4 downto 0);
			i_D1	: in std_logic_vector(4 downto 0);
			o_O		: out std_logic_vector(4 downto 0)
		);
	end component;

	--TODO: Add necessary components for "top half" of processor

	component full_adder_n is
		port(
			i_A		: in std_logic_vector(N-1 downto 0);
			i_B		: in std_logic_vector(N-1 downto 0);
			i_Cin	: in std_logic;
			o_Cout	: out std_logic;
			o_Sum	: out std_logic_vector(N-1 downto 0)
		);
	end component;

	component ShiftLeft2 is
		port(
			i_A : in std_logic_vector(N-1 downto 0);
	     	o_F : out std_logic_vector(N-1 downto 0)
		);
	end component;

	-- ControlUnit Signal Outputs
	--signal s_MemRead: std_logic; -- Connects output of ControlUnit (o_MemRead) to MEM_Data
	signal s_RegDst : std_logic; -- Connects output of ControlUnit (o_RegDst) to Mux_ReRegDst (i_S)
	signal s_Jump: std_logic; -- Connects output of ControlUnit (o_Jump) to Mux_Jump (i_S)
	signal s_Branch: std_logic; -- Connects output of ControlUnit (o_Branch) to AND_Branch (i_A)
	signal s_MemtoReg: std_logic; -- Connects output of ControlUnit (o_MemtoReg) to MUX_MemtoReg (i_S)
	signal s_ALUOp: std_logic_vector(3 downto 0); -- Connects output of ControlUnit (o_ALUOp) to ALU (i_ALUOp)
	signal s_MemWrite: std_logic; -- Connects output of ControlUnit (o_MemWrite) to MEM_Data (i_WrEn) [might need to change the hard encoded '1' within the mem file]
	signal s_SelALUSrc : std_logic; -- Connects output of ControlUnit (o_ALUSrc) to MUX_ALUSrc (i_S)
	signal s_RegWrite : std_logic; -- Connects output of ControlUnit (o_RegWrite) to MIPS_Register (i_WrE)

	-- reg_file Signal Outputs
	signal s_RegData1: std_logic_vector(N-1 downto 0); -- Connects output of MIPS_Register (o_RdD1) to ALU1 (i_Data1)
	signal s_RegData2: std_logic_vector(N-1 downto 0); -- Connects output of MIPS_Register (o_RdD2) to MUX_ALUSrc (i_D0) and MEM_Data (i_Data)

	-- ALU Signal Outputs
	signal s_ALUOut: std_logic_vector(N-1 downto 0); -- Connects output of ALU (o_Out) to MEM_Data (i_Addr) and MUX_MemtoReg (i_D0)
	signal s_Overflow: std_logic; -- Connects output of ALU (o_Overflow) to AND_Branch (i_B)

	-- signExt Signal Outputs
	signal s_SignExt: std_logic_vector(N-1 downto 0); -- Connects output of signExt (o_F) to MUX_ALUSrc (i_D1)

	-- MUX_ALUSrc Signal Outputs
	signal s_ALUSrc: std_logic_vector(N-1 downto 0); -- Connects output of MUX_ALUSrc (o_O) to ALU1 (i_Data2)

	-- MUX_RegDst Signal Outputs
	signal s_WrAddr : std_logic_vector(4 downto 0); -- Connects output of MUX_RegDst (o_O) to MIPS_Register (i_WrAddr)

	-- MUX_MemtoReg Signal OUtputs
	signal s_WrData : std_logic_vector(N-1 downto 0); --Connects output of Mux_MemtoReg (o_O) to MIPS_Register (i_WrD)

	-- MEM_Data Signal Outputs
	signal s_MemData: std_logic_vector(N-1 downto 0); -- Connects output of MEM_Data (o_Q) to MUX_MemtoReg (i_D1)

	--DONE: Add required signals for "top half" of processor
	
	signal s_FULLADDER: std_logic_vector(N-1 downto 0);
	signal s_JUMPSHIFT: std_logic_vector(N-1 downto 0);
	signal s_32SignExtend: std_logic_vector(N-1 downto 0);
	signal s_FULLADDER1: std_logic_vector(N-1 downto 0);
	signal s_ALUZero: std_logic;
	signal s_JUMPSHIFT_temp: std_logic_vector(N-1 downto 0);
	signal s_MUX: std_logic_vector(N-1 downto 0);
	signal s_PC: std_logic_vector(N-1 downto 0);

begin

	MUX_RegDst: mux2t1_5 port map(
		i_S => s_RegDst,
		i_D0 => i_Inst(20 downto 16),
		i_D1 => i_Inst(15 downto 11),
		o_O => s_WrAddr
	);

	MIPS_Register: reg_file port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_WrD => s_WrData,
		i_WrAddr => s_WrAddr,
		i_RdS1 => i_Inst(25 downto 21),
		i_RdS2 => i_Inst(20 downto 16),
		i_WrE => s_RegWrite,
		o_RdD1 => s_RegData1,
		o_RdD2 => s_RegData2
	);

	MUX_ALUSrc: mux2t1_N port map(
		i_S => s_SelALUSrc,
		i_D0 => s_RegData2,
		i_D1 => s_SignExt,
		o_O => s_ALUSrc
	);

	ALU1: ALU port map(
		i_Data1 => s_RegData1,
		i_Data2 => s_ALUSrc,
		i_ALUOp => s_ALUOp,
		i_ShiftAmt  => i_Inst(10 downto 6),
		o_Zero => s_ALUZero,
		o_Out => s_ALUOut,
		o_Overflow => o_Overflow
	);

	Sign_Extender: signExt port map(
		i_A => i_Inst(15 downto 0),
		i_S => '1',
		o_F => s_SignExt
	);

	MEM_Data: mem port map(
		i_Clk => i_CLK,
		i_Addr => s_ALUOut,
		i_Data => s_RegData2,
		i_WrEn => s_MemWrite,
		o_Q => s_MemData
	);

	MUX_MemtoReg: mux2t1_N port map(
		i_S => s_MemtoReg,
		i_D0 => s_ALUOut,
		i_D1 => s_MemData,
		o_O => s_WrData
	);

	CONTROL_UNIT: ControlUnit port map( 
        i_Instr		=> i_Inst,
        o_RegDst	=> s_RegDst,
        o_Jump		=> s_Jump, 
        o_Branch	=> s_Branch,
        --o_MemRead    => s_MemRead,
        o_MemtoReg	=> s_MemtoReg,
        o_ALUOp		=> s_ALUOp,
        o_MemWrite	=> s_MemWrite,
        o_ALUSrc    => s_SelALUSrc,
        o_RegWrite 	=> s_RegWrite
	);

	--DONE: Complete the "top half" of the processor

	FULLADDER: full_adder_n port map(
		i_A 	=> i_PC,
		i_B 	=> 32x"4",
		i_Cin 	=> '0',
		o_Sum 	=> s_FULLADDER
	);

	SHIFTLEFT1: ShiftLeft2 port map(
		i_A => "000000" & i_Inst(25 downto 0),
		o_F =>  s_JUMPSHIFT_temp
	);
	--DONE: TA looked over this. Hopefully this will work as intended.
	s_JUMPSHIFT <= s_FULLADDER(31 downto 28) & s_JUMPSHIFT_temp(27 downto 0);

	SHIFTLEFT3: ShiftLeft2 port map( --Skipped SHIFTLEFT2 because of component name
		i_A => s_SignExt,
		o_F => s_32SignExtend
	);

	FULLADDER1: full_adder_n port map(
		i_A 	=> s_FULLADDER,
		i_B 	=> s_32SignExtend,
		i_Cin 	=> '0',
		o_Sum	=> s_FULLADDER1
	);
	
	MUX_PCSrc: mux2t1_N port map(
		i_S 	=> (s_Branch and s_ALUZero),
		i_D0 	=> s_FULLADDER,
		i_D1 	=> s_FULLADDER1,
		o_O 	=> s_MUX
	);

	MUX_Jump: mux2t1_N port map(
		i_S 	=> s_Jump,
		i_D0 	=> s_MUX,
		i_D1 	=> s_32SignExtend,
		o_O 	=> s_PC --NOTE: This signal is meant to connect to the PC's input 
	);

end structural;

-------------------------------------------------------------------------
-- Henry Duwe, Remington Greatline, Lex Somers
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
	generic(N : integer := DATA_WIDTH);
	port(
		iCLK		: in std_logic;
		iRST		: in std_logic;
		iInstLd		: in std_logic;
		iInstAddr	: in std_logic_vector(N-1 downto 0);
		iInstExt	: in std_logic_vector(N-1 downto 0);
		oALUOut		: out std_logic_vector(N-1 downto 0)
	); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.
end  MIPS_Processor;

architecture structure of MIPS_Processor is

  	component mem is
		generic(
			ADDR_WIDTH : integer;
			DATA_WIDTH : integer

		);
		port(
			clk		: in std_logic;
			addr	: in std_logic_vector((ADDR_WIDTH-1) downto 0);
			data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			we		: in std_logic := '1';
			q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);
    end component;



	component ControlUnit
		port(
			i_Instr 	: in std_logic_vector(31 downto 0);
			o_RegDst	: out std_logic_vector(1 downto 0);
			o_Jump 		: out std_logic;
			o_Branch 	: out std_logic;
			o_MemtoReg 	: out std_logic_vector(1 downto 0);
			o_ALUOp 	: out std_logic_vector(4 downto 0); -- Controls what operation the ALU does and what it outputs
			o_MemWrite 	: out std_logic;
			o_ALUSrc 	: out std_logic;
			o_RegWrite 	: out std_logic;
			o_Jal		: out std_logic;
			o_Jr		: out std_logic;
			o_Halt		: out std_logic
		);
	end component;



	component ALU
		port(
			i_Data1 	: in std_logic_vector(31 downto 0);
			i_Data2 	: in std_logic_vector(31 downto 0);
			i_ALUOp 	: in std_logic_vector(4 downto 0); --This is decoded into instructions for the ALU
			i_ShiftAmt 	: in std_logic_vector(4 downto 0); -- This is bits 10-6 of the Instruction. Specifies shift amount for the shifter.
			o_Zero 		: out std_logic; -- checks if two inputs are the same. used for branching
			o_Out 		: out std_logic_vector(31 downto 0);
			o_Overflow 	: out std_logic
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



	component ShiftLeft2 is
		port(
			i_A    : in std_logic_vector(N-1 downto 0);
			o_F    : out std_logic_vector(N-1 downto 0)
		);
	end component;



	component full_adder_n is
		port(
			i_A		: in std_logic_vector(N-1 downto 0);
			i_B		: in std_logic_vector(N-1 downto 0);
			i_Cin	: in std_logic;
			o_Cout	: out std_logic;
			o_Sum	: out std_logic_vector(N-1 downto 0)
		);
	end component;



	component dffg_N is 
		port(
			i_CLK	: in std_logic; -- Clock input
			i_RST	: in std_logic; -- Reset input
			i_WrE	: in std_logic; -- Write enable input
			i_D		: in std_logic_vector(N-1 downto 0); -- Data value input
			o_Q		: out std_logic_vector(N-1 downto 0) -- Data value output
		);
		end component;

		component PC_Reg is
			generic(N : integer := 32);
			port(
				i_CLK	: in std_logic; -- Clock input
				i_RST	: in std_logic; -- Reset input
				i_WrE	: in std_logic; -- Write enable input
				i_D		: in std_logic_vector(N-1 downto 0); -- Data value input
				o_Q		: out std_logic_vector(N-1 downto 0) -- Data value output
			);
		  end component;

	-- Required data memory signals
-------------------------------------------------------------------------------------------------------------------------------------------------------
	signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
	signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
	signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
	signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
	
	-- Required register file signals 
	signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
	signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
	signal s_RegDstMUXOut	: std_logic_vector(4 downto 0);
	signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

	-- Required instruction memory signals
	signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
	signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
	signal s_Inst         : std_logic_vector(N-1 downto 0); -- Done: use this signal as the instruction signal

	-- Required halt signal -- for simulation
	signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

	-- Required overflow signal -- for overflow exception detection
	signal s_Ovfl         : std_logic;  -- This signal indicates an overflow exception would have been initiated
-------------------------------------------------------------------------------------------------------------------------------------------------------



-- Done: You may add any additional signals or components your implementation requires below this comment



	--CUSTOM SIGNALS
-------------------------------------------------------------------------------------------------------------------------------------------------------

	-- DONE SIGNALS. These are the signals that have been assigned as an output, and used as an input.
	---------------------------------------------------------------------------------------------------------

	-- ControlUnit Signal Outputs
		signal s_RegDst 	: std_logic_vector(1 downto 0); -- Connects output of ControlUnit (o_RegDst) to Mux_ReRegDst (i_S)
		signal s_MemtoReg	: std_logic_vector(1 downto 0); -- Connects output of ControlUnit (o_MemtoReg) to MUX_MemtoReg (i_S)
		signal s_ALUOp		: std_logic_vector(4 downto 0); -- Connects output of ControlUnit (o_ALUOp) to ALU (i_ALUOp)
		signal s_SelALUSrc 	: std_logic; -- Connects output of ControlUnit (o_ALUSrc) to MUX_ALUSrc (i_S)

	-- reg_file Signal Outputs
		signal s_RegData1	: std_logic_vector(N-1 downto 0); -- Connects output of MIPS_Register (o_RdD1) to ALU1 (i_Data1)
		signal s_RegData2	: std_logic_vector(N-1 downto 0); -- Connects output of MIPS_Register (o_RdD2) to MUX_ALUSrc (i_D0) and MEM_Data (i_Data)

	-- ALU Signal Outputs
		--signal s_ALUOut		: std_logic_vector(N-1 downto 0); -- Connects output of ALU (o_Out) to MEM_Data (i_Addr) and MUX_MemtoReg (i_D0)
		signal s_ALUZero	: std_logic; -- RG: Connects to zero output of ALU

	-- MUX_ALUSrc Signal Outputs
		signal s_ALUSrc		: std_logic_vector(N-1 downto 0); -- Connects output of MUX_ALUSrc (o_O) to ALU1 (i_Data2)

	---------------------------------------------------------------------------------------------------------


	-- TODO SIGNALS. These are the signals that have not been assigned as an output, and/or used as an input.
	---------------------------------------------------------------------------------------------------------
	-- ControlUnit Signal Outputs
		-- TODO assigned output, not used as input yet
		signal s_Jump		: std_logic; -- Connects output of ControlUnit (o_Jump) to Mux_Jump (i_S)
		-- TODO assigned output, not used as input yet
		signal s_Branch		: std_logic; -- Connects output of ControlUnit (o_Branch) to AND_Branch (i_A)

	-- signExt Signal Outputs
		--TODO assigned output, used as input for ALUSrc, but not used for the address-calculation-adder input on the top half of the diagram
		signal s_SignExt	: std_logic_vector(N-1 downto 0); -- Connects output of signExt (o_F) to MUX_ALUSrc (i_D1)
	
	-- RG: Extranious Signals
		signal s_JumpAddr	: std_logic_vector(N-1 downto 0); -- RG: Connects to shift left 2 output
		signal s_Add4		: std_logic_vector(N-1 downto 0); -- RG: Connects to add plus 4 output
		signal s_temp : std_logic_vector(N-1 downto 0); -- RG: Temporary signal for s_JumpAddr
		signal s_SignExt1 : std_logic_vector(N-1 downto 0); -- RG: Input for Adder who in turn is connected to PCSrc mux port D1
		signal s_Add : std_logic_vector(N-1 downto 0);
		signal s_JumpMUX_D0 : std_logic_vector(N-1 downto 0); -- RG: Provides input for Jump mux at port D0
		signal s_PCInput : std_logic_vector(N-1 downto 0); -- RG: TODO: Figure out where to route PC block's input to
		signal s_MUXMemtoRegOut : std_logic_vector(N-1 downto 0);
		signal s_MuxJumpOutput : std_logic_vector(N-1 downto 0);
		signal s_Jr : std_logic;

		--RG: Beginning to jal test
		signal s_RegWrData2 : std_logic_vector(N-1 downto 0);
		signal s_jalAddress : std_logic_vector(N-1 downto 0);
		signal s_Jal : std_logic;
		signal s_PCInputTemp : std_logic_vector(N-1 downto 0);
		signal s_NextInstAddr_Temp	: std_logic_vector(N-1 downto 0);
		--End of jal test

	---------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------

begin

  -- Done: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  	with iInstLd select s_IMemAddr <= 
		s_NextInstAddr when '0',
    	iInstAddr when others;


  IMem: mem
    generic map(
		ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
	)
    port map(
		clk  => iCLK,
        addr => s_IMemAddr(11 downto 2),
        data => iInstExt,
        we   => iInstLd,
        q    => s_Inst
	);
  
  DMem: mem
    generic map(
		ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => N
	)
    port map(
		clk  => iCLK,
        addr => s_DMemAddr(11 downto 2),
        data => s_DMemData,
        we   => s_DMemWr,
        q    => s_DMemOut
	);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- DONE: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

	MUX_RegDst: mux2t1_5 port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_S 	=> s_RegDst(0),
		i_D0 	=> s_Inst(20 downto 16),
		i_D1 	=> s_Inst(15 downto 11),
		o_O		=> s_RegDstMUXOut
	);

	MUX_RegDst2: mux2t1_5 port map(
		i_S 	=> s_RegDst(1),
		i_D0 	=> s_RegDstMUXOut,
		i_D1 	=> b"11111",
		o_O		=> s_RegWrAddr
	);

	MIPS_Register: reg_file port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_CLK		=> iCLK,
		i_RST		=> iRST,
		i_WrD		=> s_RegWrData,
		i_WrAddr	=> s_RegWrAddr,
		i_RdS1		=> s_Inst(25 downto 21),
		i_RdS2		=> s_Inst(20 downto 16),
		i_WrE		=> s_RegWr,
		o_RdD1		=> s_RegData1,
		o_RdD2		=> s_RegData2
	);
		s_DMemData 	<= s_RegData2; -- Assigning Required data memory data input signal to the second output of the reg file

	MUX_ALUSrc: mux2t1_N port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_S 	=> s_SelALUSrc,
		i_D0 	=> s_RegData2,
		i_D1 	=> s_SignExt,
		o_O 	=> s_ALUSrc
	);

	ALU1: ALU port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_Data1 	=> s_RegData1, 
		i_Data2 	=> s_ALUSrc,
		i_ALUOp 	=> s_ALUOp,
		i_ShiftAmt 	=> s_Inst(10 downto 6),
		o_Zero 		=> s_ALUZero,
		o_Out 		=> oALUOut,
		o_Overflow 	=> s_Ovfl
	);

	s_DMemAddr <= oALUOut; --RG: Replaces line above
	Sign_Extender: signExt port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_A 	=> s_Inst(15 downto 0),
		i_S 	=> '1',
		o_F 	=> s_SignExt
	);

	MUX_MemtoReg: mux2t1_N port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_S 	=> s_MemtoReg(0),
		--i_D0	=> oALUOut, --RG: Replaces line above
		i_D0 => s_DMemAddr, --RG: Synthesis tool complains about assigning an output to an input
		i_D1 	=> s_DMemOut,
		o_O 	=> s_MUXMemtoRegOut
	);

	MUX_MemtoReg2: mux2t1_N port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
		i_S 	=> s_MemtoReg(1),
		i_D0	=> s_MUXMemtoRegOut,
		i_D1 	=> s_Add4,
		o_O 	=> s_RegWrData --RG: Old solution prior to jal mux and adder test
		--o_O 	=> s_RegWrData2
	);

	--RG: TODO: Make a jal mux and adder that will add the base address to the increment and hand that value to the register if a jal control signal is used
	/*
	ADDJAL: full_adder_n port map(
		i_A		=> s_RegWrData2,
		i_B		=> 32b"10000000000000000000000",
		i_Cin	=> '0',
		o_Sum	=> s_jalAddress
	);

	MUX_JAL: mux2t1_N port map(
		i_S 	=> s_Jal,
		i_D0	=> s_RegWrData2, --If jal signal is not used
		i_D1 	=> s_jalAddress, --If jal signal is used
		o_O 	=> s_RegWrData
	);
	--end of TODO block
	*/

	CONTROL_UNIT: ControlUnit port map( -- DONE. Signal assingments should be correct as of 4/11/2023.
        i_Instr		=> s_Inst,
        o_RegDst	=> s_RegDst,
        o_Jump		=> s_Jump, 
        o_Branch	=> s_Branch,
        o_MemtoReg	=> s_MemtoReg,
        o_ALUOp		=> s_ALUOp,
        o_MemWrite	=> s_DMemWr,
        o_ALUSrc    => s_SelALUSrc,
        o_RegWrite 	=> s_RegWr,
		o_Jal		=> s_Jal,
		o_Jr		=> s_Jr,
		o_Halt		=> s_Halt
	);

	ADD4: full_adder_n port map( -- RG: Takes PC value, adds 4, and sends result to ShiftLeft2_1
		i_A		=> s_NextInstAddr,
		i_B		=> 32b"0100",
		i_Cin	=> '0',
		o_Sum	=> s_Add4
	);
		--RG: DONE: ShiftLeft2 under construction
	ShiftLeft2_Instruction: ShiftLeft2 port map( -- RG: Conveys jump address from instruction to jump mux
		i_A			=> 6b"0" & s_Inst(25 downto 0),
		o_F			=> s_temp
	);

	s_JumpAddr <= (s_temp and 32b"00001111111111111111111111111111") or (s_Add4 and 32b"11110000000000000000000000000000"); -- RG: The true output of ShiftLeft2_1

	ShiftLeft2_Add: ShiftLeft2 port map(
		i_A		    => s_SignExt,
		o_F			=> s_SignExt1
	);

	ADD: full_adder_n port map(
		i_A		=> s_Add4,
		i_B		=> s_SignExt1,
		i_Cin	=> '0',
		o_Sum	=> s_Add
	);

	MUX_Branch: mux2t1_N port map(
		i_S    => (s_Branch and s_ALUZero),
    	i_D0    => s_Add4,
    	i_D1    => s_Add,
    	o_O     => s_JumpMUX_D0
	);

	MUX_Jump: mux2t1_N port map(
		i_S    => s_Jump,
    	i_D0    => s_JumpMUX_D0,
    	i_D1    => s_JumpAddr, --RG: Neglected "4" which I'm sure has no consequences!
    	o_O     => s_MuxJumpOutput
		--o_O     => s_PCInputTemp
	);

	MUX_JumpRegister: mux2t1_N port map(
		i_S    => s_Jr,
    	i_D0    => s_MuxJumpOutput,
    	i_D1    => s_DMemAddr,
    	o_O     => s_PCInput
		--o_O		=> s_PCInputTemp
	);

	--s_PCInput <= s_PCInputTemp or 32b"10000000000000000000000"; 

	-- s_NextInstAddr_Temp <= s_NextInstAddr;

	-- with iRST select s_NextInstAddr <=
	-- 	(s_NextInstAddr_Temp or 32b"10000000000000000000000") when '1',
	-- 	s_NextInstAddr_Temp when others;

	PC_Register: PC_Reg port map(
		i_CLK	=> iCLK,
		i_RST	=> iRST,
		i_WrE	=> '1',
		i_D		=> s_PCInput,
		o_Q		=> s_NextInstAddr
	);

end structure;

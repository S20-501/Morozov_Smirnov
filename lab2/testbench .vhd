library ieee;
use ieee.std_logic_1164.all;

entity tb_demodulator_decoder is
end tb_demodulator_decoder;

architecture tb of tb_demodulator_decoder is

    component demodulator_decoder
        port (CLK : in std_logic :='0';
					reset : in std_logic :='0';
					IData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
					QData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
					DataValid : in std_logic :='0';
					BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
					DataStrobe : out std_logic :='0');
    end component;
	 component tester_demodulator_decoder
        port (tester_CLK : in std_logic :='0';
					tester_reset : in std_logic :='0';
					tester_IData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
					tester_QData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
					tester_DataValid : in std_logic :='0';
					tester_BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
					tester_DataStrobe : out std_logic :='0');
    end component;

		signal test_CLK :  std_logic :='0';
		signal test_reset :  std_logic :='0';
		signal test_IData_In : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
		signal test_QData_In :STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
		signal test_DataValid :  std_logic :='0';
		signal test_BufDataOut: STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
		signal test_DataStrobe : std_logic :='0';
	begin

    dut : demodulator_decoder
    port map (
					CLK => test_CLK,
					reset => test_reset,
					IData_In => test_IData_In,
					QData_In => test_QData_In,
					DataValid => test_DataValid,
					BufDataOut => test_BufDataOut,
					DataStrobe => test_DataStrobe);
	tester : tester_demodulator_decoder
    port map ( tester_CLK => test_CLK,
					 tester_reset => test_reset,
					 tester_IData_In => test_IData_In,
					 tester_QData_In => test_QData_In,
					 tester_DataValid => test_DataValid,
					 tester_BufDataOut => test_BufDataOut,
					 tester_DataStrobe => test_DataStrobe);		
end;
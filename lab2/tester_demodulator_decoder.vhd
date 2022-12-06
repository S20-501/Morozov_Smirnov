library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.ALL;
entity tester_demodulator_decoder is
port(tester_CLK : out std_logic :='0';
				tester_reset : out std_logic :='0';
				tester_IData_In :out STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
				tester_QData_In :out STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
				tester_DataValid : out std_logic :='0';
				tester_BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
				tester_DataStrobe : out std_logic :='0');
end tester_demodulator_decoder;
architecture tester of tester_demodulator_decoder is
    constant TbPeriod : time := 2 ps;
    signal TbClock : std_logic := '1';
    signal TbSimEnded : std_logic := '0';
	 procedure skiptime(time_count: in integer) is
	 begin
		  count_time: for k in 0 to time_count-1 loop
		  wait until rising_edge(TbClock);
		  end loop count_time ;
	 end;
begin
		  TbClock <= not TbClock after TbPeriod/2	 when TbSimEnded /= '1' else '0';
		  tester_CLK <= TbClock;
stimuli : process
    begin
		 wait for 2 ps;
		 skiptime(6335000);
		 TbSimEnded <= '1';
    end process;
end tester;

configuration ts_demodulator_decoder of tester_demodulator_decoder is
    for tester
    end for;
end ts_demodulator_decoder;
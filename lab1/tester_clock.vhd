library ilibrary ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
entity tester_clock is
port(tester_CLK                    : out std_logic:='0';
              tester_reset                  : out std_logic:='0';
              tester_add_minute_units       : out std_logic:='0';
              tester_add_hours_units        : out std_logic:='0';
              tester_add_minute_tens        : out std_logic:='0';
              tester_add_hours_tens         : out std_logic:='0');
end tester_clock;
architecture tester of tester_clock is
    	 constant TbPeriod : time := 2 ps;
    signal TbClock : std_logic := '1';
    signal TbSimEnded : std_logic := '0';
	 procedure skiptime(time_count: in integer) is
	 begin
		  count_time: for k in 0 to time_count-1 loop
		 if rising_edge(TbClock) then
		  wait for 2 ps;
		  end if;
		  end loop count_time ;
	 end;
begin
		  TbClock <= not TbClock after TbPeriod/2	 when TbSimEnded /= '1' else '0';
		  tester_CLK <= TbClock;
stimuli : process
    begin
		  wait for 2 ps;
		  --wait for 12670 ns;
		  skiptime(6335000);
		  tester_reset <= '1';
		  --wait for 1 ns;
		  skiptime(50);
		  tester_reset <= '0';
		  tester_add_minute_units<= '1';
		  --wait for 60 ns;
        	  skiptime(50);
		  tester_add_minute_units<= '0';
		  tester_add_minute_tens<='1';
		  --wait for 60 ns;
		  skiptime(50);
		  tester_add_minute_tens<='0';
		  tester_add_hours_units<='1';
       		  --wait for 60 ns;      
        	  skiptime(50);
		  tester_add_hours_units<='1';
		  tester_add_hours_tens<='1';
		  --wait for 60 ns;
        	  skiptime(50);
		  tester_add_hours_tens<='1';
		  skiptime(50);
		  TbSimEnded <= '1';
    end process;
end tester;

configuration ts_clock of tester_clock is
    for tester
    end for;
end ts_clock;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_clock is
end tb_clock;

architecture tb of tb_clock is

    component clock
        port (CLK                    : in std_logic:='0';
              reset                  : in std_logic:='0';
              add_minute_units       : in std_logic:='0';
              add_hours_units        : in std_logic:='0';
              add_minute_tens        : in std_logic:='0';
              add_hours_tens         : in std_logic:='0';
              Led                    : out unsigned (4 downto 0):=(others => '0');
              out_7seg_minute_units  : out std_logic_vector (7 downto 0):=(others => '0');
              out_7seg_minute_tens   : out std_logic_vector (7 downto 0):=(others => '0');
              out_7seg_hours_tens    : out std_logic_vector (7 downto 0):=(others => '0');
              out_7seg_hours_units : out std_logic_vector (7 downto 0):=(others => '0'));
    end component;

    signal CLK                    : std_logic:='0';
    signal reset                  : std_logic:='0';
    signal add_minute_units       : std_logic:='0';
    signal add_hours_units        : std_logic:='0';
    signal add_minute_tens        : std_logic:='0';
    signal add_hours_tens         : std_logic:='0';
    signal Led                    : unsigned (4 downto 0):=(others => '0');
    signal out_7seg_minute_units  : std_logic_vector (7 downto 0):=(others => '0');
    signal out_7seg_minute_tens   : std_logic_vector (7 downto 0):=(others => '0');
    signal out_7seg_hours_tens    : std_logic_vector (7 downto 0):=(others => '0');
    signal out_7seg_hours_units : std_logic_vector (7 downto 0):=(others => '0');
    constant TbPeriod : time := 2 ps;
    signal TbClock : std_logic := '1';
    signal TbSimEnded : std_logic := '0';
begin

    dut : clock
    port map (CLK                    => CLK,
              reset                  => reset,
              add_minute_units       => add_minute_units,
              add_hours_units        => add_hours_units,
              add_minute_tens        => add_minute_tens,
              add_hours_tens         => add_hours_tens,
              Led                    => Led,
              out_7seg_minute_units  => out_7seg_minute_units,
              out_7seg_minute_tens   => out_7seg_minute_tens,
              out_7seg_hours_tens    => out_7seg_hours_tens,
              out_7seg_hours_units => out_7seg_hours_units);
    TbClock <= not TbClock after TbPeriod/2	 when TbSimEnded /= '1' else '0';
    CLK <= TbClock;

    stimuli : process
    begin
        wait for 12670 ns;
		  reset <= '1';
		  wait for 1 ns;
		  reset <= '0';
		  add_minute_units<= '1';
		  wait for 60 ns;
        add_minute_units<= '0';
		  add_minute_tens<='1';
		  wait for 60 ns;
		  add_minute_tens<='0';
		  add_hours_units<='1';
        wait for 60 ns;      
        add_hours_units<='1';
		  add_hours_tens<='1';
		  wait for 60 ns;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_clock of tb_clock is
    for tb
    end for;
end cfg_tb_clock;

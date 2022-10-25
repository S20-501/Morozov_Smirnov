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
	 component tester_clock
        port (tester_CLK                    : out std_logic:='0';
              tester_reset                  : out std_logic:='0';
              tester_add_minute_units       : out std_logic:='0';
              tester_add_hours_units        : out std_logic:='0';
              tester_add_minute_tens        : out std_logic:='0';
              tester_add_hours_tens         : out std_logic:='0');
    end component;

    signal test_CLK                    : std_logic:='0';
    signal test_reset                  : std_logic:='0';
    signal test_add_minute_units       : std_logic:='0';
    signal test_add_hours_units        : std_logic:='0';
    signal test_add_minute_tens        : std_logic:='0';
    signal test_add_hours_tens         : std_logic:='0';
    signal test_Led                    : unsigned (4 downto 0):=(others => '0');
    signal test_out_7seg_minute_units  : std_logic_vector (7 downto 0):=(others => '0');
    signal test_out_7seg_minute_tens   : std_logic_vector (7 downto 0):=(others => '0');
    signal test_out_7seg_hours_tens    : std_logic_vector (7 downto 0):=(others => '0');
    signal test_out_7seg_hours_units : std_logic_vector (7 downto 0):=(others => '0');
begin

    dut : clock
    port map (CLK                    => test_CLK,
              reset                  => test_reset,
              add_minute_units       => test_add_minute_units,
              add_hours_units        => test_add_hours_units,
              add_minute_tens        => test_add_minute_tens,
              add_hours_tens         => test_add_hours_tens,
              Led                    => test_Led,
              out_7seg_minute_units  => test_out_7seg_minute_units,
              out_7seg_minute_tens   => test_out_7seg_minute_tens,
              out_7seg_hours_tens    => test_out_7seg_hours_tens,
              out_7seg_hours_units => test_out_7seg_hours_units);
	tester : tester_clock
    port map (tester_CLK                    => test_CLK,
              tester_reset                  => test_reset,
              tester_add_minute_units       => test_add_minute_units,
              tester_add_hours_units        => test_add_hours_units,
              tester_add_minute_tens        => test_add_minute_tens,
				  tester_add_hours_tens         => test_add_hours_tens);				
end;
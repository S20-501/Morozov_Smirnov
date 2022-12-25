library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

use std.env.finish;
use std.env.stop;

entity generator_tester is
    port(
        clk               : out  std_logic := '0';
        nRst              : out  std_logic := '0';
        DDS_en_s          : out  std_logic := '1';
        DDS_mode_s        : out  std_logic_vector(1 downto 0) := (others => '0');
        DDS_amplitude_s   : out  std_logic_vector(15 downto 0) := (others => '1');
        DDS_frequency_s   : out  std_logic_vector(31 downto 0) := (others => '0');
        DDS_start_phase_s : out  std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;

architecture a_generator_tester of generator_tester is
    signal clock_r:std_logic := '0';

    procedure skiptime(time_count: in integer) is
    begin
        count_time: for k in 0 to time_count-1 loop
            wait until falling_edge(clock_r); 
            wait for 200 ps; --need to wait for signal stability, value depends on the Clk frequency. 
                        --For example, for Clk period = 100 ns (10 MHz) it's ok to wait for 200 ps.
        end loop count_time ;
    end;
begin
    clock_r <= not clock_r after 10 ns;
    clk <= clock_r;

    process
    begin
        skiptime(10);

        nRst <= '1';
        DDS_frequency_s <= X"010003FF";
        skiptime(1000);


        DDS_mode_s <= "01";
        skiptime(1000);

        DDS_mode_s <= "10";
        skiptime(1000);

        DDS_mode_s <= "00";
        skiptime(1000);

        DDS_mode_s <= "11";


        for k in 1048276-256 to 1048276+256 loop
            DDS_frequency_s <= conv_std_logic_vector(k * 102400, DDS_frequency_s'length);
            skiptime(5);
        end loop;
        

        DDS_start_phase_s <= X"A0F1";
        skiptime(1550);

        DDS_start_phase_s <= X"EFF1";
        skiptime(1550);

        DDS_start_phase_s <= X"6FF1";
        skiptime(1550);

        DDS_start_phase_s <= X"2FFF";
        skiptime(1550);

        DDS_start_phase_s <= X"0000";


        DDS_frequency_s <= X"010003FF";

        for k in 0 to 256 loop
            DDS_amplitude_s <= conv_std_logic_vector(k * 256, DDS_amplitude_s'length);
            skiptime(10);
        end loop;

        skiptime(100);

        DDS_en_s <= '0';
        
        skiptime(100);

        stop;
    end process;
end architecture;

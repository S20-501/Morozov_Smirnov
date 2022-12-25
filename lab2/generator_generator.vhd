library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
-- use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

entity generator_generator is
    port (
        clk: in std_logic;
        nRst: in std_logic;
        DDS_en_s: in std_logic;
        DDS_mode_s: in std_logic_vector(1 downto 0);
        -- DDS_amplitude_s: in std_logic_vector(15 downto 0);
        DDS_frequency_s: in std_logic_vector(31 downto 0);
        DDS_start_phase_s: in std_logic_vector(15 downto 0);

        DAC_I_s: out std_logic_vector(9 downto 0);
        DAC_Q_s: out std_logic_vector(9 downto 0);

        MainPhase_s: out std_logic_vector(9 downto 0);
        
        -- signals from SIN generator
        SIN_I_s: in std_logic_vector(9 downto 0);
        SIN_Q_s: in std_logic_vector(9 downto 0)
    );
end entity;

architecture a_generator_generator of generator_generator is
    constant SIN_WAVE:          std_logic_vector(1 downto 0) := "00";
    constant SAW_WAVE:          std_logic_vector(1 downto 0) := "01";
    constant SQUARE_WAVE:       std_logic_vector(1 downto 0) := "10";
    constant MODULATED_WAVE:    std_logic_vector(1 downto 0) := "11";

    signal MainAccumulator_counter: std_logic_vector(31 downto 0);

    signal saw_i_r: std_logic_vector(9 downto 0);
    signal square_i_r: std_logic_vector(9 downto 0);

    signal MainPhase_r: std_logic_vector(15 downto 0);  
begin
    -- mode selector
    with DDS_mode_s select DAC_I_s <=
            SIN_I_s when SIN_WAVE,
            saw_i_r when SAW_WAVE,
            square_i_r when SQUARE_WAVE,
            SIN_I_s when MODULATED_WAVE,
            (others => '0') when others;
    
    with DDS_mode_s select DAC_Q_s <=
        SIN_Q_s when MODULATED_WAVE,
        (others => '0') when others;


    saw_i_r <= MainAccumulator_counter(31 downto 31-9); -- major 10bits of accumulator

    with MainAccumulator_counter(31) select square_i_r <=  -- major bit is sign
        (others => '1') when '1',
        (others => '0') when others;


    MainPhase_s <= MainPhase_r(15 downto 15-9);  -- for sin_generator.vhd 

    accumulator_p:  process(nRst, clk)
    begin
        if (nRst = '0') then
            MainAccumulator_counter <= (others => '0');
            MainPhase_r <= (others => '0');
        elsif (rising_edge(clk)) then
            if (DDS_en_s = '1') then
                MainAccumulator_counter <= MainAccumulator_counter + DDS_frequency_s;
                MainPhase_r <= MainAccumulator_counter(31 downto 31-15) + DDS_start_phase_s;
            end if;
        end if;        
    end process;
end architecture;

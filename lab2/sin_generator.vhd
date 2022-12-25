library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
-- use ieee.std_logic_unsigned.all;

entity sin_generator is
    port (
        nRst: in std_logic;
        clk: in std_logic;

        MainPhase: in std_logic_vector(9 downto 0);
        DDS_amplitude_s: in std_logic_vector(15 downto 0);

        -- signals from SIN generator
        SIN_I_s: out std_logic_vector(9 downto 0);
        SIN_Q_s: out std_logic_vector(9 downto 0);

        -- address ports
        address_a_s: out std_logic_vector (7 downto 0);
        address_b_s: out std_logic_vector (7 downto 0);

        -- outputs of ROM
        q_a: in std_logic_vector (8 downto 0);
        q_b: in std_logic_vector (8 downto 0)
    );
end entity;

architecture a_sin_generator of sin_generator is  
    procedure phase_convert (
        signal phase_r: in std_logic_vector(9 downto 0);
        signal output_r: in std_logic_vector (8 downto 0);
        
        signal address_r: out std_logic_vector(7 downto 0);        
        signal SIN_r: out std_logic_vector(9 downto 0)
    ) is
        constant FIRST_QUATER:  std_logic_vector(1 downto 0)  := "00";
        constant SECOND_QUATER: std_logic_vector(1 downto 0)  := "01";
        constant THIRD_QUATER:  std_logic_vector(1 downto 0)  := "10";
        constant FOURTH_QUATER: std_logic_vector(1 downto 0)  := "11";
    begin
        if (phase_r(9 downto 8) = FIRST_QUATER) then
            address_r <= phase_r(7 downto 0); -- address in direct order
            SIN_r <= ('0' & output_r); -- no inversion
        elsif (phase_r(9 downto 8) = SECOND_QUATER) then
            address_r <= 255 - phase_r(7 downto 0); -- address in reverse order
            SIN_r <= ('0' & output_r); -- no inversion
        elsif (phase_r(9 downto 8) = THIRD_QUATER) then
            address_r <= phase_r(7 downto 0); -- address in direct order
            SIN_r <= 511 - ('1' & output_r); -- invert SIN
        elsif (phase_r(9 downto 8) = FOURTH_QUATER) then
            address_r <= 255 - phase_r(7 downto 0);  -- address in reverse order
            SIN_r <= 511 - ('1' & output_r); -- invert SIN
        end if;
    end procedure;

    constant HALF_PI: std_logic_vector(9 downto 0) := (X"40" & B"00");

    signal SIN_I_r: std_logic_vector(9 downto 0);
    signal SIN_Q_r: std_logic_vector(9 downto 0);

    signal address_a_r: std_logic_vector (7 downto 0);
    signal address_b_r: std_logic_vector (7 downto 0);

    signal ShiftedPhase_r: std_logic_vector(9 downto 0);

    signal Multiplied_SIN_I_r: std_logic_vector(26 downto 0);
    signal Multiplied_SIN_Q_r: std_logic_vector(26 downto 0);
begin
    address_a_s <= address_a_r;
    address_b_s <= address_b_r;

    SIN_I_s <= Multiplied_SIN_I_r(25 downto 25 - 9); -- major 10bits of multiplied value
    SIN_Q_s <= Multiplied_SIN_Q_r(25 downto 25 - 9);

    phase_convert_p : process(clk, nRst)
    begin
        if (nRst = '0') then
            SIN_I_r <= (others => '0');
            SIN_Q_r <= (others => '0');

            address_a_r <= (others => '0');
            address_b_r <= (others => '0');

            ShiftedPhase_r <= (others => '0');

            Multiplied_SIN_I_r <= (others => '0');
            Multiplied_SIN_Q_r <= (others => '0');
        elsif (rising_edge(clk)) then
            ShiftedPhase_r <= MainPhase + HALF_PI;

            phase_convert(MainPhase, q_a, address_a_r, SIN_I_r);
            phase_convert(ShiftedPhase_r, q_b, address_b_r, SIN_Q_r);

            Multiplied_SIN_I_r <= signed(SIN_I_r) * unsigned(DDS_amplitude_s); -- signals after multiplier
            Multiplied_SIN_Q_r <= signed(SIN_Q_r) * unsigned(DDS_amplitude_s);
        end if;
    end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

entity modulator_lut is
    port (
        address: in std_logic_vector(5 downto 0);
		clock		: IN STD_LOGIC  := '1';
        nRst: in std_logic;
		Amplitude: out std_logic_vector(15 downto 0);
        StartPhase: out std_logic_vector(15 downto 0)
    );
end entity modulator_lut;

architecture a_modulator_lut of modulator_lut is
    TYPE int_array is ARRAY (natural range <>) of std_logic_vector(15 downto 0);

    CONSTANT lut_qpsk_start_phase : int_array := (
        X"A000", --
        X"6000", --
        X"E000", --
        X"2000", --

        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000"
    );

    CONSTANT lut_8psk_start_phase : int_array := (
        X"A000",
        X"8000",--
        X"4000",--
        X"6000",--
        X"C000",--
        X"E000",--
        X"2000",
        X"0000",

        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000"
    );

    CONSTANT lut_16qam_start_phase: int_array := (
        X"A000",
        X"A666",
        X"E000",
        X"D333",
        X"9333",
        X"A000",
        X"E666",--
        X"E000",
        X"6000",--
        X"5333",
        X"2000",
        X"2666",
        X"6666",--
        X"6000",--
        X"1333",--
        X"2000"
    );

    CONSTANT lut_qpsk_amplitude : int_array := (
        X"FFFF",
        X"FFFF",
        X"FFFF",
        X"FFFF",

        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000"
    );

    CONSTANT lut_8psk_amplitude : int_array := (
        X"FFFF",
        X"FFFF",
        X"FFFF",
        X"FFFF",
        X"FFFF",
        X"FFFF",
        X"FFFF",
        X"FFFF",

        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000",
        X"0000"
    );

    CONSTANT lut_16qam_amplitude : int_array := (
        X"FFFF",
        X"DFFF",
        X"FFFF",
        X"DFFF",
        X"DFFF",
        X"7FFF",
        X"DFFF",--
        X"7FFF",
        X"FFFF",--
        X"DFFF",
        X"FFFF",
        X"DFFF",
        X"DFFF",--
        X"7FFF",
        X"DFFF",--
        X"7FFF"
    );

    -- SIGNAL lut_qpsk_address_index : integer range 0 to 3;
    -- SIGNAL lut_8psk_address_index : integer range 0 to 7;
    SIGNAL lut_address_index : integer range 0 to 15;

    signal Amplitude_r : std_logic_vector(15 downto 0);
    signal StartPhase_r : std_logic_vector(15 downto 0);
begin
    Amplitude <= Amplitude_r;
    StartPhase <= StartPhase_r;

    process (nRst, clock)
    begin
        if nRst = '0' then
            Amplitude_r <= (others => '0');
            StartPhase_r <= (others => '0'); 
        elsif rising_edge(clock) then
            if (address < B"000100") then  -- QPSK
                lut_address_index <= CONV_INTEGER(address(1 downto 0)); -- delay 1 clk
                Amplitude_r <= lut_qpsk_amplitude(lut_address_index);
                StartPhase_r <= lut_qpsk_start_phase(lut_address_index);
            elsif(address < B"011111") then -- 8PSK
                lut_address_index <= CONV_INTEGER(address(2 downto 0));
                Amplitude_r <= lut_8psk_amplitude(lut_address_index);
                StartPhase_r <= lut_8psk_start_phase(lut_address_index);
            elsif(address < B"110000") then  -- 16QAM
                lut_address_index <= CONV_INTEGER(address(3 downto 0));
                Amplitude_r <= lut_16qam_amplitude(lut_address_index);
                StartPhase_r <= lut_16qam_start_phase(lut_address_index);
            end if;
        end if;
    end process;
end architecture;
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
    TYPE int_array is ARRAY (0 to 48) of std_logic_vector(15 downto 0);

    CONSTANT lut_start_phase : int_array := (
        0 => X"A000",
        1 => X"E000", --
        2 => X"6000", --
        3 => X"2000", --

        16 => X"A000",
        17 => X"8000",--
        18 => X"4000",--
        19 => X"6000",--
        20 => X"C000",--
        21 => X"E000",--
        22 => X"2000",
        23 => X"0000",

        32 => X"A000",
        33 => X"A666",
        34 => X"E000",
        35 => X"D333",
        36 => X"9333",
        37 => X"A000",
        38 => X"E666",--
        39 => X"E000",
        40 => X"6000",--
        41 => X"5333",
        42 => X"2000",
        43 => X"2666",
        44 => X"6666",--
        45 => X"6000",--
        46 => X"1333",--
        47 => X"2000",

        others => X"0000" 
    );    

    CONSTANT lut_amplitude : int_array := (
        32 => X"FFFF",
        33 => X"DFFF",
        34 => X"FFFF",
        35 => X"DFFF",
        36 => X"DFFF",
        37 => X"7FFF",
        38 => X"DFFF",--
        39 => X"7FFF",
        40 => X"FFFF",--
        41 => X"DFFF",
        42 => X"FFFF",
        43 => X"DFFF",
        44 => X"DFFF",--
        45 => X"7FFF",
        46 => X"DFFF",--
        47 => X"7FFF",

        others => X"FFFF"
    );

    -- SIGNAL lut_qpsk_address_index : integer range 0 to 3;
    -- SIGNAL lut_8psk_address_index : integer range 0 to 7;
    SIGNAL lut_address_index : integer range 0 to 15;

    -- signal Amplitude_r : std_logic_vector(15 downto 0);
    -- signal StartPhase_r : std_logic_vector(15 downto 0);
begin
    -- Amplitude <= Amplitude_r;
    -- StartPhase <= StartPhase_r;



    process (nRst, address)
    begin
        if nRst = '0' then
            Amplitude <= (others => '0');
            StartPhase <= (others => '0'); 
        else --if rising_edge(clock) then
            -- if (address < B"000100") then  -- QPSK
            --     lut_address_index <= CONV_INTEGER(address(1 downto 0)); -- delay 1 clk
            --     Amplitude_r <= lut_qpsk_amplitude(lut_address_index);
            --     StartPhase_r <= lut_qpsk_start_phase(lut_address_index);
            -- elsif(address < B"011111") then -- 8PSK
            --     lut_address_index <= CONV_INTEGER(address(2 downto 0));
            --     Amplitude_r <= lut_8psk_amplitude(lut_address_index);
            --     StartPhase_r <= lut_8psk_start_phase(lut_address_index);
            -- elsif(address < B"110000") then  -- 16QAM
            --     lut_address_index <= CONV_INTEGER(address(3 downto 0));
            --     Amplitude_r <= lut_16qam_amplitude(lut_address_index);
            --     StartPhase_r <= lut_16qam_start_phase(lut_address_index);
            -- end if;

            Amplitude <= lut_amplitude(CONV_INTEGER(address));
            StartPhase <= lut_start_phase(CONV_INTEGER(address));
        end if;
    end process;
end architecture;
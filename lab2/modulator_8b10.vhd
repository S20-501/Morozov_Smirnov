library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

entity modulator_8b10 is
    port (
        clk   : in std_logic;
        nRst : in std_logic;

        ByteReadRequest: in std_logic;
        WordReadRequest: out std_logic;

        DataPort: in std_logic_vector(15 downto 0);
        CodedData: out std_logic_vector(9 downto 0)
    );
end entity modulator_8b10;

architecture a_modulator_8b10 of modulator_8b10 is
    component enc_8b10b
        port (
        RESET : in std_logic;
        SBYTECLK : in std_logic;
        KI : in std_logic;
        AI : in std_logic;
        BI : in std_logic;
        CI : in std_logic;
        DI : in std_logic;
        EI : in std_logic;
        FI : in std_logic;
        GI : in std_logic;
        HI : in std_logic;
        JO : out std_logic;
        HO : out std_logic;
        GO : out std_logic;
        FO : out std_logic;
        IO : out std_logic;
        EO : out std_logic;
        DO : out std_logic;
        CO : out std_logic;
        BO : out std_logic;
        AO : out std_logic
      );
    end component;
    
    signal DataIn_r : std_logic_vector(7 downto 0);
    signal CurrentByte_r: std_logic;
    signal CodedData_r : std_logic_vector(9 downto 0);
    signal DataOut_r : std_logic_vector(9 downto 0);
    SIGNAL WordReadRequest_r: std_logic;
begin
    enc_8b10b_inst : enc_8b10b
    port map (
        RESET => "not"(nRst),
        SBYTECLK => clk,

        KI => '0', -- Control (K) input(active high)
        AI => DataIn_r(7),
        BI => DataIn_r(6),
        CI => DataIn_r(5),
        DI => DataIn_r(4),
        EI => DataIn_r(3),
        FI => DataIn_r(2),
        GI => DataIn_r(1),
        HI => DataIn_r(0),

        JO => DataOut_r(9),
        HO => DataOut_r(8),
        GO => DataOut_r(7),
        FO => DataOut_r(6),
        IO => DataOut_r(5),
        EO => DataOut_r(4),
        DO => DataOut_r(3),
        CO => DataOut_r(2),
        BO => DataOut_r(1),
        AO => DataOut_r(0)
    );

    con_p: process (clk, nRst)
    begin
        if nRst = '0' then
            CurrentByte_r <= '0'; -- minor byte first
            CodedData_r <= (others => '0');
            WordReadRequest_r <= '0';
        elsif rising_edge(clk) then
            if (ByteReadRequest = '1') then
                CurrentByte_r <= not CurrentByte_r;
                CodedData_r <= DataOut_r;
                WordReadRequest_r <= CurrentByte_r;
            elsif WordReadRequest_r = '1' then
                WordReadRequest_r <= '0';
            end if;
        end if;
    end process;

    CodedData <= CodedData_r;
    WordReadRequest <= WordReadRequest_r;

    with CurrentByte_r select DataIn_r <=
        DataPort(15 downto 8) when '1',
        DataPort(7 downto 0) when '0',
        (others => '0') when others;
end architecture;

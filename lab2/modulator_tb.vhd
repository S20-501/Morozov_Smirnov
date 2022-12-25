library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

entity modulator_tb is
end;

architecture a_modulator_tb of modulator_tb is
    component modulator
        port (
        clk : in std_logic;
        nRst : in std_logic;
        Sync : in std_logic;
        SignalMode : in std_logic_vector(1 downto 0);
        ModulationMode : in std_logic_vector(1 downto 0);
        Mode : in std_logic;
        AmpErr : in std_logic;
        Amplitude : out std_logic_vector(15 downto 0);
        StartPhase : out std_logic_vector(15 downto 0);
        CarrierFrequency : in std_logic_vector(31 downto 0);
        SymbolFrequency : in std_logic_vector(31 downto 0);
        DataPort : in std_logic_vector(15 downto 0);
        rdreq : out std_logic;
        DDS_en: out std_logic 
    );
    end component;

    component modulator_tester
        port (
        clk : out std_logic;
        nRst : out std_logic;
        Sync : out std_logic;
        SignalMode : out std_logic_vector(1 downto 0);
        ModulationMode : out std_logic_vector(1 downto 0);
        Mode : out std_logic;
        AmpErr : out std_logic;
        CarrierFrequency : out std_logic_vector(31 downto 0);
        SymbolFrequency : out std_logic_vector(31 downto 0);
        DataPort : out std_logic_vector(15 downto 0);
        rdreq: in std_logic
        );
    end component;


    -- Ports
    signal clk : std_logic;
    signal nRst : std_logic;
    signal Sync : std_logic;
    signal SignalMode : std_logic_vector(1 downto 0);
    signal ModulationMode : std_logic_vector(1 downto 0);
    signal Mode : std_logic;
    signal AmpErr : std_logic;
    signal Amplitude : std_logic_vector(15 downto 0);
    signal StartPhase : std_logic_vector(15 downto 0);
    signal CarrierFrequency : std_logic_vector(31 downto 0);
    signal SymbolFrequency : std_logic_vector(31 downto 0);
    signal DataPort : std_logic_vector(15 downto 0);
    signal rdreq : std_logic;
    signal DDS_en_r : std_logic;
begin
    modulator_inst : modulator
    port map (
      clk => clk,
      nRst => nRst,
      Sync => Sync,
      SignalMode => SignalMode,
      ModulationMode => ModulationMode,
      Mode => Mode,
      AmpErr => AmpErr,
      Amplitude => Amplitude,
      StartPhase => StartPhase,
      CarrierFrequency => CarrierFrequency,
      SymbolFrequency => SymbolFrequency,
      DataPort => DataPort,
      rdreq => rdreq,
      DDS_en => DDS_en_r
    );

    modulator_tester_inst : modulator_tester
    port map (
        clk => clk,
        nRst => nRst,
        Sync => Sync,
        SignalMode => SignalMode,
        ModulationMode => ModulationMode,
        Mode => Mode,
        AmpErr => AmpErr,
        CarrierFrequency => CarrierFrequency,
        SymbolFrequency => SymbolFrequency,
        DataPort => DataPort,
        rdreq => rdreq
    );

end;
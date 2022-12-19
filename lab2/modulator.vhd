library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

entity modulator is
    port (
        clk   : in std_logic;
        nRst : in std_logic;

        -- SYSTEM CONTROL Register
        Sync: in std_logic; -- O_PTR(6)
        -- nRstDDS: in std_logic; -- O_PTR(5) -- TO DDS
        SignalMode: in std_logic_vector(1 downto 0); -- O_PTR(4 downto 3)
        ModulationMode: in std_logic_vector(1 downto 0); -- O_PTR(2 downto 1)
        Mode: in std_logic;  -- O_PTR(0)


        -- DDS Register
        -- DDS Control (1 byte)
        AmpErr: in std_logic;	-- DDSControl(3)
          
        -- SignalMode: in std_logic_vector(1 downto 0); -- DDSControl(1 downto 0)
        -- Amplitude  -- DDS()
        -- StartPhase -- DDS()
        -- Frequency  -- DDS()


        -- ModulationRegister
        Amplitude: out std_logic_vector(15 downto 0);  -- TO DDS
        StartPhase: out std_logic_vector(15 downto 0);  -- TO DDS
        CarrierFrequency: in std_logic_vector(31 downto 0);
        SymbolFrequency: in std_logic_vector(31 downto 0);


        DataPort: in std_logic_vector(15 downto 0);
        rdreq: out std_logic;
        DDS_en: out std_logic       
    );
end entity modulator;

architecture a_modulator of modulator is
  component modulator_8b10
      port (
      clk : in std_logic;
      nRst : in std_logic;
      ByteReadRequest : in std_logic;
      WordReadRequest : out std_logic;
      DataPort : in std_logic_vector(15 downto 0);
      CodedData : out std_logic_vector(9 downto 0)
    );
  end component;

  component modulator_modulation
      port (
      clk : in std_logic;
      nRst : in std_logic;
      SymbolFrequency : in std_logic_vector(31 downto 0);
      CodedData : in std_logic_vector(9 downto 0);
      lut_address : out std_logic_vector(5 downto 0);
      ModulationMode : in std_logic_vector(1 downto 0);
      Mode : in std_logic;
      ByteReadRequest : out std_logic;
      DDS_En: out std_logic
    );
  end component;

  component modulator_lut
    port (
    address : in std_logic_vector(5 downto 0);
    clock : in STD_LOGIC;
    nRst : in std_logic;
    Amplitude : out std_logic_vector(15 downto 0);
    StartPhase : out std_logic_vector(15 downto 0)
  );
  end component;


  signal ByteReadRequest : std_logic;
  signal CodedData : std_logic_vector(9 downto 0);

  signal lut_address : std_logic_vector(5 downto 0);

begin
  modulator_8b10_inst : modulator_8b10
    port map (
      clk => clk,
      nRst => nRst,
      ByteReadRequest => ByteReadRequest,
      WordReadRequest => rdreq,
      DataPort => DataPort,
      CodedData => CodedData
    );

  modulator_modulation_inst : modulator_modulation
    port map (
      clk => clk,
      nRst => nRst,
      SymbolFrequency => SymbolFrequency,
      CodedData => CodedData,
      lut_address => lut_address,
      ModulationMode => ModulationMode,
      Mode => Mode,
      ByteReadRequest => ByteReadRequest,
      DDS_En => DDS_En
    );

  modulator_lut_inst : modulator_lut
    port map (
      address => lut_address,
      clock => clk,
      nRst => nRst,
      Amplitude => Amplitude,
      StartPhase => StartPhase
    );
end architecture;

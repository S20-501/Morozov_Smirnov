library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

entity generator_assembly_tb is
end;

architecture a_generator_assembly_tb of generator_assembly_tb is
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

    component demodulator_decoder
        port (clk : in std_logic :='0';
          nRst : in std_logic :='0';
            IData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
              QData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
              DataValid : in std_logic :='0';
              DataStrobe : out std_logic :='0';
            address_in_division_lut		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0):=(others => '0');
          clock		: OUT STD_LOGIC  := '1';
          division_number		: IN STD_LOGIC_VECTOR (8 DOWNTO 0):=(others => '0');
		  modulation_mode :OUT unsigned(1 downto 0) :=(others => '1');
		  useful_information :OUT STD_LOGIC_VECTOR(3 downto 0) :=(others => '0')
        );
        
      end component;
      
      component division_lut
        port (
            address_in_division_lut		: IN STD_LOGIC_VECTOR (8 DOWNTO 0):=(others => '0');
            clock		: IN STD_LOGIC  := '1';
            division_number		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0):=(others => '0')
        );
    end component division_lut;

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

    component generator_top
        port (
        clk : in std_logic;
        nRst : in std_logic;
        DDS_en_s : in std_logic;
        DDS_mode_s : in std_logic_vector(1 downto 0);
        DDS_amplitude_s : in std_logic_vector(15 downto 0);
        DDS_frequency_s : in std_logic_vector(31 downto 0);
        DDS_start_phase_s : in std_logic_vector(15 downto 0);
        DAC_I_s : out std_logic_vector(9 downto 0);
        DAC_Q_s : out std_logic_vector(9 downto 0)
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


    signal address_in_division_lut		:  STD_LOGIC_VECTOR (8 DOWNTO 0);
    signal clock		:  STD_LOGIC  := '1';
    signal division_number		: STD_LOGIC_VECTOR (8 DOWNTO 0);

    signal DAC_I_s : std_logic_vector(9 downto 0);
    signal DAC_Q_s : std_logic_vector(9 downto 0);

    signal DataValid :  std_logic :='0';
	signal BufDataOut: STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
	signal DataStrobe : std_logic :='0';
	signal modulation_mode : unsigned(1 downto 0) :=(others => '1');
	signal useful_information : STD_LOGIC_VECTOR(3 downto 0) :=(others => '0');
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

    demodulator_decoder_inst : demodulator_decoder
    port map (
      clk => clk,
      nRst => nRst,
      IData_In => DAC_I_s,
      QData_In => DAC_Q_s,
      DataValid => DataValid,
      DataStrobe => DataStrobe,
      address_in_division_lut=>address_in_division_lut,
      clock=>clock,
      division_number=>division_number,
	  modulation_mode=>modulation_mode,
	  useful_information=>useful_information
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

    generator_top_inst : generator_top
    port map (
        clk => clk,
        nRst => nRst,
        DDS_en_s => DDS_en_r,
        DDS_mode_s => SignalMode,
        DDS_amplitude_s => Amplitude,
        DDS_frequency_s => CarrierFrequency,
        DDS_start_phase_s => StartPhase,
        DAC_I_s => DAC_I_s,
        DAC_Q_s => DAC_Q_s
    );
    
    division_lut_inst: division_lut
    port map(
        address_in_division_lut=>address_in_division_lut,
        clock=>clock,
        division_number=>division_number
    );

end;
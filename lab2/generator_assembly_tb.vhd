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
              BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
              DataStrobe : out std_logic :='0';
          address_a		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
            address_b		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
            address_c		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
          clock		: OUT STD_LOGIC  := '1';
          q_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
          q_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
          q_c		: IN STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
        
      end component;
      
      component division_lut
        port (
            address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            address_c		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            q_a		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
            q_b		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
            q_c		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component division_lut;

      -- component demodulator_decoder_tester
      --   port (--clk : out std_logic :='0';
      --     -- nRst : out std_logic :='0';
      --     -- IData_In :out STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
      --     -- QData_In :out STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
      --     DataValid : out std_logic :='0';
      --     BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
      --     DataStrobe : out std_logic :='0'
      --   );
         
      --end component;

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

    signal address_a		:  STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal address_b		:  STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal address_c		:  STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal clock		:  STD_LOGIC  := '1';
    signal q_a		: STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal q_b		: STD_LOGIC_VECTOR (9 DOWNTO 0);
    signal q_c		: STD_LOGIC_VECTOR (9 DOWNTO 0);

    signal DAC_I_s : std_logic_vector(9 downto 0);
    signal DAC_Q_s : std_logic_vector(9 downto 0);

    signal DataValid :  std_logic :='0';
	signal BufDataOut: STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
	signal DataStrobe : std_logic :='0';
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
      BufDataOut => BufDataOut,
      DataStrobe => DataStrobe,
      address_a=> address_a,
      address_b=>address_b,
      address_c=>address_c,
      clock=>clock,
      q_a=>q_a,
      q_b=>q_b,
      q_c=>q_c
    );

    -- demodulator_decoder_tester_inst : demodulator_decoder_tester
    -- port map (
    -- -- clk => clk,
    -- -- nRst => nRst,
    -- -- IData_In => DAC_I_s,
    -- -- QData_In => DAC_Q_s,
    --     DataValid => DataValid,
    --     BufDataOut => BufDataOut,
    --     DataStrobe => DataStrobe
    -- );

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
        address_a=> address_a,
        address_b=>address_b,
        address_c=>address_c,
        clock=>clock,
        q_a=>q_a,
        q_b=>q_b,
        q_c=>q_c
    );




end;
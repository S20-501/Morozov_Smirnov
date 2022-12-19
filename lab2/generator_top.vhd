library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity generator_top is
    port (
        clk: in std_logic;
        nRst: in std_logic;
        DDS_en_s: in std_logic;
        DDS_mode_s: in std_logic_vector(1 downto 0);
        DDS_amplitude_s: in std_logic_vector(15 downto 0);
        DDS_frequency_s: in std_logic_vector(31 downto 0);
        DDS_start_phase_s: in std_logic_vector(15 downto 0);

        DAC_I_s: out std_logic_vector(9 downto 0);
        DAC_Q_s: out std_logic_vector(9 downto 0)
    );
end entity;

architecture a_generator_top of generator_top is
    signal MainPhase_r       : std_logic_vector(9 downto 0);
    signal SIN_I_r           : std_logic_vector(9 downto 0);
    signal SIN_Q_r           : std_logic_vector(9 downto 0);

    signal address_a_r      : std_logic_vector (7 downto 0);
    signal address_b_r      : std_logic_vector (7 downto 0);
    signal q_a_r            : std_logic_vector (8 downto 0);
    signal q_b_r            : std_logic_vector (8 downto 0);

    component sin_generator
      port (
        nRst : in std_logic;
        clk : in std_logic;
        MainPhase : in std_logic_vector(9 downto 0);
        DDS_amplitude_s : in std_logic_vector(15 downto 0);
        SIN_I_s : out std_logic_vector(9 downto 0);
        SIN_Q_s : out std_logic_vector(9 downto 0);
        address_a_s : out std_logic_vector (7 downto 0);
        address_b_s : out std_logic_vector (7 downto 0);
        q_a : in std_logic_vector (8 downto 0);
        q_b : in std_logic_vector (8 downto 0)
      );
    end component;
    

    component sin_lut
    	PORT
    	(
    		address_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    		address_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    		clock		: IN STD_LOGIC  := '1';
    		q_a		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
    		q_b		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
    	);
    end component;

    component generator_generator
        port (
        clk : in std_logic;
        nRst : in std_logic;
        DDS_en_s : in std_logic;
        DDS_mode_s : in std_logic_vector(1 downto 0);
        DDS_frequency_s : in std_logic_vector(31 downto 0);
        DDS_start_phase_s : in std_logic_vector(15 downto 0);
        DAC_I_s : out std_logic_vector(9 downto 0);
        DAC_Q_s : out std_logic_vector(9 downto 0);
        MainPhase_s : out std_logic_vector(9 downto 0);
        SIN_I_s : in std_logic_vector(9 downto 0);
        SIN_Q_s : in std_logic_vector(9 downto 0)
      );
    end component;
  

begin
  sin_generator_inst : sin_generator
    port map (
      nRst => nRst,
      clk => clk,
      MainPhase => MainPhase_r,
      DDS_amplitude_s => DDS_amplitude_s,
      SIN_I_s => SIN_I_r,
      SIN_Q_s => SIN_Q_r,
      address_a_s => address_a_r,
      address_b_s => address_b_r,
      q_a => q_a_r,
      q_b => q_b_r
    );


  sin_rom_inst : sin_lut
      PORT MAP (
      address_a	 => address_a_r,
      address_b	 => address_b_r,
      clock	 => clk,
      q_a	 => q_a_r,
      q_b	 => q_b_r
    );

  generator_generator_inst : generator_generator
    port map (
      clk => clk,
      nRst => nRst,
      DDS_en_s => DDS_en_s,
      DDS_mode_s => DDS_mode_s,
      DDS_frequency_s => DDS_frequency_s,
      DDS_start_phase_s => DDS_start_phase_s,
      DAC_I_s => DAC_I_s,
      DAC_Q_s => DAC_Q_s,
      MainPhase_s => MainPhase_r,
      SIN_I_s => SIN_I_r,
      SIN_Q_s => SIN_Q_r
    );
  
end architecture;

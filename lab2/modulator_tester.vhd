library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
-- use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;

use std.env.stop;

entity modulator_tester is
    port (
        clk   : out std_logic := '0';
        nRst : out std_logic := '0';

        -- SYSTEM CONTROL Register
        Sync: out std_logic := '0'; -- O_PTR(6)
        -- nRstDDS: in std_logic; -- O_PTR(5) -- TO DDS
        SignalMode: out std_logic_vector(1 downto 0) := (others => '0') ; -- O_PTR(4 downto 3)
        ModulationMode: out std_logic_vector(1 downto 0) := (others => '0') ; -- O_PTR(2 downto 1)
        Mode: out std_logic := '0';  -- O_PTR(0)


        -- DDS Register
        -- DDS Control (1 byte)
        AmpErr: out std_logic := '0';	-- DDSControl(3)
          
        
        -- Amplitude: out std_logic_vector(15 downto 0);  -- TO DDS
        -- StartPhase: out std_logic_vector(15 downto 0);  -- TO DDS
        CarrierFrequency: out std_logic_vector(31 downto 0) := (others => '0') ;
        SymbolFrequency: out std_logic_vector(31 downto 0) := (others => '0') ;


        DataPort: out std_logic_vector(15 downto 0) := (others => '0');
        rdreq: in std_logic
    );
end entity modulator_tester;

architecture a_modulator_tester of modulator_tester is
    signal clock_r:std_logic := '0';
    signal data_counter: std_logic_vector(15 downto 0) := (others => '0') ;

    procedure skiptime(time_count: in integer) is
    begin
        count_time: for k in 0 to time_count-1 loop
            wait until falling_edge(clock_r); 
            wait for 200 ps; --need to wait for signal stability, value depends on the Clk frequency. 
                        --For example, for Clk period = 100 ns (10 MHz) it's ok to wait for 200 ps.
        end loop count_time ;
    end;


    -- GSMRegistr start
    component GSMRegistr_FIFO
        port (
        clock : in STD_LOGIC;
        data : in STD_LOGIC_VECTOR (15 DOWNTO 0);
        rdreq : in STD_LOGIC;
        wrreq : in STD_LOGIC;
        empty : out STD_LOGIC;
        full : out STD_LOGIC;
        q : out STD_LOGIC_VECTOR (15 DOWNTO 0);
        usedw : out STD_LOGIC_VECTOR (9 DOWNTO 0)
      );
    end component;
    
    signal DataIn: std_logic_vector(15 downto 0);
    signal wrreq : STD_LOGIC := '0';
    signal empty : STD_LOGIC;
    signal full : STD_LOGIC;
    signal usedw : STD_LOGIC_VECTOR (9 DOWNTO 0);
begin
    -- GSMRegistr start
    GSMRegistr_FIFO_inst : GSMRegistr_FIFO
    port map (
        clock => clock_r,
        data => DataIn,
        rdreq => rdreq,
        wrreq => wrreq,
        empty => empty,
        full => full,
        q => DataPort,
        usedw => usedw
    );

    process(clock_r)
    begin
        if (rising_edge(clock_r)) then
            DataIn <= data_counter;
        end if;
    end process;

    process
    begin
        for i in 100 downto 0 loop
            data_counter <= data_counter + 1;
            skiptime(1320);
            wrreq <= '1';
            skiptime(1);
            wrreq <= '0';
        end loop;
    end process;
    -- GSMRegistr end

    clock_r <= not clock_r after 10 ns;
    clk <= clock_r;

    -- DataPort <= data_counter;

    -- process(rdreq)
    -- begin
    --     if (rising_edge(rdreq)) then
    --         if (data_counter = X"FFFF") then
    --             data_counter <= (others => '0');
    --         else
    --             data_counter <= data_counter + 1;
    --         end if;
    --     end if;
    -- end process;

    process
    begin
  nRst <= '0';

        CarrierFrequency <= X"010003FF";
        SymbolFrequency <= X"010003FF"; 
        
        SignalMode <= "11";

        skiptime(1000);

       
        Mode <= '1';

        skiptime(1000);



         ModulationMode <= "00";
         skiptime(10);
         nRst <= '1';

        skiptime(50000);

         nRst <= '0';
        ModulationMode <= "01";
        skiptime(10);
        nRst <= '1';
        skiptime(50000);

        nRst <= '0';
        ModulationMode <= "10";
       
          skiptime(10);
         nRst <= '1';
         skiptime(50000);
            
        skiptime(1000);

        stop;
    end process;

end architecture;
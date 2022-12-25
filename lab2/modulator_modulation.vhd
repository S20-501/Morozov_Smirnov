library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_signed.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- CONTROL

-- Mode — режим работы: 0 – обычный режим; 1 – режим PSK.
-- Modulation mode — «00» – QPSK; «01» – 8-PSK; «10» – 16-QAM; «11» – модуляция не используется.
-- Signal mode — «00» – гармонический сигнал; «01» – пилообразный сигнал; «10» – меандр; «11» – зарезервировано.
-- nRstDDS — сигнал сброса схемы прямого цифрового синтеза.
-- Sync — сигнал синхронизации, ‘1’ — разрешение использования внешней синхронизации для модуля организации пересылки данных средствами квадратурной модуляции.


-- 4.2.3.	АДРЕСА МОДУЛЯ ОРГАНИЗАЦИИ ПЕРЕСЫЛКИ ДАННЫХ СРЕДСТВАМИ КВАДРАТУРНОЙ МОДУЛЯЦИИ
-- Смещение	Размер, байт	Назначение	Описание
-- 0x0000	2	Amplitude	Амплитуда сигнала
-- 0x0002	2	Start Phase	Начальная фаза
-- 0x0004	4	Carrier Frequency	Частота несущей
-- 0x0008	4	Symbol Frequency	Частота следования символов
-- 0x000C	2	DataPort	Порт записи данных

entity modulator_modulation is
    port (
        clk   : in std_logic;
        nRst : in std_logic;
        -- Amplitude: out std_logic_vector(15 downto 0); -- FROM LUT
        -- StartPhase: out std_logic_vector(15 downto 0);
        -- CarrierFrequency: in std_logic_vector(31 downto 0); -- PASSTHROW
        -- SignalMode: out std_logic_vector; -- PASSTHROW
        -- nRstDDS  -- PASSTHROW

        SymbolFrequency: in std_logic_vector(31 downto 0);
        CodedData: in std_logic_vector(9 downto 0); -- 10 bits current data

        lut_address: out std_logic_vector(5 downto 0);

        ModulationMode: in std_logic_vector(1 downto 0);
        Mode: in std_logic; -- 0 - no modulation, 1 - modulation on

        -- Sync -- NOT USED

        ByteReadRequest: out std_logic;
        DDS_En: out std_logic
    );
end entity modulator_modulation;

architecture a_modulator_modulation of modulator_modulation is
    constant MODULATION_QPSK:          std_logic_vector(1 downto 0) := "00";
    constant MODULATION_8PSK:          std_logic_vector(1 downto 0) := "01";
    constant MODULATION_16QAM:         std_logic_vector(1 downto 0) := "10";
    constant MODULATION_RESERVED:      std_logic_vector(1 downto 0) := "11";
    

    signal Symbol_clock: std_logic; -- TODO: REMOVE
    signal SymbolAccumulator_counter: std_logic_vector(31 downto 0);

    signal data_r: std_logic_vector(13 downto 0); -- shift register, when 10 bits shifted, new major bits are set (4 bits always correct)
    signal shift_counter: std_logic_vector(2 downto 0); -- from 0 to 3 bits
    signal shifted_10bit_counter: std_logic_vector(3 downto 0); -- for renewing shift register with data


    signal need_shifted_r: std_logic_vector(2 downto 0);

    signal ByteReadRequest_r: std_logic;
    signal lut_address_r: std_logic_vector(5 downto 0);

    signal DDS_En_r: std_logic;

    signal CalibrationData_r: std_logic_vector(9 downto 0);
    signal CalibrationByte_counter: std_logic_vector(2 downto 0);
    signal CalibrationNeeded_r: std_logic;
    signal SessionModulation_r: std_logic_vector(1 downto 0);
    
begin
    DDS_En <= DDS_En_r;

    ByteReadRequest <= ByteReadRequest_r;
    lut_address <= lut_address_r;


    -- 1 3 0 2 2 1 0 3 2 3 -- QPSK
    -- 5 1 2 3 4 -- 8PSK
    -- 13 8 6 12 14 -- 16QAM

    with CalibrationByte_counter select CalibrationData_r <=
        B"1_010_001_101" when B"000",
        B"11_101_100_01" when B"001",
        B"1_010_001_101" when B"010",
        B"11_101_100_01" when B"011",
        B"1_010_001_101" when B"100",
        B"11_101_100_01" when B"101",
            (others => '0')  when others;
    

    Symbol_accumulator: process (clk, nRst)
    begin
        if nRst = '0' then
            SymbolAccumulator_counter <= (others => '0'); 
            DDS_En_r <= '0';
        elsif rising_edge(clk) then
            DDS_En_r <= '1';
            Symbol_clock <= SymbolAccumulator_counter(31);

            -- TODO: simplify it
            if (SymbolAccumulator_counter(31) = '1') then
                SymbolAccumulator_counter <= '0' & (SymbolAccumulator_counter(30 downto 0) + SymbolFrequency(30 downto 0));
            else
                SymbolAccumulator_counter <= SymbolAccumulator_counter + SymbolFrequency;
            end if;
        end if;
    end process;


    shift_p: process (clk, nRst)
    begin
        if nRst = '0' then
            data_r <= (others => '0');
            shift_counter <= (others => '0') ;
            shifted_10bit_counter <= (others => '0'); 

            ByteReadRequest_r <= '0';
            SessionModulation_r <= (others => '0');
            CalibrationNeeded_r <= '1'; -- need to calibrate before use
            CalibrationByte_counter <= (others => '0') ;
        elsif rising_edge(clk) then
            if (shifted_10bit_counter = 0) then -- when data is loading 
                -- I need to start calibration after modulation mode change (on reset only)
                -- It will be 6x10 bit words, because 60 is least common multiple of 2, 3, 4, 10

                if (CalibrationNeeded_r = '1') then
                    if (CalibrationByte_counter = B"000") then
                        SessionModulation_r <= ModulationMode;
                    elsif (CalibrationByte_counter = B"101") then
                        CalibrationNeeded_r <= '0';
                    end if;

                    CalibrationByte_counter <= CalibrationByte_counter + 1;
                    data_r(data_r'high downto data_r'high - 9) <= CalibrationData_r;
                else
                    data_r(data_r'high downto data_r'high - 9) <= CodedData(9 downto 0);
                    ByteReadRequest_r <= '1';
                end if;

                shifted_10bit_counter <= CONV_STD_LOGIC_VECTOR(10, shifted_10bit_counter'length);
            elsif (shift_counter > 0) then
                shift_counter <= shift_counter - 1;
                shifted_10bit_counter <= shifted_10bit_counter - 1;

                data_r <= '0' & data_r(data_r'high downto data_r'low + 1);
                
                ByteReadRequest_r <= '0';

                -- TODO: write shifted bit to ring buffer!
                -- or write current data to it
                -- sr_out <= data_r(data_r'low);
            else
                shift_counter <= need_shifted_r;
                ByteReadRequest_r <= '0';
            end if;
        end if;
    end process;

    Symbol_new: process(clk, nRst)
    begin
        if nRst = '0' then
            lut_address_r <= (others => '0');

            need_shifted_r <= CONV_STD_LOGIC_VECTOR(4, need_shifted_r'length);  -- need perform initial shift for filling buffer
        elsif rising_edge(clk) then
            if (Mode = '1' and SymbolAccumulator_counter(31) = '1') then -- modulation and new symbol arrived
                if (SessionModulation_r = MODULATION_QPSK) then
                    -- 0000 00 - 0000 11
                    lut_address_r(5 downto 2) <= B"0000";
                    lut_address_r(1 downto 0) <= data_r(1 downto 0);

                    need_shifted_r <= CONV_STD_LOGIC_VECTOR(2, need_shifted_r'length);
                elsif (SessionModulation_r = MODULATION_8PSK) then
                    -- 010 000 - 010 111
                    lut_address_r(5 downto 3) <= B"010";
                    lut_address_r(2 downto 0) <= data_r(2 downto 0);

                    need_shifted_r <= CONV_STD_LOGIC_VECTOR(3, need_shifted_r'length);
                elsif (SessionModulation_r = MODULATION_16QAM) then
                    -- 10 0000 - 10 1111
                    lut_address_r(5 downto 4) <= B"10";
                    lut_address_r(3 downto 0) <= data_r(3 downto 0);

                    need_shifted_r <= CONV_STD_LOGIC_VECTOR(4, need_shifted_r'length);
                end if;
            else
                need_shifted_r <= CONV_STD_LOGIC_VECTOR(0, need_shifted_r'length);
            end if;
        end if;
    end process;
end architecture;
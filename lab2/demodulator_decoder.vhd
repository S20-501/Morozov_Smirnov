library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_signed.all;

	


entity demodulator_decoder is
	port(CLK : in std_logic :='0';
	reset : in std_logic :='0';
	IData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
	QData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
	DataValid : in std_logic :='0';
	BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
	DataStrobe : out std_logic :='0');
end demodulator_decoder;

architecture test_demodulator_decoder of demodulator_decoder is

constant  border_0_const : integer:=0;
constant  border_1_const : integer:=255;
constant  border_2_const : integer:=-255;
constant  border_3_const : integer:=-180;
constant  border_4_const : integer:=180;
constant  if_modulation_0_const : unsigned :=b"00";
constant  if_modulation_1_const : unsigned :=b"01";
constant  if_modulation_2_const : unsigned :=b"10";
constant  if_modulation_3_const : unsigned :=b"11";
constant  limit_sensivity_differencial_const : integer:=5;
constant limit_time_useful_information_QPSK : unsigned(3 downto 0):=(others => '0');
constant limit_time_useful_information_8PSK : unsigned(3 downto 0):=(others => '0');
constant limit_time_useful_information_16QAM : unsigned(3 downto 0):=(others => '0');

signal delta_I_Data_In_r : signed(9 downto 0):=(others => '0');
signal delta_Q_Data_In_r : signed(9 downto 0):=(others => '0');
signal differencial_I_Data_In_r : signed(13 downto 0):=(others => '0');
signal differencial_Q_Data_In_r : signed(13 downto 0):=(others => '0'); 
signal modulation_r :unsigned(1 downto 0) :=(others => '1');
signal information_r :STD_LOGIC_VECTOR(3 downto 0) :=(others => '0');
signal	delay_IData_In_r : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal	delay_QData_In_r : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal	delay_r : unsigned(3 downto 0):=(others => '0');
signal	count_delay_r : unsigned(3 downto 0):=(others => '0');


function division_lut(y: in unsigned(3 downto 0))
return signed is
variable inverted_y_r: signed(3 downto 0);
constant C_NY       : integer:= 4;
constant C_NDY      : integer:= 8;
type t_divition_lut is array (0 to 2**C_NY-1) of integer range 0 to 2**C_NDY-1;
constant C_DIV_LUT  : t_divition_lut := (511, 255, 127, 84, 63, 50, 42, 36, 31, 27, 25, 22, 20, 19, 17, 16);
variable invert_y_r : signed(7 downto 0) :=(others => '0');
begin
	invert_y_r := signed( conv_unsigned(C_DIV_LUT( conv_integer(unsigned(y))),C_NDY));
	inverted_y_r:= invert_y_r(7 downto 4);
	return inverted_y_r;
end;


function demodulator_QPSK(IData_In:in STD_LOGIC_VECTOR(9 downto 0);QData_In:in STD_LOGIC_VECTOR(9 downto 0))
	return std_logic_vector is
	variable information : std_logic_vector(1 downto 0);
begin
	if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then
		if (signed(IData_In)>conv_signed(border_0_const,IData_In'LENGTH)) then
			information := "11";
		elsif (signed(IData_In)<conv_signed(border_0_const,IData_In'LENGTH)) then 
			information := "01";
		end if;
	elsif( signed(QData_In)<conv_signed(border_0_const,QData_In'LENGTH)) then
		if (signed(IData_In)>conv_signed(border_0_const,IData_In'LENGTH)) then
			information_r := "10";
		elsif (signed(IData_In)<conv_signed(border_0_const,IData_In'LENGTH)) then 
			information := "00";
		end if;
	else
		information := "00";
	end if;
	return information;
end;

function demodulator_8PSK(IData_In:in STD_LOGIC_VECTOR(9 downto 0);QData_In:in STD_LOGIC_VECTOR(9 downto 0))
	return std_logic_vector is
	variable information : std_logic_vector(2 downto 0);
	begin
		if (signed(IData_In) > conv_signed(border_3_const,IData_In'LENGTH)) then
			if (signed(IData_In) < conv_signed(border_4_const,IData_In'LENGTH)) then
				if (signed(QData_In) > conv_signed(border_4_const,QData_In'LENGTH)) then	
						information := "111";
				elsif (signed(QData_In) < conv_signed(border_3_const,QData_In'LENGTH)) then
						information := "001";
				end if;
			end if;
		elsif (signed(IData_In) > conv_signed(border_4_const,IData_In'LENGTH)) then
			if (signed(QData_In) > conv_signed(border_4_const,QData_In'LENGTH)) then
				information := "110";
			elsif (signed(QData_In) < conv_signed(border_3_const,QData_In'LENGTH)) then
				information := "011";
			end if;

		elsif (signed(IData_In) < conv_signed(border_3_const,IData_In'LENGTH)) then
			if (signed(QData_In) < conv_signed(border_3_const,QData_In'LENGTH)) then
				information_r := "000";
			elsif (signed(QData_In) < conv_signed(border_4_const,QData_In'LENGTH)) then
				information := "101";
			end if;
		elsif (signed(QData_In) > conv_signed(border_3_const,QData_In'LENGTH)) then
			if (signed(QData_In) < conv_signed(border_4_const,QData_In'LENGTH)) then
				if (signed(IData_In) > conv_signed(border_4_const,IData_In'LENGTH)) then	
						information := "010";
				elsif (signed(IData_In) < conv_signed(border_3_const,IData_In'LENGTH)) then
						information := "100";
				end if;
			end if;
		end if;
	return information;
	end;
	
function demodulator_16QAM(IData_In:in STD_LOGIC_VECTOR(9 downto 0);QData_In:in STD_LOGIC_VECTOR(9 downto 0))
	return std_logic_vector is
	variable informatio : std_logic_vector(3 downto 0);
begin
	if (signed(IData_In) > conv_signed(border_0_const,IData_In'LENGTH)) then
		if (signed(IData_In) < conv_signed(border_1_const,IData_In'LENGTH)) then
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := "0000";
				else
					information := "0001";
				end if;
			else	
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
						information := "0010";
				else
					information := "0011";
				end if;
			end if;
		else
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := "0100";
				else
					information := "0101";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
					information := "0110";
				else
					information := "0111";
				end if;
			end if;
		end if;
	else
		if (signed(IData_In) > conv_signed(border_2_const,IData_In'LENGTH)) then
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := "1000";
				else
					information := "1001";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
					information := "1010";
				else
					information := "1011";
				end if;
			end if;
		else
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := "1100";
				else
					information := "1101";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
					information := "1110";
				else
					information := "1111";
				end if;
			end if;
		end if;
	end if;
return information;
end;

begin
main: process(CLK, reset)
	begin
		if reset='1' then
				modulation_r <= (others => '1');
				information_r <= (others => '0');
				delay_IData_In_r <=(others => '0');
				delay_QData_In_r <=(others => '0');
				delay_r <= (others => '0');
				count_delay_r <= (others => '0');
		elsif rising_edge(CLK) then
			delta_I_Data_In_r <=abs(signed(IData_In)-signed(delay_IData_In_r));		
			delta_Q_Data_In_r <=abs(signed(QData_In)-signed(delay_QData_In_r));
			differencial_I_Data_In_r <= delta_I_Data_In_r * division_lut(count_delay_r);
			differencial_Q_Data_In_r <= delta_Q_Data_In_r * division_lut(count_delay_r);
			
			if( differencial_I_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
				if( differencial_Q_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
					if(count_delay_r + 1 < delay_r) then
						delay_r <= count_delay_r;
					end if;
				end if;
			end if;
			
			
			if( differencial_I_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
				if( differencial_Q_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
					if(count_delay_r > delay_r) then
						count_delay_r<=(others => '0');
					end if;
				end if;
			else
				count_delay_r<=count_delay_r + 1;
			end if;
			
			if( differencial_I_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
				if( differencial_Q_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
					delay_IData_In_r <= IData_In;
				end if;
			end if;
			
			if( differencial_I_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
				if( differencial_Q_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
					delay_QData_In_r <= QData_In;
				end if;
			end if;
			
			if( differencial_I_Data_In_r >conv_signed(limit_sensivity_differencial_const,3)) then
				if( differencial_Q_Data_In_r >conv_signed(9,3)) then
					if (delay <= limit_time_useful_information_QPSK)
						modulation_r= if_modulation_0_const;
					elsif (delay >= limit_time_useful_information_16QAM)
						modulation_r= if_modulation_2_const;
					else
						modulation_r= if_modulation_1_const;
					end if;
				end if;
			end if;
			
		end if;
		if modulation_r= if_modulation_0_const then
			DataStrobe <='1';
		elsif modulation_r=if_modulation_1_const then
			DataStrobe <='1';
		elsif modulation_r=if_modulation_2_const then
			DataStrobe <='1';
		elsif modulation_r=if_modulation_0_const then 
			DataStrobe <='0';
		end if;
		
		if modulation_r= if_modulation_0_const then
			information_r(1 downto 0)<=demodulator_QPSK(IData_In,QData_In);
		elsif modulation_r=if_modulation_1_const then
			information_r(2 downto 0)<=demodulator_8PSK(IData_In,QData_In);
		elsif modulation_r=if_modulation_2_const then	
			information_r<=demodulator_16QAM(IData_In,QData_In);
		elsif modulation_r=if_modulation_0_const then 
			information_r<=(others => '0');
		end if;
		
		if modulation_r= if_modulation_0_const then
			--BufDataOut<=decoder(information_r(1 downto 0));
		elsif modulation_r=if_modulation_1_const then
			--BufDataOut<=decoder(information_r(2 downto 0));
		elsif modulation_r=if_modulation_2_const then	
			--BufDataOut<=decoder(information_r);
		elsif modulation_r=if_modulation_0_const then 
			BufDataOut<= (others => '0');
		end if;	
	end process;
end;
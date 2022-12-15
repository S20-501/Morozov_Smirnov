library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;	
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_signed.all;


entity demodulator_decoder is
	port(clk : in std_logic :='0';
	nRst : in std_logic :='0';
	IData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
	QData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
	DataValid : in std_logic :='0';
	BufDataOut:out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
	DataStrobe : out std_logic :='0'
	--modul : out unsigned(1 downto 0) :=(others => '1')
	);
end entity demodulator_decoder;

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
constant  limit_sensivity_differencial_const : integer:=1;
constant mean_testing_time : unsigned(11 downto 0):="100100010001";
constant number_of_bytes_const : integer:= 10;

signal delta_I_Data_In_r : signed(9 downto 0):=(others => '0');
signal delta_Q_Data_In_r : signed(9 downto 0):=(others => '0');
signal differencial_I_Data_In_muchbites_r : signed(19 downto 0):=(others => '0');
signal differencial_Q_Data_In_muchbites_r : signed(19 downto 0):=(others => '0');
signal differencial_I_Data_In_r : signed(9 downto 0):=(others => '0');
signal differencial_Q_Data_In_r : signed(9 downto 0):=(others => '0');  
signal modulation_r :unsigned(1 downto 0) :=(others => '1');
signal information_r :STD_LOGIC_VECTOR(3 downto 0) :=(others => '0');
signal	delay_IData_In_r : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal	delay_QData_In_r : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal	delay_r : unsigned(3 downto 0):=(others => '0');
signal	count_delay_r : unsigned(3 downto 0):=(others => '0');
signal	count_testing_time_r : unsigned(11 downto 0):=(others => '0');
signal	count_time_r : unsigned(3 downto 0):=(others => '0');
signal	amplitude_r : unsigned(19 downto 0):=(others => '0');
signal corner_r: signed(19 downto 0):=(others => '0');
type t_amplitude_lut is array (0 to 8) of unsigned(19 downto 0);
signal amplitude_lut : t_amplitude_lut;
type t_corner_lut is array (0 to 8) of signed(9 downto 0);
signal corner_lut : t_corner_lut;

function division_lut(y: in integer)
return integer is
variable inverted_y_r: integer;
constant C_NY2      : integer:= 10;
constant C_NDY2      : integer:= 10;
type t_divition_lut2 is array (0 to 2**C_NY2-1) of integer range 0 to 2**C_NDY2-1;
variable C_DIV_LUT2  : t_divition_lut2;
begin
		divition_lut2_write_loop : for i in 0 to 1023 loop
			C_DIV_LUT2(i):=conv_integer(1023/(i+1));
		end loop divition_lut2_write_loop;
		inverted_y_r := C_DIV_LUT2 (y-1);
		return inverted_y_r;
end;

function modulation_identification (amplitude_lut :in t_amplitude_lut; corner_lut : in t_corner_lut)
	return unsigned is
	variable modulation :unsigned(1 downto 0) :=(others => '1');
	variable amplitude :unsigned(19 downto 0);
	variable identification_change_amplitude : integer := 0;
	variable identification_coincidences_corner : integer := 0;
	variable number_corners: integer := 1;
	type t_corner_identification_change_lut is array (0 to 8) of signed(9 downto 0);
   variable corner_identification_change_lut : t_corner_identification_change_lut;
begin
	amplitude := amplitude_lut(0);
	amplitude_lut_loop :  for i in 1 to 8 loop
		if(amplitude /= amplitude_lut(1)) then
			identification_change_amplitude := 1;
		end if;	
	end loop amplitude_lut_loop;
	if(identification_change_amplitude = 1) then
		modulation := "10";
	else
		corner_identification_change_lut(0):=corner_lut(0);
		corner_lut_loop1 :  for j in 1 to 8 loop
			corner_lut_loop2 :  for k in 1 to 8 loop
				if(k < number_corners-1) then
					if(corner_identification_change_lut(k) = corner_lut(j)) then
						identification_coincidences_corner := 1;
					end if;
					if(identification_coincidences_corner = 0) then
						number_corners:=number_corners + 1;
						corner_identification_change_lut(number_corners):=corner_lut(j);
					end if;
				end if;
			end loop corner_lut_loop2;
		end loop corner_lut_loop1;
		if(number_corners < 5) then
			modulation := "00";
		elsif(number_corners > 4) then
			modulation := "01";
		end if;	
	end if;
	return modulation;
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
			information := "10";
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
				information := "000";
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
	variable information : std_logic_vector(3 downto 0);
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
main: process(clk, nRst)
	begin
		if nRst='1' then
			delta_I_Data_In_r <=(others => '0');
			delta_Q_Data_In_r <=(others => '0');
			differencial_I_Data_In_r <=(others => '0');
			differencial_Q_Data_In_r <=(others => '0'); 
			modulation_r <=(others => '1');
			information_r <=(others => '0');
			delay_IData_In_r <=(others => '0');
			delay_QData_In_r <=(others => '0');
			delay_r <=(others => '0');
			count_delay_r <=(others => '0');
		elsif rising_edge(clk) then
			if(count_testing_time_r < mean_testing_time) then
				delta_I_Data_In_r <=abs(signed(IData_In)-signed(delay_IData_In_r));		
				delta_Q_Data_In_r <=abs(signed(QData_In)-signed(delay_QData_In_r));
				differencial_I_Data_In_muchbites_r <= delta_I_Data_In_r * conv_signed(division_lut(conv_integer(count_delay_r)),number_of_bytes_const);
				differencial_Q_Data_In_muchbites_r <= delta_Q_Data_In_r * conv_signed(division_lut(conv_integer(count_delay_r)),number_of_bytes_const);
				differencial_I_Data_In_r <= differencial_I_Data_In_muchbites_r(differencial_I_Data_In_muchbites_r'LENGTH-1 downto number_of_bytes_const);
				differencial_Q_Data_In_r <= differencial_Q_Data_In_muchbites_r(differencial_Q_Data_In_muchbites_r'LENGTH-1 downto number_of_bytes_const);
				count_testing_time_r<=count_testing_time_r + 1;
				
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
				
				amplitude_r<= unsigned(IData_In)* unsigned(IData_In) + unsigned(QData_In)*unsigned(QData_In);
				corner_r<=signed(QData_In)*conv_signed(division_lut(conv_integer(signed(IData_In))),number_of_bytes_const);
				corner_lut(conv_integer(count_testing_time_r))<= corner_r(corner_r'LENGTH-1 downto number_of_bytes_const);
				amplitude_lut(conv_integer(count_testing_time_r))<= amplitude_r;
			else
				if(count_time_r < delay_r) then
					count_time_r<=count_time_r+1;
				else
					count_time_r<=(others => '0');
					modulation_r<=modulation_identification(amplitude_lut,corner_lut);
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
			end if;		
		end if;		
	end if;
	end process;
end architecture;

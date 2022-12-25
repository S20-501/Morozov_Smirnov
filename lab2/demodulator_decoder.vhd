library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;	
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.all;



entity demodulator_decoder is
	port(clk : in std_logic :='0';
	nRst : in std_logic :='0';
	IData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
	QData_In :in STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
	DataValid : in std_logic :='0';
	DataStrobe : out std_logic :='0';

	address_in_division_lut		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0):=(others => '0');
	clock		: OUT STD_LOGIC  := '1';
    division_number		: in STD_LOGIC_VECTOR (8 DOWNTO 0):=(others => '0');
	modulation_mode :OUT unsigned(1 downto 0) :=(others => '1');
	useful_information :OUT STD_LOGIC_VECTOR(3 downto 0) :=(others => '0')
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
constant  limit_sensivity_differencial_const : integer:=100;
constant mean_testing_time_const : integer:= 1920;
constant number_of_bytes_const : integer:= 10;
constant time_not_react_const: integer:=7;



signal time_not_react_r: unsigned(9 downto 0):=(others => '0');
signal differencial_I_Data_In_r : integer:=0;
signal differencial_Q_Data_In_r : integer:=0; 
signal	delay_IData_In_r : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal	delay_QData_In_r : STD_LOGIC_VECTOR(9 downto 0):=(others => '0');
signal	delay_r : unsigned(9 downto 0):=(others => '1');
signal	count_delay_r : unsigned(9 downto 0):=(others => '0');
signal	count_testing_time_r : unsigned(10 downto 0):=(others => '0');
signal	count_time_r : unsigned(9 downto 0):=(others => '0');
signal	amplitude_r : signed(19 downto 0):=(others => '0');
signal corner_r: signed(19 downto 0):=(others => '0');
type t_amplitude_lut is array (0 to 30) of unsigned(19 downto 0);
signal amplitude_lut : t_amplitude_lut:=(others => (others => '0'));
type t_corner_lut is array (0 to 30) of signed(19 downto 0);
signal corner_lut : t_corner_lut:=(others => (others => '0'));
signal  indicator_revolt_differencial : integer:= 0;
signal  indicator_out : integer:= 0;
signal in_luts: integer:=0;

function modulation_identification (amplitude_lut :in t_amplitude_lut; corner_lut : in t_corner_lut; in_lut:in integer)
	return unsigned is
	variable modulation :unsigned(1 downto 0) :=(others => '1');
	variable amplitude :unsigned(19 downto 0);
	variable identification_change_amplitude : integer := 0;
	variable identification_coincidences_corner : integer := 0;
	variable number_corners: integer := 1;
	variable inaccuracy_amplitude: integer := 20000;
	variable inaccuracy_corner: integer := 600;
	type t_corner_identification_change_lut is array (0 to 30) of signed(19 downto 0);
	variable corner_identification_change_lut : t_corner_identification_change_lut:=(others => (others => '0'));
   
begin
	amplitude := amplitude_lut(0);
	amplitude_lut_loop :  for i in 1 to 30 loop
		if(i <= in_lut-1) then
			if(amplitude-conv_unsigned(inaccuracy_amplitude,19) > amplitude_lut(i) or amplitude_lut(i) > amplitude+conv_unsigned(inaccuracy_amplitude,19)) then
					identification_change_amplitude := 1;
			end if;
	end if;
	end loop amplitude_lut_loop;
	if(identification_change_amplitude = 1) then
		modulation := "10";
	else
		corner_identification_change_lut(0):=corner_lut(0);
		corner_lut_loop1 :  for j in 1 to 30 loop
			if(j <= in_lut-1) then
				corner_lut_loop2 :  for k in 0 to 30 loop
					if(k <= number_corners-1) then
						if(corner_identification_change_lut(k) < corner_lut(j)+conv_unsigned(inaccuracy_corner,19) and corner_identification_change_lut(k) > corner_lut(j)-conv_unsigned(inaccuracy_corner,19)) then
							identification_coincidences_corner := 1;
						end if;
					end if;
				end loop corner_lut_loop2;
				if(identification_coincidences_corner = 0) then
					number_corners:=number_corners + 1;
					corner_identification_change_lut(number_corners-1):=corner_lut(j);
				end if;
			end if;
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
			information := b"11";
		elsif (signed(IData_In)<conv_signed(border_0_const,IData_In'LENGTH)) then 
			information := b"01";
		end if;
	elsif( signed(QData_In)<conv_signed(border_0_const,QData_In'LENGTH)) then
		if (signed(IData_In)>conv_signed(border_0_const,IData_In'LENGTH)) then
			information :=b"10";
		elsif (signed(IData_In)<conv_signed(border_0_const,IData_In'LENGTH)) then 
			information := b"00";
		end if;
	else
		information := b"00";
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
						information := b"111";
				elsif (signed(QData_In) < conv_signed(border_3_const,QData_In'LENGTH)) then
						information := b"001";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_4_const,QData_In'LENGTH)) then
					information := b"110";
				elsif (signed(QData_In) < conv_signed(border_3_const,QData_In'LENGTH)) then
					information := b"011";
				else
					information := b"010";
				end if;
			end if;
		else
			if (signed(QData_In) < conv_signed(border_4_const,QData_In'LENGTH)) then
				information := b"101";
			elsif (signed(QData_In) < conv_signed(border_3_const,QData_In'LENGTH)) then
				information := b"000";
			else
				information := b"100";
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
					information := b"0000";
				else
					information := b"0001";
				end if;
			else	
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
						information := b"0010";
				else
					information := b"0011";
				end if;
			end if;
		else
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := b"0100";
				else
					information := b"0101";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
					information := b"0110";
				else
					information := b"0111";
				end if;
			end if;
		end if;
	else
		if (signed(IData_In) > conv_signed(border_2_const,IData_In'LENGTH)) then
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := b"1000";
				else
					information := b"1001";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
					information := b"1010";
				else
					information := b"1011";
				end if;
			end if;
		else
			if (signed(QData_In) > conv_signed(border_0_const,QData_In'LENGTH)) then	
				if (signed(QData_In) < conv_signed(border_1_const,QData_In'LENGTH)) then
					information := b"1100";
				else
					information := b"1101";
				end if;
			else
				if (signed(QData_In) > conv_signed(border_2_const,QData_In'LENGTH)) then
					information := b"1110";
				else
					information := b"1111";
				end if;
			end if;
		end if;
	end if;
return information;
end;
begin
main: 
process(clk, nRst)
	begin
		if nRst='0' then
			time_not_react_r <=(others => '0');
			differencial_I_Data_In_r <=0;
			differencial_Q_Data_In_r <=0;
			delay_IData_In_r <=(others => '0');
			delay_QData_In_r <=(others => '0');
			delay_r <=(others => '1');
			count_delay_r <=(others => '0');
			count_testing_time_r <=(others => '0');
			count_time_r <=(others => '0');
			amplitude_r <=(others => '0');
			corner_r <=(others => '0');
			amplitude_lut <=(others => (others => '0'));
			corner_lut <=(others => (others => '0'));
			indicator_revolt_differencial <= 0;
			indicator_out <= 0;
			in_luts <= 0;

		elsif rising_edge(clk) then
				if(time_not_react_r < conv_unsigned(time_not_react_const,time_not_react_r'length)) then
					time_not_react_r<=time_not_react_r+1;	
				else
					 if(time_not_react_r<=conv_unsigned(time_not_react_const,time_not_react_r'length)) then
					 	delay_IData_In_r <= IData_In;
					 	delay_QData_In_r <= QData_In;
					 	time_not_react_r<=time_not_react_r+1;
					else
						differencial_I_Data_In_r<=conv_integer(signed(delay_IData_In_r))-conv_integer(signed(IData_In));
						differencial_Q_Data_In_r<=conv_integer(signed(delay_QData_In_r))-conv_integer(signed(QData_In));
						amplitude_r<= signed(IData_In)* signed(IData_In) + signed(QData_In)*signed(QData_In);
						address_in_division_lut<= IData_In(IData_In'length-2 downto 0);
						corner_r<=signed(QData_In)*signed(IData_In(0)&division_number);
						if( abs(differencial_I_Data_In_r) >limit_sensivity_differencial_const or abs(differencial_Q_Data_In_r) >limit_sensivity_differencial_const) then
							indicator_revolt_differencial<=1;
						else		
							if(indicator_revolt_differencial=1) then
								indicator_revolt_differencial<=0;
								
								if(delay_r>count_delay_r) then
									delay_r<=count_delay_r;
								end if;
									count_delay_r <= (others => '0');
								if(count_testing_time_r <= conv_unsigned(mean_testing_time_const, count_testing_time_r'length)) then
									corner_lut(in_luts)<= corner_r;
									amplitude_lut(in_luts)<= unsigned(amplitude_r);
									in_luts<=in_luts+1;
									
								 else
									indicator_out <= 1;
								 	if modulation_mode= if_modulation_0_const then
										useful_information(1 downto 0)<=demodulator_QPSK(IData_In,QData_In);
								 	elsif modulation_mode=if_modulation_1_const then
								 		useful_information(2 downto 0)<=demodulator_8PSK(IData_In,QData_In);
								 	elsif modulation_mode=if_modulation_2_const then	
								 		useful_information<=demodulator_16QAM(IData_In,QData_In);
								 	elsif modulation_mode=if_modulation_3_const then 
								 		useful_information<=(others => '0');
									end if;	
								end if;
							else
								indicator_out <= 0;
								count_delay_r<=count_delay_r + 1;
							end if;
						end if;	
							delay_IData_In_r <= IData_In;
							delay_QData_In_r <= QData_In;
					end if;
			end if;
			if(count_testing_time_r < conv_unsigned(mean_testing_time_const, count_testing_time_r'length)) then
				count_testing_time_r<=count_testing_time_r + 1;
				
			elsif(count_testing_time_r = conv_unsigned(mean_testing_time_const, count_testing_time_r'length)) then
				modulation_mode<=modulation_identification(amplitude_lut,corner_lut,in_luts);
					if modulation_mode= if_modulation_0_const then
						DataStrobe <='1';
					elsif modulation_mode=if_modulation_1_const then
						DataStrobe <='1';
					elsif modulation_mode=if_modulation_2_const then
						DataStrobe <='1';
					elsif modulation_mode=if_modulation_0_const then 
						DataStrobe <='0';
					end if;
					count_testing_time_r<=count_testing_time_r + 1;
			end if;		
		end if;		
	end process;
end architecture;
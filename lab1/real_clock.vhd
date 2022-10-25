library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity clock is
	port(CLK : in STD_LOGIC;
	reset : in std_logic :='0';
	add_min_e:in std_logic :='0';
	add_hrs_e:in std_logic :='0';
	add_min_d:in std_logic :='0';
	add_hrs_d:in std_logic :='0';
	Led : out unsigned(4 downto 0):=(others => '0');
	CH_Led: out STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
	out_7seg : out STD_LOGIC_VECTOR(7 downto 0):=(others => '0'));
end clock;

architecture test_clock of clock is
	signal count : unsigned(15 downto 0) :=(others => '0');
	signal min_e : unsigned(3 downto 0) :=(others => '0');
	signal min_d : unsigned(3 downto 0) :=(others => '0');
	signal hrs_e : unsigned(3 downto 0) :=(others => '0');
	signal hrs_d : unsigned(3 downto 0) :=(others => '0');

function dec_7seg(num : in unsigned(3 downto 0))
	return std_logic_vector is
	variable seg7 : std_logic_vector(6 downto 0);
   begin
	   if num = X"0" then seg7 := b"1000000";
	elsif num = X"1" then seg7 := b"1111001";
	elsif num = X"2" then seg7 := b"0100100";
	elsif num = X"3" then seg7 := b"0110000";
	elsif num = X"4" then seg7 := b"0011001";
	elsif num = X"5" then seg7 := b"0010010";
	elsif num = X"6" then seg7 := b"0000010";
	elsif num = X"7" then seg7 := b"1111000";
	elsif num = X"8" then seg7 := b"0000000";
	elsif num = X"9" then seg7 := b"0010000";
	else             seg7 := (others => '1');
	end if;
	return std_logic_vector(seg7);
	end;
begin

	main: process(CLK)
	begin
			if reset='1' then
				count <= (others => '0');
				hrs_e <= (others => '0');
				hrs_d <= (others => '0');
				min_e <= (others => '0');
				min_d <= (others => '0');
		elsif rising_edge(CLK) then
			if add_min_e='1' then
				if min_e=9 then
					min_e <= x"0";
				else
					min_e <= min_e + 1;
				end if;
			elsif add_min_d='1' then
				if min_d=5 then
					min_d <= x"0";
				else
					min_d <= min_d + 1;
				end if;
			elsif add_hrs_e='1' then
						if hrs_d<2 then
							if hrs_e = 9 then
								hrs_e <= x"0";
							else
								hrs_e <= hrs_e + 1;
							end if;
						elsif hrs_d=2 then 
							if hrs_e = 3 then
								hrs_e <= x"0";
							else
								hrs_e <= hrs_e + 1;
							end if;
						end if;
			elsif add_hrs_d='1' then
						if hrs_e>3 then
							if hrs_d = 1 then
								hrs_d <= x"0";
							else
								hrs_d <= hrs_d + 1;
							end if;
						elsif hrs_e<4 then 
							if hrs_d = 2 then
								hrs_d <= x"0";
							else
								hrs_d <= hrs_d + 1;
							end if;
						end if;
			elsif count=to_unsigned(1, 1) then
				count <= (others => '0');
				if min_e=9 then
					min_e <= x"0";
					if min_d = 5 then
						min_d <= x"0";
						if hrs_d<2 then
							if hrs_e = 9 then
								hrs_e <= x"0";
								hrs_d <= hrs_d + 1;
							else
								hrs_e <= hrs_e + 1;
								end if;
						elsif hrs_d=2 then 
								if hrs_e = 3 then
								hrs_e <= x"0";
								hrs_d <= x"0";
								else
								hrs_e <= hrs_e + 1;
								end if;
						end if;
					else
						min_d <= min_d + 1;
					end if;
				else
					min_e <= min_e + 1;
				end if;
			else
				count <= count + 1;
			end if;
			case to_integer(count(10 downto 9)) is
				when 0 => CH_Led <= b"1000"; out_7seg <= ('1' & dec_7seg(min_e));
				when 1 => CH_Led <= b"0100"; out_7seg <= ('1' & dec_7seg(min_d));
				when 2 => CH_Led <= b"0010"; out_7seg <= (count(15) & dec_7seg(hrs_e));
				when 3 => CH_Led <= b"0001"; out_7seg <= ('1' & dec_7seg(hrs_d));
			   when others => CH_Led <= b"0000"; out_7seg <= (others => '1');
			end case;
		end if;
	end process;
	
	Led <= count(15 downto 11);
end test_clock;	

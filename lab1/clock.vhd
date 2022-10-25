library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity clock is
	port(CLK : in STD_LOGIC;
	reset : in std_logic :='0';
	add_minute_units:in std_logic :='0';
	add_hours_units:in std_logic :='0';
	add_minute_tens:in std_logic :='0';
	add_hours_tens:in std_logic :='0';
	Led : out unsigned(4 downto 0):=(others => '0');
	out_7seg_minute_units : out STD_LOGIC_VECTOR(7 downto 0):=(others => '0');
	out_7seg_minute_tens : out STD_LOGIC_VECTOR(7 downto 0):=(others => '0');
	out_7seg_hours_tens : out STD_LOGIC_VECTOR(7 downto 0):=(others => '0');
	out_7seg_hours_units : out STD_LOGIC_VECTOR(7 downto 0):=(others => '0'));
end clock;

architecture test_clock of clock is
	signal hours_tens : unsigned(3 downto 0) :=(others => '0');
	signal hours_units : unsigned(3 downto 0) :=(others => '0');
	signal minute_tens : unsigned(3 downto 0) :=(others => '0');
	signal minute_units : unsigned(3 downto 0) :=(others => '0');
	signal count : unsigned(11 downto 0) :=(others => '0');
	signal add_count : unsigned(5 downto 0) :=(others => '0');
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

	main: process(CLK, reset)
	begin
			
			if reset='1' then
				hours_tens <= (others => '0');
				hours_units <= (others => '0');
				minute_tens <= (others => '0');
				minute_units <= (others => '0');
				count <= (others => '0');
				add_count <= (others => '0');
			elsif rising_edge(CLK) then
				if add_hours_tens='1' then
					if add_count=to_unsigned(49, 6) then
						if hours_tens=2 then
							hours_tens <= x"0";
						else
							hours_tens <= hours_tens + 1;
						end if;
					end if;
				elsif count=to_unsigned(2999, 12) and add_hours_units='0' and add_minute_units='0' and add_minute_tens='0' then
					if minute_units=9 then
						if minute_tens=5 then
							if hours_tens<2 then
								if hours_units=9 then
									hours_tens <= hours_tens + 1;
								end if;
							end if;
							if hours_tens=2 then
								if hours_units=3 then
									hours_tens <= x"0";
								end if;
							end if;
						end if;
					end if;
				end if;
			
				if add_hours_units='1'  then
					if add_count=to_unsigned(49, 6) then
						if hours_tens<2 then
							if hours_units = 9 then
								hours_units <= x"0";
							else
								hours_units <= hours_units + 1;
							end if;
						elsif hours_tens=2 then 
							if hours_units = 3 then
								hours_units <= x"0";
							else
								hours_units <= hours_units + 1;
							end if;
						end if;
					end if;
				elsif count=to_unsigned(2999, 12) and add_hours_tens='0' and add_minute_units='0' and add_minute_tens='0' then
					if minute_units=9 then
						if minute_tens=5 then
							if hours_tens<2 then
								if hours_units = 9 then
									hours_units <= x"0";
								else
									hours_units <= hours_units + 1;
								end if;
							elsif hours_tens=2 then 
								if hours_units = 3 then
									hours_units <= x"0";
								else
									hours_units <= hours_units + 1;
								end if;
							end if;
						end if;
					end if;
				end if;					
				
				if add_minute_tens='1'  then
					if add_count=to_unsigned(49, 6) then
						if minute_tens=5 then
							minute_tens <= x"0";
						else
							minute_tens <= minute_tens + 1;
						end if;
					end if;
				elsif count=to_unsigned(2999, 12) and add_hours_tens='0' and add_hours_units='0' and add_minute_units='0' then
						if minute_units=9 then
							if minute_tens=5 then
								minute_tens <= x"0";
							else
								minute_tens <= minute_tens + 1;
							end if;
						end if;
					end if;
			
				
				
				if add_minute_units='1' then
					if add_count=to_unsigned(49, 6) then
						if minute_units=9 then
							minute_units <= x"0";
						else
							minute_units <= minute_units + 1;
						end if;
					end if;
				elsif count=to_unsigned(2999, 12)  and add_hours_units='0' and add_hours_tens='0' and add_minute_tens='0' then
					if minute_units=9 then
						minute_units <= x"0";
					else
						minute_units <= minute_units + 1;
					end if;	
				end if;
			
				if count=to_unsigned(2999, 12) then
					count <= (others => '0');	
				else
					count <= count + 1;
				end if;
				if add_minute_tens='1' or add_hours_tens='1' or add_hours_units='1' or add_minute_units='1' then
					if add_count=to_unsigned(49, 6) then
						add_count <= (others => '0');	
					else
						add_count <= add_count + 1;
					end if;
				else
					add_count <= (others => '0');
				end if;
			
			--case to_integer(count(10 downto 9)) is
 --Channel_Led <= b"1000"; out_7seg <= ('1' & dec_7seg(minute_units));
				--when 1 => Channel_Led <= b"0100"; out_7seg <= ('1' & dec_7seg(minute_tens));
				--when 2 => Channel_Led <= b"0010"; out_7seg <= (count(15) & dec_7seg(hours_units));
				--when 3 => Channel_Led <= b"0001"; out_7seg <= ('1' & dec_7seg(hours_tens));
			   --when others => Channel_Led <= b"0000"; out_7seg <= (others => '1');
			--end case;
			out_7seg_minute_units <= ('1' & dec_7seg(minute_units));
			out_7seg_minute_tens <= ('1' & dec_7seg(minute_tens));
			out_7seg_hours_units <= ('0' & dec_7seg(hours_units));
			out_7seg_hours_tens <= ('1' & dec_7seg(hours_tens));
			
		end if;
	end process;
	
	Led <= count(11 downto 7);
end test_clock;	

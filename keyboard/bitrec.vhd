library ieee ;
use ieee.std_logic_1164.all ;
-- simplified 5 states bitrec  

-- DO NOT CHANGE IN THIS PART OF CODE --------------------------
entity bitrec is
   port ( resetN        : in  std_logic ;
             clk        : in  std_logic ;
             kbd_clk    : in  std_logic ;
             kbd_dat    : in  std_logic ;
             dout_new   : out std_logic ;
             dout       : out std_logic_vector(7 downto 0)) ;
end bitrec ;

architecture arc_bitrec of bitrec is
   signal shift_reg : std_logic_vector(9 downto 0) ;
   signal parity_ok : std_logic                    ;
   type state is (idle , --initial state
				HighClk,
				LowClk,
				ChkData,
				NewData );
   constant numOfBits : integer  := 11 ; 
begin
    parity_ok <=  shift_reg(8) -- same as kbd_dat
                xor shift_reg(7) xor shift_reg(6)
                xor shift_reg(5) xor shift_reg(4)
                xor shift_reg(3) xor shift_reg(2)
                xor shift_reg(1) xor shift_reg(0) ;
process ( resetN , clk )

  variable present_state : state;
  variable count : integer range 0 to 15;

begin

-- END OF DO NOT CHANGE PART ---------------------------

	---- ASYNC PART ----
    if resetN = '0' then
  		dout_new <= '0';
		dout <= (others => '0');
		count := 0 ;
      present_state := idle;
     ---- SYNCHRONOUS PART ----   
    elsif rising_edge (clk) then
  
		---- DEFAULT PART ----
	     dout_new <= '0';

		---- State Machine ----
	     case present_state is
		
			when idle =>
				count := 0;
				if (kbd_clk = '0' and kbd_dat = '0') then
					present_state := LowClk;
				--	count := count + 1;
				end if;
			when LowClk =>			
				if (kbd_clk = '1') then
				
					shift_reg <= kbd_dat & shift_reg(9 downto 1); 
					count := count +1;
					
					if (count < numOfBits) then
						present_state := HighClk;
					elsif (count = numOfBits) then
						present_state := ChkData;
					end if;
				end if;
			when HighClk =>
			
					if (kbd_clk = '0') then
						present_state := LowClk;
					end if;

			when ChkData =>
			
				if (parity_ok = '0') then
					present_state := idle;
				else 
					dout <= shift_reg(7 downto 0);
					present_state := NewData;
				end if;				
				
			when NewData =>
				dout_new <= '1';
				present_state := idle;
		end case;
 	end if;
end process;
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_mul is
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        x1 : in  signed(18 downto 0);
        x2 : in  signed(17 downto 0);
        y1 : in  signed(17 downto 0);
        y2 : in  signed(17 downto 0);
        d1 : in  signed(16 downto 0);
        d2 : in  signed(16 downto 0);
        f1 : in  signed(18 downto 0);
        f2 : in  signed(19 downto 0);
        h1 : in  signed(17 downto 0);
        h2 : in  signed(18 downto 0);
        a1 : in  signed(15 downto 0);
        a2 : in  signed(14 downto 0);
        b1 : in  signed(15 downto 0);
        b2 : in  signed(13 downto 0);
        o  : out signed(24 downto 0)
    );
end entity matrix_mul;

architecture rtl of matrix_mul is
    signal raw_m11 : signed(36 downto 0);
    signal raw_m12 : signed(36 downto 0);
    signal raw_m21 : signed(35 downto 0);
    signal raw_m22 : signed(35 downto 0);

    signal mult11_reg : signed(19 downto 0);
    signal mult12_reg : signed(19 downto 0);
    signal mult21_reg : signed(18 downto 0);
    signal mult22_reg : signed(18 downto 0);

    signal p_z11d1 : signed(36 downto 0);
    signal p_z12d2 : signed(36 downto 0);
    signal sum_e1_temp : signed(37 downto 0); 
    signal e1_reg : signed(23 downto 0);

    signal p_z21d1 : signed(35 downto 0);
    signal p_z22d2 : signed(35 downto 0);
    signal sum_e2_temp : signed(36 downto 0); 
    signal e2_reg : signed(22 downto 0);

    signal e1_reg_resized_g1 : signed(24 downto 0);
    signal f1_resized_g1 : signed(24 downto 0); 
    signal sum_g1_temp : signed(24 downto 0);
    signal g1_reg : signed(19 downto 0);

    signal e2_reg_resized_g2 : signed(23 downto 0);
    signal f2_resized_g2 : signed(23 downto 0); 
    signal sum_g2_temp : signed(23 downto 0);
    signal g2_reg : signed(18 downto 0);

    signal p_h1g1_comb : signed(37 downto 0);
    signal p_h2g2_comb : signed(37 downto 0);
    signal k1_sum_temp : signed(39 downto 0);
    signal k1_reg : signed(24 downto 0);

    signal p_a1b1_comb : signed(31 downto 0);
    signal p_a2b2_comb : signed(28 downto 0);
    signal c1_sum_temp : signed(33 downto 0);
    signal c1_reg : signed(19 downto 0);

    signal o_sum_temp : signed(25 downto 0);

begin

    raw_m11 <= x1 * y1;
    raw_m12 <= x1 * y2;
    raw_m21 <= x2 * y1;
    raw_m22 <= x2 * y2;

    p_z11d1 <= mult11_reg * d1;
    p_z12d2 <= mult12_reg * d2;
    sum_e1_temp <= resize(p_z11d1, 38) + resize(p_z12d2, 38);

    p_z21d1 <= mult21_reg * d1;
    p_z22d2 <= mult22_reg * d2;
    sum_e2_temp <= resize(p_z21d1, 37) + resize(p_z22d2, 37);

    e1_reg_resized_g1 <= resize(e1_reg, 25);
    f1_resized_g1 <= resize(f1 & "0", 25); 
    sum_g1_temp <= e1_reg_resized_g1 + f1_resized_g1;

    e2_reg_resized_g2 <= resize(e2_reg, 24);
    f2_resized_g2 <= resize(f2 & "0000", 24); 
    sum_g2_temp <= e2_reg_resized_g2 + f2_resized_g2;

    p_h1g1_comb <= h1 * g1_reg;
    p_h2g2_comb <= h2 * g2_reg;
    k1_sum_temp <= resize(p_h1g1_comb & "0", 40) + resize(p_h2g2_comb, 40); 

    p_a1b1_comb <= a1 * b1;
    p_a2b2_comb <= a2 * b2;
    c1_sum_temp <= resize(p_a1b1_comb & "00", 34) + resize(p_a2b2_comb & "0000", 34); 
    
    o_sum_temp <= resize(k1_reg, 26) + resize(c1_reg, 26);
    o <= o_sum_temp(24 downto 0);

    process(clk, rst)
    begin
        if rst = '1' then
            mult11_reg <= (others => '0');
            mult12_reg <= (others => '0');
            mult21_reg <= (others => '0');
            mult22_reg <= (others => '0');
            e1_reg <= (others => '0');
            e2_reg <= (others => '0');
            g1_reg <= (others => '0');
            g2_reg <= (others => '0');
            k1_reg <= (others => '0');
            c1_reg <= (others => '0');
        elsif rising_edge(clk) then
            mult11_reg <= raw_m11(36 downto 34) & raw_m11(33 downto 17);
            mult12_reg <= raw_m12(36 downto 34) & raw_m12(33 downto 17);
            mult21_reg <= raw_m21(35 downto 33) & raw_m21(32 downto 17);
            mult22_reg <= raw_m22(35 downto 33) & raw_m22(32 downto 17);

            e1_reg <= sum_e1_temp(37 downto 32) & sum_e1_temp(31 downto 14);
            e2_reg <= sum_e2_temp(36 downto 31) & sum_e2_temp(30 downto 14);
            
            g1_reg <= sum_g1_temp(23 downto 18) & sum_g1_temp(17 downto 4);
            g2_reg <= sum_g2_temp(22 downto 17) & sum_g2_temp(16 downto 4);

            k1_reg <= k1_sum_temp(38 downto 31) & k1_sum_temp(30 downto 14);
            
            c1_reg <= c1_sum_temp(31 downto 29) & c1_sum_temp(28 downto 12);
        end if;
    end process;

end architecture rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_mul is
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        x1 : in  signed(17 downto 0);
        x2 : in  signed(17 downto 0);
        y1 : in  signed(18 downto 0);
        y2 : in  signed(18 downto 0);
        d1 : in  signed(19 downto 0);
        d2 : in  signed(19 downto 0);
        f1 : in  signed(18 downto 0);
        f2 : in  signed(19 downto 0);
        h1 : in  signed(18 downto 0);
        h2 : in  signed(17 downto 0);
        a1 : in  signed(17 downto 0);
        a2 : in  signed(17 downto 0);
        b1 : in  signed(18 downto 0);
        b2 : in  signed(17 downto 0);
        o  : out signed(24 downto 0)
    );
end entity matrix_mul;

architecture rtl of matrix_mul is
    signal raw_m11, raw_m12, raw_m21, raw_m22 : signed(36 downto 0);

    signal mult11_reg, mult12_reg, mult21_reg, mult22_reg : signed(19 downto 0);

    signal p_z11d1, p_z12d2, p_z21d1, p_z22d2 : signed(39 downto 0);
    signal sum_e1_temp, sum_e2_temp : signed(40 downto 0);
    signal e1_reg, e2_reg : signed(22 downto 0);

    signal g1_sum_temp, g2_sum_temp : signed(23 downto 0);
    signal g1_reg, g2_reg : signed(22 downto 0);

    signal p_h1g1_comb : signed(41 downto 0);
    signal p_h2g2_comb : signed(40 downto 0);
    signal k1_sum_temp : signed(42 downto 0);
    signal k1_reg : signed(24 downto 0);

    signal p_a1b1_comb : signed(36 downto 0);
    signal p_a2b2_comb : signed(35 downto 0);
    signal c1_sum_temp : signed(37 downto 0);
    signal c1_reg : signed(19 downto 0);

    signal o_sum_temp : signed(25 downto 0);

begin

    raw_m11 <= x1 * y1;
    raw_m12 <= x1 * y2;
    raw_m21 <= x2 * y1;
    raw_m22 <= x2 * y2;

    p_z11d1 <= mult11_reg * d1;
    p_z12d2 <= mult12_reg * d2;
    sum_e1_temp  <= resize(p_z11d1, 41) + resize(p_z12d2, 41);

    p_z21d1 <= mult21_reg * d1;
    p_z22d2 <= mult22_reg * d2;
    sum_e2_temp  <= resize(p_z21d1, 41) + resize(p_z22d2, 41);

    g1_sum_temp <= resize(e1_reg, 24) + resize(f1, 24);
    g2_sum_temp <= resize(e2_reg, 24) + resize(f2, 24);

    p_h1g1_comb <= h1 * g1_reg;
    p_h2g2_comb <= h2 * g2_reg;
    k1_sum_temp <= resize(p_h1g1_comb, 43) + resize(p_h2g2_comb, 43);

    p_a1b1_comb <= a1 * b1;
    p_a2b2_comb <= a2 * b2;
    c1_sum_temp <= resize(p_a1b1_comb, 38) + resize(p_a2b2_comb, 38);
    
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
            mult21_reg <= raw_m21(36 downto 34) & raw_m21(33 downto 17);
            mult22_reg <= raw_m22(36 downto 34) & raw_m22(33 downto 17);

            e1_reg <= sum_e1_temp(39 downto 34) & sum_e1_temp(33 downto 17);
            e2_reg <= sum_e2_temp(39 downto 34) & sum_e2_temp(33 downto 17);
            
            g1_reg <= g1_sum_temp(22 downto 0);
            g2_reg <= g2_sum_temp(22 downto 0);

            k1_reg <= k1_sum_temp(41 downto 34) & k1_sum_temp(33 downto 17);
            
            c1_reg <= c1_sum_temp(36 downto 34) & c1_sum_temp(33 downto 17);
        end if;
    end process;

end architecture rtl;
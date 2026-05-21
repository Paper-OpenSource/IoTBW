library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity matrix_tb is
end entity matrix_tb;

architecture sim of matrix_tb is
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '1';

    signal x1_tb : signed(18 downto 0);
    signal x2_tb : signed(17 downto 0);
    signal y1_tb : signed(17 downto 0);
    signal y2_tb : signed(17 downto 0);
    signal d1_tb : signed(16 downto 0);
    signal d2_tb : signed(16 downto 0);
    signal f1_tb : signed(18 downto 0);
    signal f2_tb : signed(19 downto 0);
    signal h1_tb : signed(17 downto 0);
    signal h2_tb : signed(18 downto 0);
    signal a1_tb : signed(15 downto 0);
    signal a2_tb : signed(14 downto 0);
    signal b1_tb : signed(15 downto 0);
    signal b2_tb : signed(13 downto 0);

    signal o_tb  : signed(24 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    constant X1_FRAC_BITS : natural := 18;
    constant X2_FRAC_BITS : natural := 17;
    constant Y1_Y2_FRAC_BITS : natural := 16;
    constant D1_D2_FRAC_BITS : natural := 14;
    constant F1_FRAC_BITS : natural := 17;
    constant F2_FRAC_BITS : natural := 17;
    constant H1_FRAC_BITS : natural := 16;
    constant H2_FRAC_BITS : natural := 18;
    constant A1_FRAC_BITS : natural := 15;
    constant A2_FRAC_BITS : natural := 14;
    constant B1_FRAC_BITS : natural := 14;
    constant B2_FRAC_BITS : natural := 13;
    constant K1_O_FRAC_BITS : natural := 17;


    function to_fixed(val : real; total_bits : natural; frac_bits : natural) return signed is
        variable scaled_val : real;
        variable int_val    : integer;
    begin
        scaled_val := val * (2.0**frac_bits);
        int_val    := integer(round(scaled_val));
        return to_signed(int_val, total_bits);
    end function to_fixed;

begin
    dut_inst: entity work.matrix_top
        port map (
            clk => clk_tb,
            rst => rst_tb,
            x1  => x1_tb,
            x2  => x2_tb,
            y1  => y1_tb,
            y2  => y2_tb,
            d1  => d1_tb,
            d2  => d2_tb,
            f1  => f1_tb,
            f2  => f2_tb,
            h1  => h1_tb,
            h2  => h2_tb,
            a1  => a1_tb,
            a2  => a2_tb,
            b1  => b1_tb,
            b2  => b2_tb,
            o   => o_tb
        );

    clk_process: process
    begin
        while now < 300 ns loop 
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_process;

    stim_proc: process
        variable rx1, rx2, ry1, ry2, rd1, rd2, rf1, rf2, rh1, rh2, ra1, ra2, rb1, rb2 : real;
    begin
        rst_tb <= '1';
        wait for CLK_PERIOD * 2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        rx1 := 0.5;      x1_tb <= to_fixed(rx1, 19, X1_FRAC_BITS);
        rx2 := -0.25;    x2_tb <= to_fixed(rx2, 18, X2_FRAC_BITS);
        ry1 := 1.5;      y1_tb <= to_fixed(ry1, 18, Y1_Y2_FRAC_BITS);
        ry2 := -0.75;    y2_tb <= to_fixed(ry2, 18, Y1_Y2_FRAC_BITS);
        rd1 := 2.0;      d1_tb <= to_fixed(rd1, 17, D1_D2_FRAC_BITS);
        rd2 := -1.0;     d2_tb <= to_fixed(rd2, 17, D1_D2_FRAC_BITS);
        rf1 := 0.125;    f1_tb <= to_fixed(rf1, 19, F1_FRAC_BITS);
        rf2 := -0.125;   f2_tb <= to_fixed(rf2, 20, F2_FRAC_BITS);
        rh1 := 0.25;     h1_tb <= to_fixed(rh1, 18, H1_FRAC_BITS);
        rh2 := 0.0625;   h2_tb <= to_fixed(rh2, 19, H2_FRAC_BITS);
        ra1 := 0.75;     a1_tb <= to_fixed(ra1, 16, A1_FRAC_BITS);
        ra2 := -0.5;     a2_tb <= to_fixed(ra2, 15, A2_FRAC_BITS);
        rb1 := 1.0;      b1_tb <= to_fixed(rb1, 16, B1_FRAC_BITS);
        rb2 := 0.5;      b2_tb <= to_fixed(rb2, 14, B2_FRAC_BITS);

        wait for CLK_PERIOD * 20; 

        wait;
    end process stim_proc;

end architecture sim;

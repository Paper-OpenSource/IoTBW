library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matrix_top is
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
end entity matrix_top;

architecture structural of matrix_top is
begin
    u_matrix_mul_inst: entity work.matrix_mul
        port map (
            clk => clk,
            rst => rst,
            x1 => x1,
            x2 => x2,
            y1 => y1,
            y2 => y2,
            d1 => d1,
            d2 => d2,
            f1 => f1,
            f2 => f2,
            h1 => h1,
            h2 => h2,
            a1 => a1,
            a2 => a2,
            b1 => b1,
            b2 => b2,
            o  => o
        );
end architecture structural;
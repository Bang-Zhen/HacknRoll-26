with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Invite_Code is
   subtype Byte is Integer range 0 .. 255;
   package Rand is new Ada.Numerics.Discrete_Random (Byte);
   Gen : Rand.Generator;
   function Hex (B : Byte) return String is
      Digits : constant String := "0123456789ABCDEF";
      Hi : Integer := B / 16;
      Lo : Integer := B mod 16;
   begin
      return Digits (Hi + 1) & Digits (Lo + 1);
   end Hex;
begin
   Rand.Reset (Gen);
   Put_Line (Hex (Rand.Random (Gen)) &
             Hex (Rand.Random (Gen)) &
             Hex (Rand.Random (Gen)) &
             Hex (Rand.Random (Gen)));
end Invite_Code;

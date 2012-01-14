--  Generated by gperfhash
with Util.Strings.Transforms;
with Interfaces; use Interfaces;

package body Sqlite3_H.Perfect_Hash is

   C : constant array (Character) of Unsigned_8 :=
     (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
      15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 0, 0, 0, 0, 0, 0,
      0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
      15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

   P : constant array (0 .. 6) of Natural :=
     (1, 2, 3, 4, 7, 9, 13);

   T1 : constant array (0 .. 6, Unsigned_8 range 0 .. 24) of Unsigned_8 :=
     ((143, 96, 170, 168, 5, 221, 118, 70, 107, 192, 176, 130, 205, 180, 29,
       75, 72, 130, 134, 58, 11, 112, 107, 171, 238),
      (180, 2, 196, 77, 209, 61, 149, 97, 43, 57, 69, 126, 232, 154, 25, 211,
       62, 215, 181, 201, 228, 167, 28, 102, 215),
      (133, 106, 209, 117, 51, 209, 60, 189, 39, 41, 33, 19, 192, 151, 94,
       120, 190, 187, 151, 241, 38, 145, 217, 75, 212),
      (147, 18, 41, 107, 118, 30, 200, 90, 101, 192, 44, 168, 94, 60, 134,
       10, 50, 154, 4, 213, 75, 107, 141, 216, 51),
      (41, 104, 175, 241, 124, 61, 0, 11, 87, 21, 236, 106, 178, 89, 202,
       193, 188, 51, 144, 208, 221, 139, 171, 90, 222),
      (52, 176, 202, 98, 235, 165, 118, 228, 58, 161, 116, 43, 211, 102, 236,
       7, 198, 105, 78, 186, 118, 191, 16, 48, 128),
      (133, 172, 79, 95, 45, 169, 47, 156, 128, 214, 180, 197, 86, 107, 99,
       99, 39, 28, 235, 81, 124, 139, 132, 225, 23));

   T2 : constant array (0 .. 6, Unsigned_8 range 0 .. 24) of Unsigned_8 :=
     ((94, 74, 218, 128, 191, 64, 53, 80, 54, 36, 176, 13, 192, 31, 45, 43,
       139, 74, 169, 234, 141, 5, 208, 79, 239),
      (35, 233, 99, 220, 99, 211, 131, 143, 149, 138, 37, 42, 35, 57, 202,
       217, 88, 108, 105, 114, 42, 103, 27, 56, 67),
      (102, 8, 146, 198, 7, 113, 80, 188, 109, 57, 239, 32, 76, 186, 96, 142,
       157, 156, 48, 211, 145, 223, 106, 24, 131),
      (216, 125, 109, 240, 114, 175, 39, 237, 107, 142, 180, 185, 208, 65,
       55, 65, 42, 73, 137, 94, 38, 12, 174, 228, 122),
      (151, 225, 8, 68, 9, 166, 38, 56, 223, 64, 116, 197, 63, 224, 30, 6,
       175, 188, 140, 240, 98, 105, 210, 183, 235),
      (57, 193, 135, 211, 112, 69, 91, 204, 78, 191, 151, 115, 179, 221, 162,
       204, 110, 205, 176, 96, 78, 227, 122, 91, 186),
      (27, 62, 122, 225, 148, 217, 212, 155, 163, 21, 117, 47, 179, 197, 108,
       150, 229, 148, 35, 115, 179, 191, 58, 3, 49));

   G : constant array (0 .. 242) of Unsigned_8 :=
     (0, 70, 0, 85, 0, 0, 0, 45, 60, 5, 0, 112, 0, 0, 0, 18, 0, 0, 46, 43, 0,
      114, 51, 45, 0, 0, 0, 0, 6, 72, 5, 81, 0, 106, 0, 0, 32, 0, 0, 0, 0, 0,
      35, 113, 58, 0, 21, 60, 0, 23, 0, 0, 53, 75, 47, 44, 25, 0, 0, 13, 81,
      0, 0, 0, 0, 63, 0, 0, 0, 7, 0, 0, 60, 12, 0, 0, 71, 0, 0, 0, 51, 0,
      106, 20, 0, 0, 0, 0, 0, 14, 80, 0, 0, 0, 2, 0, 0, 25, 97, 0, 0, 0, 70,
      0, 117, 0, 0, 0, 0, 19, 16, 12, 74, 40, 94, 0, 0, 10, 0, 111, 0, 85,
      47, 0, 11, 0, 45, 0, 0, 0, 28, 16, 0, 0, 66, 0, 0, 64, 0, 100, 62, 15,
      0, 100, 3, 0, 0, 0, 0, 46, 0, 81, 0, 13, 89, 0, 0, 40, 0, 67, 20, 28,
      36, 58, 0, 0, 0, 0, 4, 57, 0, 7, 17, 0, 0, 118, 78, 114, 0, 0, 59, 74,
      0, 12, 44, 0, 0, 0, 120, 0, 48, 50, 110, 88, 0, 1, 32, 0, 0, 8, 0, 21,
      54, 56, 0, 26, 62, 0, 0, 0, 0, 15, 31, 90, 0, 0, 0, 21, 5, 104, 33, 0,
      78, 3, 35, 0, 0, 0, 18, 0, 0, 105, 0, 50, 19, 0, 6, 95, 17, 0, 14, 39,
      0);

   function Hash (S : String) return Natural is
      F : constant Natural := S'First - 1;
      L : constant Natural := S'Length;
      F1, F2 : Natural := 0;
      J : Unsigned_8;
   begin
      for K in P'Range loop
         exit when L < P (K);
         J  := C (S (P (K) + F));
         F1 := (F1 + Natural (T1 (K, J))) mod 243;
         F2 := (F2 + Natural (T2 (K, J))) mod 243;
      end loop;
      return (Natural (G (F1)) + Natural (G (F2))) mod 121;
   end Hash;

   --  Returns true if the string <b>S</b> is a keyword.
   function Is_Keyword (S : in String) return Boolean is
      H : constant Natural := Hash (S);
   begin
      return Keywords (H).all = Util.Strings.Transforms.To_Upper_Case (S);
   end Is_Keyword;
end Sqlite3_H.Perfect_Hash;

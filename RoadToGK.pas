unit RoadToGk;

interface

uses SysUtils;

//procedure
function GkAden: string;
function GK(cidade: string): string;

implementation

function GkAden: string;

var x, y, z: integer;
var GK_name: string;

begin
   x := User.X; y := User.Y; z := User.Z;
   Gk_name := 'elisa';
   Result := 'false';
   //Center
   //x = 146364, 148557
   //y = 26571, 28692

   if (x >= 146237) and (x <= 148574) and (y >= 26471) and (y <= 28692) and
      (z >= -2400 ) and (z <= -2100) then begin

      Engine.MoveTo(147440,26851,-2206);
      Engine.MoveTo(147208,25819,-2015);
      Engine.MoveTo(146779,25808,-2015);
   end
   //Superior Esquerdo
   else if (x >= 143624) and (x <= 147323) and (y >= 20392) and (y <= 25169) and
           (z >= -2143 ) and (z <= -2055) then begin

           //Engine.MoveTo(144925,22642,-2143); //Linha Para Geodata Fudido
           Engine.MoveTo(145459,24240,-2143);
           Engine.MoveTo(146383,24314,-2015);
           Engine.MoveTo(146496,25732,-2015);
           Engine.MoveTo(146771,25796,-2015);
   end
   //Parte de Baixo
   //x = 143867, 151348
   //y = 28824, 31458
   //z = -2463, -2415
   else if (x >= 143867) and (x <= 151348) and (y >= 28824) and (y <= 31458) and
           (z >= -2463 ) and (z <= -2415) then begin

           Engine.MoveTo(147460,30136,-2463);
           Engine.MoveTo(147419,28626,-2270);
           if User.InRange(147419,28626,-2246, 300, 300) then
              GkAden
   end
   //Lado Superor Direito
   //x = 147662, 150768
   //y = 20545, 24834
   //z = -2143, -2015
   else if (x >= 147662) and (x <= 150768) and (y >= 20545) and (y <= 24834) and
           (z >= -2243 ) and (z <= -2015) then begin

           Engine.MoveTo(149695,24284,-2143);
           Engine.MoveTo(148554,24264,-2015);
           Engine.MoveTo(148423,25755,-2015);
           Engine.MoveTo(146815,25794,-2015);
    end;
    if User.InRange(146791,25808,-2008, 300, 300) then begin
       Result := 'Gk ' + Gk_name;
    end;
end;

function GK (cidade: string): string;

begin
   if LowerCase(cidade) = 'aden' then
      Result := GkAden;
end;

end.

<QucsStudio Schematic 5.8>
<Properties>
View=0,0,1212,800,1,165,0
Grid=10,10,1
DataSet=*.dat
DataDisplay=*.dpl
OpenDisplay=3
showFrame=0
FrameText0=Title \n @PATH@@FILE@
FrameText1=Drawn By:
FrameText2=Date: @DATE@
FrameText3=Revision:
</Properties>
<Symbol>
</Symbol>
<Components>
Pac P1 1 280 180 18 -26 0 "1"1"50 Ω"1"0 dBm"0"1 GHz"0"26.85"0"con_2"0
GND * 1 280 210 0 0 0
GND * 1 640 220 0 0 0
Pac P2 1 640 180 18 -26 0 "2"1"50 Ω"1"0 dBm"0"1 GHz"0"26.85"0"con_2"0
COAX TL1 1 470 150 -26 16 0 "2.29"1"0.022e-6"0"1"0"2.95 mm"0"0.9 mm"0"1 m"1"4e-4"0"26.85"0
.SP SP1 1 70 100 0 9 0 "lin"1"0.5 GHz"1"1.2 GHz"1"2001"1"no"0"1"0"2"0"none"0
</Components>
<Wires>
640 210 640 220
500 150 640 150
280 150 440 150
</Wires>
<Diagrams>
<Rect 812 240 360 220 31 #c0c0c0 1 00 1 0 1 1 1 0 1 1 1 0 1 1 -1 -1 -1 "" "" "">
	<Legend 10 -100 0>
	<"dB(S[1,1])" "" #0000ff 1 3 0 0 0 0 "">
	<"dB(S[2,1])" "" #ff0000 1 3 0 0 0 0 "">
</Rect>
<Smith 812 540 220 220 31 #c0c0c0 1 00 1 0 1 1 1 0 1 1 1 0 1 1 -1 -1 -1 "" "" "">
	<Legend 10 -100 0>
	<"S[1,1]" "" #0000ff 1 3 0 0 0 0 "">
	<"S[2,2]" "" #ff0000 1 3 0 0 0 0 "">
</Smith>
</Diagrams>
<Paintings>
</Paintings>

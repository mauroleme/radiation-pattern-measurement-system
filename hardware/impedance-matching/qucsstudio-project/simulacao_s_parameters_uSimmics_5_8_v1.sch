<QucsStudio Schematic 5.8>
<Properties>
View=19.8897,-102.968,1312.06,790,0.723214,0,0
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
L L1 1 540 90 -26 10 0 "4.517 nH"1"0"0""0"inductor_1mH"0
C C2 1 470 160 17 -26 1 "3.174 pF"1"0"0""0"neutral"0"SMD0603"0
GND * 1 470 190 0 0 0
SPfile Antena_Yagi_868MHz 1 700 90 -26 -40 0 "C:/Users/jpcoe/Seafile/Minha Biblioteca/Alunos/Mauro/Ensaios 23Abr2025/Antena Transmissora/500M_1200M.s1p"0"1"0"polar"0"linear"0"short"0"none"0"block"0"SOT23"0
GND * 1 700 190 0 0 0
.SP SP1 1 90 480 0 9 0 "lin"1"800 MHz"1"1 GHz"1"20001"1"no"0"1"0"2"0"none"0
Pac P1 1 80 120 18 -26 0 "1"1"50 Ω"1"0 dBm"0"1 GHz"0"26.85"0"con_2"0
GND * 1 80 200 0 0 0
TLIN TL1 1 270 90 -26 20 0 "50 Ω"1"1 m"1"0 dB"0"26.85"0""0""0
</Components>
<Wires>
470 90 510 90
470 90 470 130
570 90 670 90
700 120 700 190
80 150 80 200
80 90 240 90
300 90 470 90
</Wires>
<Diagrams>
<Rect 912 240 360 220 31 #c0c0c0 1 00 1 0 1 1 1 0 1 1 1 0 1 1 -1 -1 -1 "" "" "">
	<Legend 10 -100 0>
	<"dB(S[1,1])" "" #0000ff 1 3 0 0 0 0 "">
</Rect>
<Smith 912 540 220 220 31 #c0c0c0 1 00 1 0 1 1 1 0 1 1 1 0 1 1 -1 -1 -1 "" "" "">
	<Legend 10 -100 0>
	<"S[1,1]" "" #0000ff 1 3 0 0 0 0 "">
	  <Mkr 8.6845e+08 108 -210 3 1 0 0 1 50>
</Smith>
</Diagrams>
<Paintings>
Text 420 66 16 #000000 0 port
Text 560 66 16 #000000 0 device
</Paintings>

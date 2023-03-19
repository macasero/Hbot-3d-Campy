; Configuration file for Duet WiFi (firmware version 3)
; executed by the firmware on start-up
; ==============================================================
;
; Hbot XL by Campy3d
;
global model = 1								; 1 = XL 		2 = ST    for  CUSTOM (edit in config-var.g on you model type XT or ST)
global probetype = 2							; 1 = IR mini    2 = Superpinda    3 = 10mm Inductive
global meshP = 3								; X = size of mesh matrix size: 3 = 3x3 ; 5 = 5x5 ; 7 = 7x7 ; 9 = 9x9; 11 = 11 x 11
; ===============================================================
; LCD
M575 P1 S1 B57600								; enable support for PanelDue
G4 S2											; Pause for 1LC boot
M955 I21										; set 1LC orienation
; Load model type
;M98 P"0:/sys/config-var.g" S{global.model} L0 Z0  

; General preferences
G90												; send absolute coordinates...
M83												; ...but relative extruder moves
M550 P"HBot XL RRF3"						    ; set printer name
M669 K1											; select CoreXY mode

; Network
M552 S1											; enable network
M586 P0 S1										; enable HTTP
M586 P1 S1										; enable FTP
M586 P2 S0										; enable Telnet

; Drives
M569 P0.4 S1                                         ; physical drive 0.4 goes forwards
M569 P0.3 S0                                         ; physical drive 0.3 goes backwards
M569 P0.2 S1                                         ; physical drive 0.2 goes forwards
M569 P0.1 S1                                         ; physical drive 0.2 goes forwards
M569 P121.0 S0                                       ; physical drive 121.0 goes backwards
M584 X0.4 Y0.3 Z0.2:0.1 E121.0                           ; set drive mapping
M350 X16 Y16 Z16 E16 I1							; configure microstepping with interpolation
M92 X80.00 Y80.00 Z400.00 E400.00				; set steps per mm
M566 X500.00 Y500.00 Z60.00 E600.00				; set maximum instantaneous speed changes (mm/min)
M566 P1
M203 X18000.00 Y18000.00 Z800.00 E4800.00		; set maximum speeds (mm/min)
M201 X2000.00 Y2000.00 Z400.00 E4000.00			; set accelerations (mm/s^2)
M201.1 X500 Y500 Z200 							; set accelerations for special moves (probing)
M204 P1200.0 T5000.0                                     ; set print and travel accelerations (mm(s^2)
M566 E400						;300	  ; Set maximum instantaneous speed changes (JERKS) (mm/min) ONLY EXTRUDER
M205 X8 Y8 Z8							; Set maximum instantaneous speed changes (JERKS) (mm/seg) XYZ . USE this for Marlin COMPATIBILITY
M906 X1000 Y1000 Z1000 E560 I30					; set motor currents (mA) and motor idle factor in per cent
M84 S30											; Set idle timeout

; Axis Limits
M208 X0 Y0 Z-1 S1								; set axis minima
M208 X330 Y325 Z395 S0							; set axis maxima

; Definimos Leadscrews para el Z_Tilt
M671 X-59.13:437.87 Y164:164 S5		        

		        
; Endstops
M574 X1 S1 P"!io1.in"                                 ; configure switch-type (e.g. microswitch) endstop for low end on X via pin io1.in
M574 Y2 S1 P"!121.io0.in"                             ; configure switch-type (e.g. microswitch) endstop for low end on Y via pin 121.io0.in

; Filament Sensor
;M98 P"0:/sys/00-Functions/FilamentsensorStatus"

; Z-Probe IR
M558 P8 C"121.io2.in" H5 F600 T9000 A3 S0.03        ; Set Z probe type mini ir sensor
G31 P1000 X-25 Y0 Z 0.728 								; set Z probe trigger value, offset and trigger height
M557 X20:305 Y20:300 P3								; Mesh 3x3

; Heaters BED
M308 S0 P"temp0" Y"thermistor" T100000 B3950 A"Heated Bed"	; configure sensor 0 as thermistor on pin bedtemp
M950 H0 C"out0" T0							; create bed heater output on bedheat and map it to sensor 0
M307 H0 B0 S1.00								; disable bang-bang mode for the bed heater and set PWM limit
M140 H0											; map heated bed to heater 0
M143 H0 S120									; set temperature limit for heater 0 to 120C
M143 H0 P0 S120 A2								; disable temporarily H0 if temp exceeds 120C
M143 H0 P0 S130 A0								; heater fault H0 if temp exceeds 130C
M570 H0 P60 T15 S0 

; Heaters HOTEND
M308 S1 P"121.temp1" Y"thermistor" T100000 B4725 C7.06e-8 A"Nozzle T0" ; Configure sensor 1 as thermistor on pin e0temp
M950 H1 C"121.out0" T1									; create nozzle heater output on e0heat and map it to sensor 1
M307 H1 B0 S1.00										; disable bang-bang mode for heater	and set PWM limit
M143 H1 S290											; set temperature limit for heater 1 to 300C
M143 H1 S275 A2											; disable temporarily H1 if temp exceeds 275C
M143 H1 S285 A0											; heater fault H1 if temp exceeds 280C
M570 H1 P10 T30 S0										; heater fault for 10 seg of 30ยบC excursion

;PID backup
M307 H0 R0.322 C632.982:632.982 D5.13 S1.00 V24.3 B0 I0		; Bed PID
M307 H1 R2.813 C295.614:204.933 D6.24 S1.00 V24.5 B0 I0		; Hotend PID

; Fan0 = Part Coooling
M950 F0 C"121.out2" Q500							; create fan 0 on pin fan0 and set its frequency
M106 P0 C"LayerFAN" S0 H-1 B0.3					; set fan 0 name and value. Thermostatic control is turned off

; Fan1 = Hotend
M950 F1 C"121.out1" Q500							; create fan 1 on pin fan1 and set its frequency
M106 P1 C"ToolFAN" S1 H1 T60					; set fan 1 name and value. Thermostatic control is turned on

; Fan2 = Chamber cam
M950 F2 C"out3" Q100 							; create fan 2 on pin fan2 and set its frequency
M106 P2 I0 C"ChamFAN" S0 H-1 B0.3                    ; Set fan 2 PWR fan

; Sensor = MotherBoard Cooling
;----MCU & DRIVERS sensors------
;M912 P0 S-13							        ; Cpu temp correction MUST BE ADJUSTED ON EACH BOARD
M308 S3 Y"mcu-temp"	A"MCU"						; create sensor for MCU temp M308 S3 Y"mcutemp"
M308 S4 Y"drivers"	A"Drivers"					; create sensor for drivers temp M308 S4 Y"drivers"

; Tools
M200 D1.75
M563 P0 S"T0" D0 H1 F0							; define tool 0
G10 P0 X0 Y0 Z0									; set tool 0 axis offsets
G10 P0 R-274 S-274								; set initial tool 0 active and standby temperatures to 0C
M302 S180 R180                                         ; allow extrusion starting from 180°C and retractions already from 180°C

; Firmware Retraction
M404 N1.75										; Define filament diameter for print monitor
M207 S0.95 R0 F2400 Z0							; Firmware retraction

; Bed Compensation Taper
M376 H10										; Bed Compensation Taper 10mm

; Pressure Advance
;M572 D0 S0.09			;PLA
;M572 D0 S0.11			;PETG
;M572 D0 S0.1			;ABS

; LCD
M575 P1 S1 B57600								; enable support for PanelDue

; LEDS
M950 P1 C"out6" Q500							;use heater 1 outupt for LED
M42 P1 S1										; turn on LEDS

; Power Management
M911 S23 R24 P"M913 X0 Y0 G91 M83 G1 Z3 E-5 F1000"		; set voltage thresholds and actions to run on power loss
; Select Tool 0
T0												; select first tool
; Load config-override
M501											; load saved parameters from non-volatile memory
; Load Preloaded filamento config
M703

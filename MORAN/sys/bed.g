; bed.g
; called to perform automatic bed compensation via G32
; Centro CON offset probe para los G1: 146,198
; Centro SIN offset probe para los G30:164,160
; generated by RepRapFirmware Configuration Tool v3.2.3 on Mon Jun 14 2021 12:17:56 GMT+0200 (hora de verano de Europa central)
;
;
M291 P"Probing Z-tilt process started" R"Probing.." S1 T2
M561                                                   ; clear any existing bed transform
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
        G28                                            ; home all axis without mesh bed level
else
	G28 Z
;M558 F600:80 A5 S0.003 ;  0.01                 ; Slow z-probe, up to 5 probes until disparity is 0.02 or less - else yield average.
M558 F600:80 A5 S0.01 ;  0.01                 ; Slow z-probe, up to 5 probes until disparity is 0.02 or less - else yield average.
while iterations <=2                                   ; perform 3 passes
   G30 P0 X{global.tiltZ1} Y{global.midYP} Z-99999                               ; probe near a leadscrew, half way along Y axis
   G30 P1 X{global.tiltZ2} Y{global.midYP} Z-99999 S2                           ; probe near a leadscrew and calibrate 2 motors
   G1 X{global.midX} F10000                                      ; move to the center of the bed
   G30                                                 ; probe the bed at the current xy position
   M400      
   
   ; finish all moves, clear the buffer
;
M558 F150:50 A5 S-1                                        ; slow the z-probe, perform 5 probes and yield the average
while move.calibration.initial.deviation >= 0.01  ;0.01    ; perform additional leveling if previous deviation was over 0.02mm
   if iterations = 5                                   ; perform 5 addition checks, if needed
      M300 S3000 P500                                  ; sound alert, the required deviation could not be achieved
      M558 F200 A1                                     ; set normal z-probe speed
      abort "!!! ABORTED !!! Failed to achieve < 0.01 deviation. Current deviation is " ^ move.calibration.initial.deviation ^ "mm."
   G30 P0 X{global.tiltZ1} Y{global.midYP} Z-99999                               ; probe near a leadscrew, half way along Y axis
   G30 P1 X{global.tiltZ2} Y{global.midYP} Z-99999 S2                           ; probe near a leadscrew and calibrate 2 motors
   G1 X{global.midX} F10000                                      ; move to the center of the bed
   G30                                                 ; probe the bed at the current XY position
   M400                                                ; finish all moves, clear the buffer
;
; Z-Probe IR reset back config
;
echo "Gantry deviation of " ^ move.calibration.initial.deviation ^ "mm obtained."
;
M558 F600 T9000 A3 S0.03 
G28 Z  
G29		; do a mesh
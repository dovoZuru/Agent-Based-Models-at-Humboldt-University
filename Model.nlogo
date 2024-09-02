breed [gardeners gardener]  ; Define the gardener breed
breed [leaves leaf]  ; Define the leaf breed

globals [happy-count hungry-count max-leaves-possession leaves-consumption-rate]  ; Define global variables

gardeners-own [harvesting-ticks leaves-seen leaves-harvested happy original-color leaves-possession leaves-consumed sharing-ticks speed]  ; Define variables specific to gardeners
leaves-own [previous-color]  ; Define variables specific to leaves

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP & GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all  ; Clear the world
  set weather weather
  set max-leaves-possession 50  ; Set the maximum leaves a gardener can hold
  set leaves-consumption-rate Consumption  ; Set the rate at which leaves are consumed
  set-default-shape gardeners "person"  ; Set the shape of gardeners to "person"
  set-default-shape leaves "leaf"  ; Set the shape of leaves to "leaf"
  create-gardeners TotalGardeners [
    set color 21  ; Set initial color
    set size 2.5  ; Set size
    set leaves-seen 0  ; Initialize leaves seen to 0
    set leaves-harvested 0  ; Initialize leaves harvested to 0
    set happy true  ; Initialize happy to false
    set original-color 21  ; Set original color
    set leaves-possession 20  ; Initialize leaves possession to 20
    set leaves-consumed 0  ; Initialize leaves consumed to 0
    set speed Velocity  ; Initialize speed
    set harvesting-ticks 20
  ]
  space  ; Setup the environment
  location  ; Position the gardeners
  creating-leaves  ; Create the leaves
  reset-ticks  ; Reset the tick counter
end

to go
  ask gardeners [
    move
    ifelse harvesting-ticks <= 0 [
      consume-leaves  ; Consume leaves
    ][
      set harvesting-ticks harvesting-ticks - 1  ; Decrease harvesting ticks
    ]
    update-leaves-possession-label  ; Update the label showing leaves possession
  ]
  check-happiness  ; Check and update happiness
  create-ready-leaves  ; Create new leaves if needed
  decrease-sharing-ticks  ; Decrease sharing ticks
  decrease-harvesting-ticks


  tick  ; Advance the tick counter
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;; INITIALS PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to space
  ask patches [
    ifelse (pxcor <= 16 and pycor >= 5) or
           (pxcor <= -2 and pycor <= 3) or
           (pxcor >= 0 and pycor <= 3)
    [
      set pcolor green  ; Set the color of certain patches to green
    ]
    [
      set pcolor brown  ; Set the color of the other patches to brown
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CREATE PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to creating-leaves
  create-leaves Area1 [
    set color 57  ; Set color of leaves
    set previous-color color  ; Store the previous color
    set size 1.5  ; Set size
    let x (random-float 32) - 16  ; Calculate x position
    let y (random-float 10) - (-6)  ; Calculate y position
    setxy x y  ; Set position
  ]

  create-leaves Area2 [
    set color 57  ; Set color of leaves
    set previous-color color  ; Store the previous color
    set size 1.5  ; Set size
    let x (random-float 16) - 0  ; Calculate x position
    let y (random-float 19) - 16  ; Calculate y position
    setxy x y  ; Set position
  ]

  create-leaves Area3 [
    set color 57  ; Set color of leaves
    set previous-color color  ; Store the previous color
    set size 1.5  ; Set size
    let x (random-float 13.5) - 16  ; Calculate x position
    let y (random-float 19) - 16  ; Calculate y position
    setxy x y  ; Set position
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MOVEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move
  if (rule = "Segregation") [
    ask gardeners [
    move-within-bounds-and-avoid-walls -16 16 -16 16 ; Move and avoid walls within bounds
  ]

    check-possession-status-in-seg
    check-for-red-gardeners-in-seg
    check-collision-in-seg
    check-radius-in-seg
    pluck-leaves-in-seg
    apply-weather-effects-in-seg

  ]
  if (rule = "Commoning") [
    check-for-red-gardeners-in-com
    check-radius-in-com
    pluck-leaves-in-com
    check-collision-in-com
    avoid-walls  ; Avoid walls
    check-possession-status-in-com
    apply-weather-effects-in-com
  ]
end

to move-within-bounds-and-avoid-walls [min-x max-x min-y max-y]
  let heading-before heading

  ;; Check if at or near boundary or on a brown patch, then bounce back
  if (xcor <= min-x + 1 or xcor >= max-x - 1 or ycor <= min-y + 1 or ycor >= max-y - 1) or
     ([pcolor] of patch-here = brown or [pcolor] of patch-ahead 1 = brown or
     [pcolor] of patch-left-and-ahead 90 1 = brown or [pcolor] of patch-right-and-ahead 90 1 = brown) [

    ;; Turn around or adjust heading to avoid out-of-bounds or brown patches
    set heading (heading + 180) mod 360
  ]

  ;; Move forward only if within bounds
  if (xcor > min-x and xcor < max-x and ycor > min-y and ycor < max-y) [
    ;fd fdSpeed
  ]

  ;; Correct position if still out of bounds after moving
  if xcor < min-x [ set xcor min-x + 1 ]
  if xcor > max-x [ set xcor max-x - 1 ]
  if ycor < min-y [ set ycor min-y + 1 ]
  if ycor > max-y [ set ycor max-y - 1 ]
end



to avoid-walls
  if (xcor <= min-pxcor + 1) or (xcor >= max-pxcor - 1) or (ycor <= min-pxcor + 1) or (ycor >= max-pxcor - 1) [
    set heading (heading + 180) mod 360
  ]
end

to check-for-red-gardeners-in-com
  if (color = 21 or color = black) [
    let hungry-gardeners-in-radius gardeners with [color = red] in-radius Proximity
    if any? hungry-gardeners-in-radius[
      let target one-of hungry-gardeners-in-radius
      face target
      fd speed
    ]
  ]
end

to check-for-red-gardeners-in-seg
  ask gardeners [
    move-within-bounds-and-avoid-walls -16 16 -16 16
  ]

  if (color = 21 or color = black) [
    let hungry-gardeners-in-radius gardeners with [color = red] in-radius Proximity
    if any? hungry-gardeners-in-radius[
      let target one-of hungry-gardeners-in-radius
      face target
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; WEATHER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to apply-weather-effects-in-com

  if weather = "sunny" [
    ask leaves [
      set interval 2
    ]


    ask gardeners [
      ifelse leaves-possession > 0 [
        fd Velocity
        set color 21

      ][
        set color red

      ]
      set Gift 10
      set consumption 1
      set shareTime 30

    ]
  ]

  if weather = "rainy" [
    ask leaves [
      set interval 3
    ]


    ask gardeners [
      let Velocity-1C Velocity / 2  ; Gardeners move slower due to wet conditions
      ifelse leaves-possession > 0 [
        fd Velocity-1C
        set color black

      ][
        set color red

      ]
      set Gift 8
      set consumption 0.8
      set shareTime 40
    ]
  ]

  if weather = "stormy" [
    ask leaves [
      set interval 4
    ]

    ask gardeners [
      let Velocity-2C Velocity / 10   ; Gardeners move much slower
      ifelse leaves-possession > 0 [
        fd Velocity-2C
        set color violet
      ][
        set color red
      ]
      set gift 5
      set consumption 0.5
      set shareTime 60
    ]
  ]
end

to apply-weather-effects-in-seg

  if weather = "sunny" [
    ask leaves [
      set interval 2
    ]

    ask gardeners [
      move-within-bounds-and-avoid-walls -16 16 -16 16
      ifelse leaves-possession > 0 [
        fd Velocity ; Gardeners move with normal speed
        set color 21

      ][
        set color red

      ]
      set Gift 10
      set consumption 1
      set shareTime 30

    ]
  ]

  if weather = "rainy" and leaves-possession > 0 [
    ask leaves [
      set interval 3
    ]

    ask gardeners [
      move-within-bounds-and-avoid-walls -16 16 -16 16
      let Velocity-1S Velocity / 2 ; Gardeners move slower due to wet conditions
      ifelse leaves-possession > 0 [
        fd Velocity-1S
        set color Black
      ][
        set color red
      ]
      set gift 8
      set consumption 0.8
      set ShareTime 40
    ]
  ]

  if weather = "stormy" and leaves-possession > 0 [
    ask leaves [
      set interval 4
    ]

    ask gardeners [
      move-within-bounds-and-avoid-walls -16 16 -16 16
      Let Velocity-2S Velocity / 10  ; Gardeners move much slower
      ifelse leaves-possession > 0 [
        fd Velocity-2S
        set color violet
      ][
        set color red
      ]
      set gift 5
      set consumption 0.5
      set shareTime 60
    ]
  ]
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create-ready-leaves
  if ticks mod Interval = 0 [
    ask one-of leaves [ set color yellow ]  ; Change color of a leaf to yellow periodically
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RADIUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-radius-in-com
  let ready-leaves-in-r leaves with [color = yellow] in-radius Detection  ; Find leaves in radius
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r  ; Select a target leaf
    face target  ; Face the target leaf
    set leaves-seen leaves-seen + count ready-leaves-in-r  ; Update leaves seen count
  ]
end

to check-radius-in-seg

  ask gardeners [
    move-within-bounds-and-avoid-walls -16 16 -16 16
  ]

  let ready-leaves-in-r leaves with [color = yellow] in-radius Detection  ; Find leaves in radius
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r  ; Select a target leaf
    face target  ; Face the target leaf
    set leaves-seen leaves-seen + count ready-leaves-in-r  ; Update leaves seen count
  ]
end

to pluck-leaves-in-com
  let ready-leaves-in-r leaves with [color = yellow] in-radius Harvest  ; Find leaves in harvesting radius
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r  ; Select a target leaf
    if leaves-possession < max-leaves-possession [
      face target  ; Face the target leaf
      fd speed  ; Move to the target leaf
      harvest-leaf target  ; Harvest the target leaf
      set leaves-harvested leaves-harvested + 1  ; Update leaves harvested count
      set leaves-possession leaves-possession + 10  ; Update leaves possession count
    ]
  ]
end

to pluck-leaves-in-seg
  ask gardeners [
    move-within-bounds-and-avoid-walls -16 16 -16 16
  ]

  let ready-leaves-in-r leaves with [color = yellow] in-radius Harvest  ; Find leaves in harvesting radius
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r  ; Select a target leaf
    if leaves-possession < max-leaves-possession [
      face target  ; Face the target leaf
      fd speed
      harvest-leaf target  ; Harvest the target leaf
      set leaves-harvested leaves-harvested + 1  ; Update leaves harvested count
      set leaves-possession leaves-possession + 10  ; Update leaves possession count
      set harvesting-ticks 10  ; Set harvesting ticks
    ]
  ]

end

to harvest-leaf [target-leaf]
 if harvesting-ticks = 0 [
  ask target-leaf [ set color 57 ]  ; Change the color of the harvested leaf
  ]
end

to decrease-harvesting-ticks
  ask gardeners [
    if harvesting-ticks > 0 [
      set harvesting-ticks harvesting-ticks - 1  ; Decrease sharing ticks
    ]
  ]
end
to consume-leaves
  if leaves-possession > 0 [
    set leaves-possession leaves-possession - leaves-consumption-rate  ; Consume leaves
    set leaves-consumed leaves-consumed + leaves-consumption-rate  ; Update leaves consumed count
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EMOTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-happiness
  ask gardeners [
    if ticks mod 50 = 0 [
      ifelse leaves-harvested >= 1 or any? other gardeners with [color = original-color] in-radius 0.5 or any? leaves with [color = yellow] in-radius 0.1 [
        set happy true  ; Set happy to true
        set color original-color  ; Set color to original color
      ][
        set happy false  ; Set happy to false
        set color red  ; Set color to red
      ]
      set leaves-seen 0  ; Reset leaves seen
      set leaves-harvested 0  ; Reset leaves harvested
    ]
    ifelse happy [
      set happy-count happy-count + 1  ; Increase happy count
    ][
      set hungry-count hungry-count + 1  ; Increase hungry count
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; COLLISION & SHARING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-collision-in-com
  ask gardeners [
    if color != red [
      let hungry-gardener one-of other gardeners with [color = red] in-radius 0.5
      if hungry-gardener != nobody and sharing-ticks = 0 [
        set leaves-possession leaves-possession - Gift  ; Decrease leaves possession
        ask hungry-gardener [
          set leaves-possession leaves-possession + Gift  ; Increase leaves possession of hungry gardener
          set sharing-ticks ShareTime ; Prevent immediate re-sharing
        ]
      ]
    ]
  ]
end

to check-collision-in-seg
  ask gardeners [
    move-within-bounds-and-avoid-walls -16 16 -16 16
    if color != red [
      let hungry-gardener one-of other gardeners with [color = red] in-radius 0.5
      if hungry-gardener != nobody and sharing-ticks = 0 [
        set leaves-possession leaves-possession - Gift  ; Decrease leaves possession
        ask hungry-gardener [
          set leaves-possession leaves-possession + Gift  ; Increase leaves possession of hungry gardener
          set sharing-ticks ShareTime ; Prevent immediate re-sharing
        ]
      ]
    ]
  ]
end

to decrease-sharing-ticks
  ask gardeners [
    if sharing-ticks > 0 [
      set sharing-ticks sharing-ticks - 1  ; Decrease sharing ticks
    ]
  ]

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEAVES POSSESSION & SPEED ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-possession-status-in-com
  ask gardeners [

    if leaves-possession > 0 [
      set color 21
      fd Velocity   ; Stop movement

    ]
    if leaves-possession <= 0 [
      set color red ; Hungry and weak gardener

    ]
  ]
end

to check-possession-status-in-seg
  ask gardeners [
    move-within-bounds-and-avoid-walls -16 16 -16 16
    if leaves-possession > 0 [
      set color 21
      fd Velocity   ; Stop movement

    ]
    if leaves-possession <= 0 [
      set color red ; Hungry and weak gardener

    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DISPLAY LEAVES POSSESSION ;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-leaves-possession-label
  ask gardeners [
    set label precision leaves-possession 3  ; Display leaves possession to 2 decimal places
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; REPORTER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Happy gardeners reporter
to-report happy-gardeners-count
  report count gardeners with [leaves-possession > 2]
end

;; Hungry gardeners reporter
to-report hungry-gardeners-count
  report count gardeners with [leaves-possession <= 2]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LOCATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to location
  if (rule = "Commoning") [ com-position ]
  if (rule = "Segregation") [ seg-position ]
end

to com-position
  ask gardeners [
    setxy random-xcor random-ycor  ; Position gardeners randomly
  ]
end

to seg-position
  ask turtle 0 [ setxy -4 -4 ]
  ask turtle 1 [ setxy -12 -8 ]
  ask turtle 2 [ setxy -8 -0.7 ]
  ask turtle 3 [ setxy 8 -10 ]
  ask turtle 4 [ setxy 13 -2 ]
  ask turtle 5 [ setxy 8 -4 ]
  ask turtle 6 [ setxy 2 -9 ]
  ask turtle 7 [ setxy -4 8 ]
  ask turtle 8 [ setxy -7 11 ]
  ask turtle 9 [ setxy 6 14 ]
  ask turtle 10 [ setxy 10 12 ]
  ask turtle 11 [ setxy 4 6 ]
end
<<<<<<< HEAD
=======
@#$#@#$#@
GRAPHICS-WINDOW
212
10
649
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

CHOOSER
429
577
614
622
Rule
Rule
"Commoning" "Segregation"
1

BUTTON
64
10
134
59
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
135
10
210
59
NIL
go\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
10
63
59
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
144
207
177
Detection
Detection
0
16
5.0
1
1
NIL
HORIZONTAL

SLIDER
0
216
206
249
Harvest
Harvest
0
5
1.2
0.1
1
NIL
HORIZONTAL

PLOT
657
10
1121
208
Ready Leaves
Time (ticks)
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Ready Leaves" 1.0 2 -1184463 false "" "plot count leaves with [color = yellow]"

SLIDER
0
290
205
323
Interval
Interval
0
20
4.0
1
1
NIL
HORIZONTAL

PLOT
657
244
1121
424
New leaves
Time (ticks)
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"New leaves" 1.0 2 -10899396 true "" "plot count leaves with [color = 57]"

TEXTBOX
657
208
1125
234
This plot tracks the number of leaves in different states (e.g., new leaves, ready leaves) over time. It helps in understanding how the availability of leaves changes as the gardeners work.
10
0.0
1

TEXTBOX
660
424
1116
449
This plot tracks the number of gardeners that are actively harvesting versus those that are moving around.
10
0.0
1

TEXTBOX
662
626
1113
650
This plot tracks the average number of harvesting ticks remaining for all gardeners, providing insight into how busy they are over time.
10
0.0
1

TEXTBOX
432
623
582
641
Choose Rule
11
0.0
1

TEXTBOX
2
178
197
220
Set radius for gardeners to notice ready leaves and go for them
11
0.0
1

TEXTBOX
2
250
188
279
Set radius for gardeners to reach ready leaves and pluck them
11
0.0
1

TEXTBOX
2
326
216
358
Set in ticks the multiples of the number for ready plants reoccurance 
11
0.0
1

PLOT
1121
10
1418
208
Hungry
Time (ticks)
Hunger Rate
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Hunger Rate " 1.0 0 -2674135 false "" "plot count gardeners with [leaves-possession <= 2]"

PLOT
1123
244
1416
423
Happy
Time (ticks)
Happiness
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Happy" 1.0 0 -8990512 true "" "plot count gardeners with [leaves-possession > 2]"

MONITOR
223
461
412
506
Happy
happy-gardeners-count
17
1
11

MONITOR
425
461
639
506
Hungry
hungry-gardeners-count
17
1
11

SLIDER
0
368
202
401
Area1
Area1
0
100
30.0
5
1
NIL
HORIZONTAL

SLIDER
0
408
201
441
Area2
Area2
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
0
448
200
481
Area3
Area3
0
100
18.0
1
1
NIL
HORIZONTAL

SLIDER
0
489
202
522
TotalGardeners
TotalGardeners
0
50
12.0
1
1
NIL
HORIZONTAL

SLIDER
1
530
203
563
Proximity
Proximity
0
50
5.0
1
1
NIL
HORIZONTAL

SLIDER
245
600
417
633
Velocity
Velocity
0
2
0.1
0.00005
1
NIL
HORIZONTAL

SLIDER
245
525
417
558
Gift
Gift
0
20
5.0
0.1
1
NIL
HORIZONTAL

SLIDER
245
561
417
594
Consumption
Consumption
0
5
0.5
0.1
1
NIL
HORIZONTAL

TEXTBOX
7
567
157
595
Raduis to dictect hungry gardners
11
0.0
1

PLOT
659
452
1123
625
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Happy" 1.0 0 -4757638 true "" "plot count gardeners with [leaves-possession > 2]"
"Hungry" 1.0 0 -7500403 true "" "plot count gardeners with [leaves-possession <= 2]"

CHOOSER
429
525
612
570
weather
weather
"sunny" "rainy" "stormy"
2

SLIDER
0
601
202
634
ShareTime
ShareTime
0
100
60.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
# Gardener Simulation Model

## Overview

This NetLogo model simulates the behavior of gardeners in a garden as they harvest and consume leaves. The gardeners interact with the environment by moving around, harvesting leaves, and sharing them with other gardeners. The simulation explores two different rules of movement: **Commoning** and **Segregation**.

## Features

- **Gardeners**: Agents that move around the environment, harvest leaves, and consume them. Gardeners can be in various states, such as happy, hungry, or weak, depending on their possession of leaves.
- **Leaves**: Resources that gardeners harvest. Leaves are periodically created and can change color when they are ready to be harvested.
  - **Commoning**: Gardeners move in a way that encourages clustering and collective resource sharing.
  - **Segregation**: Gardeners move in a way that promotes separation, reducing interaction with others.
- **Happiness and Sharing**: Gardeners' happiness is influenced by their possession of leaves and their proximity to other gardeners. Gardeners can share leaves with others if they encounter hungry gardeners.

## Setup and Usage

### Parameters

- `TotalGardeners`: Number of gardeners in the simulation.
- `Velocity`: Speed at which gardeners move.
- `Consumption`: Rate at which gardeners consume leaves.
- `Area1`, `Area2`, `Area3`: Number of leaves generated in different garden areas.
- `Dictection`, `Harvest`, `Proximity`: Radius values defining the range in which gardeners detect leaves or interact with other gardeners.
- `Gift`: Number of leaves shared when a gardener encounters a hungry gardener.
- `Interval`: Mutiple for creating new leaves.

### How to Run

1. **Setup**: Press the `setup` button to initialize the environment. This will create gardeners and leaves, set initial conditions, and prepare the environment.
2. **Go**: Press the `go` button to start the simulation. The gardeners will begin moving, harvesting leaves, and interacting with each other according to the selected movement rule.

### Movement Rules

- To switch between **Commoning** and **Segregation**:
  - Set the `rule` variable to `"Commoning"` or `"Segregation"` before running the simulation.
  - The gardeners will adjust their movement patterns accordingly.

### Key Procedures

- `move`: Handles the movement of gardeners according to the selected rule.
- `pluck-leaves-in-commoning` and `pluck-leaves-in-segregation`: Control how gardeners detect and harvest leaves in commoning or segregation movement modes.
- `check-happiness`: Determines the happiness state of gardeners based on their leaf possession and proximity to other gardeners or leaves.
- `check-collision-in-commoning` and `check-collision-in-segregation`: Manage interactions between gardeners, including the sharing of leaves.

## Customization

- **Gardener Behavior**: Modify the `consume-leaves`, `check-possession-status-in-commoning`, and `check-possession-status-in-segregation` procedures to change how gardeners consume leaves and transition between states (e.g., happy, hungry).
- **Environment**: Adjust the `space` procedure to change the layout of the environment, including the distribution of green and brown patches.
- **Leaf Creation**: Modify the `creating-leaves` procedure to change how and where leaves are generated in the environment.

## Visual Output

- The model includes labels that display the number of leaves each gardener possesses.
- The simulation also plots the average time (ticks) it takes for gardeners to harvest leaves over time.

## Contact

For any questions or support, please contact Favour Chizurum Onuoha at dovo.fav@aol.com
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="P2leaves">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Closeness">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="multiple">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NofGardeners">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P3leaves">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Harvest">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Rule">
      <value value="&quot;Commoning&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="P1leaves">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
>>>>>>> efa44fc (updated my model)

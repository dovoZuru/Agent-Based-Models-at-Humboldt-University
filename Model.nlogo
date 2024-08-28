breed [gardeners gardener]  ; Define the gardener breed
breed [leaves leaf]  ; Define the leaf breed

globals [happy-count hungry-count max-leaves-possession leaves-consumption-rate]  ; Define global variables

gardeners-own [harvesting-ticks leaves-seen leaves-harvested happy original-color leaves-possession leaves-consumed sharing-ticks speed]  ; Define variables specific to gardeners
leaves-own [previous-color]  ; Define variables specific to leaves

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP & GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all  ; Clear the world
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
    set leaves-possession 10  ; Initialize leaves possession to 20
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
  update-average-harvesting-ticks-plot  ; Update the plot for average harvesting ticks
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-average-harvesting-ticks-plot
  set-current-plot "Harvesting"  ; Select the plot
  set-current-plot-pen "Harvesting Ticks"  ; Select the pen
  if any? gardeners [
    plot mean [harvesting-ticks] of gardeners  ; Plot the mean harvesting ticks
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
    move-within-bounds-and-avoid-walls -16 16 -16 16  ; Move and avoid walls within bounds
    ;fd fdSpeed
    check-possession-status-in-seg
    check-for-red-gardeners-in-seg
    check-collision-in-seg
    check-radius-in-seg
    pluck-leaves-in-seg

  ]
  if (rule = "Commoning") [
    check-for-red-gardeners-in-com
    check-radius-in-com
    pluck-leaves-in-com
    check-collision-in-com
    avoid-walls  ; Avoid walls
    check-possession-status-in-com
    ;fd fdSpeed
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
    ;fd fdSpeed  ; Move forward with variable speed
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
  if (color = 21 or color = black) [
    let hungry-gardeners-in-radius gardeners with [color = red] in-radius Proximity
    if any? hungry-gardeners-in-radius[
      let target one-of hungry-gardeners-in-radius
      face target
      move-within-bounds-and-avoid-walls -16 16 -16 16
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
  let ready-leaves-in-r leaves with [color = yellow] in-radius Detection  ; Find leaves in radius
  if any? ready-leaves-in-r [
    move-within-bounds-and-avoid-walls -16 16 -16 16
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
    move-within-bounds-and-avoid-walls -16 16 -16 16
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
          set sharing-ticks 30 ; Prevent immediate re-sharing
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
          set sharing-ticks 30 ; Prevent immediate re-sharing
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
    if leaves-possession > 20 [
      set color 21 ; Rich gardener
      fd Speed

    ]
    if leaves-possession <= 20 and leaves-possession >= 10 [
      set color 21 ; Average gardener
      fd Speed

    ]
    if leaves-possession < 10 and leaves-possession > 2 [
      set color 21 ; Average gardener
      fd Speed

    ]
    if leaves-possession <= 2 and leaves-possession > 0 [
      set color black ; Hungry gardener
      fd Speed   ; Stop movement

    ]
    if leaves-possession <= 0 [
      set color red ; Hungry and weak gardener

    ]
  ]
end

to check-possession-status-in-seg
  ask gardeners [
    if leaves-possession > 20 [
      set color 21 ; Rich gardener
      fd Speed
      move-within-bounds-and-avoid-walls -16 16 -16 16
    ]
    if leaves-possession <= 20 and leaves-possession >= 10 [
      set color 21 ; Average gardener
      fd Speed
      move-within-bounds-and-avoid-walls -16 16 -16 16
    ]
    if leaves-possession < 10 and leaves-possession > 2 [
      set color 21 ; Average gardener
      fd Speed
      move-within-bounds-and-avoid-walls -16 16 -16 16
    ]
    if leaves-possession <= 2 and leaves-possession > 0 [
      set color black ; Hungry gardener
      fd Speed
      move-within-bounds-and-avoid-walls -16 16 -16 16
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

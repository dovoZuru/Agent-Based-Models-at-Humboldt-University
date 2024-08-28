breed [gardeners gardener]
breed [leaves leaf]

globals [happy-count hungry-count max-leaves-possession leaves-consumption-rate]

gardeners-own [harvesting-ticks leaves-seen leaves-harvested happy original-color leaves-possession leaves-consumed sharing-ticks]
leaves-own [previous-color]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP & GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set max-leaves-possession 20
  set leaves-consumption-rate 0.1
  set-default-shape gardeners "person"
  set-default-shape leaves "leaf"
  create-gardeners NofGardeners [
    set color 21
    set size 2.5
    set leaves-seen 0
    set leaves-harvested 0
    set happy false
    set original-color 21
    set leaves-possession 0
    set leaves-consumed 0
    set sharing-ticks 0
  ]
  space
  location
  creating-leaves
  reset-ticks
end

to go
  ask gardeners [
    ifelse harvesting-ticks = 0 [
      move
      check-radius
      pluck-leaves
      check-collision
      consume-leaves
      check-possession-status
    ][
      set harvesting-ticks harvesting-ticks - 1
    ]
  ]
  check-happiness
  create-ready-leaves
  update-average-harvesting-ticks-plot
  decrease-sharing-ticks
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;; INITIALS PROCEDURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to space
  ask patches [
    ifelse (pxcor <= 16 and pycor >= 5) or
           (pxcor <= -2 and pycor <= 3) or
           (pxcor >= 0 and pycor <= 3)
    [
      set pcolor green
    ]
    [
      set pcolor brown
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-average-harvesting-ticks-plot
  set-current-plot "Average Harvesting Ticks"
  set-current-plot-pen "Harvesting Ticks"
  if any? gardeners [
    plot mean [harvesting-ticks] of gardeners
  ] plot 0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CREATE PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to creating-leaves
  create-leaves P1leaves [
    set color 57
    set previous-color color
    set size 1.5
    let x (random-float 32) - 16
    let y (random-float 10) - (-6)
    setxy x y
  ]

  create-leaves P2leaves [
    set color 57
    set previous-color color
    set size 1.5
    let x (random-float 16) - 0
    let y (random-float 19) - 16
    setxy x y
  ]

  create-leaves P3leaves [
    set color 57
    set previous-color color
    set size 1.5
    let x (random-float 13.5) - 16
    let y (random-float 19) - 16
    setxy x y
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MOVEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move
  if (rule = "Segregation") [
    move-within-bounds-and-avoid-walls -16 16 -16 16
  ]
  if (rule = "Commoning") [
    fd 0.5
    avoid-walls
  ]
end

to move-within-bounds-and-avoid-walls [min-x max-x min-y max-y]
  let heading-before heading
  fd 0.5
  if (xcor <= (min-x + 0.8) or xcor >= (max-x - 0.8) or ycor <= (min-y + 0.8) or ycor >= (max-y - 0.8) or [pcolor] of patch-ahead 1 = brown) [
    set heading heading-before + 180
    fd 0.5
  ]
end

to avoid-walls
  if (xcor <= min-pxcor + 1.4) or (xcor >= max-pxcor - 1.4) or (ycor <= min-pycor + 1.4) or (ycor >= max-pycor - 1.4) [
    set heading heading + 60
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create-ready-leaves
  if ticks mod multiple = 0 [
    ask one-of leaves [ set color yellow ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RADIUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-radius
  let ready-leaves-in-r leaves with [color = yellow] in-radius Closeness
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    face target
    set leaves-seen leaves-seen + count ready-leaves-in-r
  ]
end

to pluck-leaves
  let ready-leaves-in-r leaves with [color = yellow] in-radius Harvest
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    if leaves-possession < max-leaves-possession [
      face target
      move-to target
      harvest-leaf target
      set leaves-harvested leaves-harvested + 1
      set leaves-possession leaves-possession + 1
    ]
  ]
end

to harvest-leaf [target-leaf]
  ask target-leaf [ set color 57 ]
  set harvesting-ticks 20
end

to consume-leaves
  if leaves-possession > 0 [
    set leaves-possession leaves-possession - leaves-consumption-rate
    set leaves-consumed leaves-consumed + leaves-consumption-rate
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EMOTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-happiness
  ask gardeners [
    if ticks mod 50 = 0 [
      ifelse leaves-harvested >= 1 or any? other gardeners with [color = original-color] in-radius 0.5 or any? leaves with [color = yellow] in-radius 0.1 [
        set happy true
        set color original-color
      ][
        set happy false
        set color red
      ]
      set leaves-seen 0
      set leaves-harvested 0
    ]
    ifelse happy [
      set happy-count happy-count + 1
    ][
      set hungry-count hungry-count + 1
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; COLLISION & SHARING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-collision
  ask gardeners [
    if color != red [
      let hungry-gardener one-of other gardeners with [color = red] in-radius 0.5
      if hungry-gardener != nobody and leaves-possession > 0 and sharing-ticks = 0 [
        set leaves-possession leaves-possession - 1
        ask hungry-gardener [
          set leaves-possession leaves-possession + 1
          set sharing-ticks 20 ; to prevent immediate re-sharing
        ]
        set sharing-ticks 20 ; to prevent immediate re-sharing
      ]
    ]
  ]
end

to decrease-sharing-ticks
  ask gardeners [
    if sharing-ticks > 0 [
      set sharing-ticks sharing-ticks - 1
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LEAVES POSSESSION STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-possession-status
  ask gardeners [
    if leaves-possession > 20 [
      set color 21 ; rich gardener
    ]
    if leaves-possession <= 20 and leaves-possession >= 10 [
      set color 21 ; average gardener
    ]
    if leaves-possession < 10 and leaves-possession >= 2 [
      set color black ; average gardener
    ]
    if leaves-possession < 2 and leaves-possession >= 0 [
      set color red ; hungry gardener
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LOCATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to location
  if (rule = "Commoning") [ com-position ]
  if (rule = "Segregation") [ seg-position ]
end

to com-position
  ask gardeners [
    setxy random-xcor random-ycor
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
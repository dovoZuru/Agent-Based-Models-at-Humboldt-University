breed [gardeners gardener]
breed [leaves leaf]

globals [leaves-harvested-last-tick]


gardeners-own [harvesting-ticks]
leaves-own [previous-color]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP & GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape gardeners "person"
  set-default-shape leaves "leaf"
  create-gardeners 12 [
    set color 21
    set size 2.5
    set harvesting-ticks 0
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
    ][
      set harvesting-ticks harvesting-ticks - 1
    ]
  ]
  create-ready-leaves
  update-average-harvesting-ticks-plot
  plot-leaf-harvest-rate


  
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



to plot-leaf-harvest-rate
  let harvested-leaves count leaves with [color = 57 and previous-color = yellow]
  update-leaf-harvest-rate-plot
  set leaves-harvested-last-tick harvested-leaves

  ask leaves with [color = 57] [
    set previous-color 57
  ]
end

to update-leaf-harvest-rate-plot
  set-current-plot "Leaf Harvest Rate"
  set-current-plot-pen "Harvest Rate"
  plot leaves-harvested-last-tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CREATE PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to creating-leaves
  create-leaves 30 [
    set color 57
    set previous-color color
    set size 1.5
    let x (random-float 32) - 16
    let y (random-float 10) - (-6)
    setxy x y
  ]

  create-leaves 20 [
    set color 57
    set previous-color color
    set size 1.5
    let x (random-float 16) - 0
    let y (random-float 19) - 16
    setxy x y
  ]

  create-leaves 18 [
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
  ]
end

to pluck-leaves
  let ready-leaves-in-r leaves with [color = yellow] in-radius Harvest
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    face target
    move-to target
    harvest-leaf target
  ]
end

to harvest-leaf [target-leaf]
  ask target-leaf [ set color 57 ]
  set harvesting-ticks 20
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
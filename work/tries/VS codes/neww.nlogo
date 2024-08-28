to check-radius
  let ready-leaves-in-r leaves with [color = yellow] in-radius Closeness
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    face target
    set leaves-seen leaves-seen + count ready-leaves-in-r
  ]
end

to pluck-leaves
  let ready-leaves-in-r leaves with [color = yellow] in-radius harvest
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    face target
    move-to target
    harvest-leaf target
    set leaves-harvested leaves-harvested + 1
  ]
end










to check-happiness
  ask gardeners [
    if ticks mod 5 = 0 [
      if leaves-harvested >= 5 [
        set happy true
      ] else [
        set happy false
      ]
      ; Reset counters
      set leaves-seen 0
      set leaves-harvested 0
    ]
  ]
end




to update-happiness-plot
  set-current-plot "Gardeners' Happiness"
  set-current-plot-pen "Happy"
  plot count gardeners with [happy]

  set-current-plot-pen "Sad"
  plot count gardeners with [not happy]
end




to go
  let harvested-leaves count leaves with [color = 57 and previous-color = yellow]
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

  ; Update plots
  update-leaves-plot
  update-gardeners-activity-plot
  update-average-harvesting-ticks-plot
  update-leaf-harvest-rate-plot
  check-happiness
  update-happiness-plot

  set leaves-harvested-last-tick harvested-leaves

  ; Reset previous color tracking
  ask leaves with [color = 57] [
    set previous-color color
  ]

  tick
end




breed [gardeners gardener]
breed [leaves leaf]

gardeners-own [harvesting-ticks leaves-seen leaves-harvested happy]
leaves-own [previous-color]

globals [leaves-harvested-last-tick]

to setup
  clear-all
  set-default-shape gardeners "person"
  set-default-shape leaves "leaf"
  create-gardeners 12 [
    set color 21
    set size 2.5
    set harvesting-ticks 0
    set leaves-seen 0
    set leaves-harvested 0
    set happy false
  ]
  space
  location
  creating-leaves
  reset-ticks
end

to go
  let harvested-leaves count leaves with [color = 57 and previous-color = yellow]
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

  ; Update plots
  update-leaves-plot
  update-gardeners-activity-plot
  update-average-harvesting-ticks-plot
  update-leaf-harvest-rate-plot
  check-happiness
  update-happiness-plot

  set leaves-harvested-last-tick harvested-leaves

  ; Reset previous color tracking
  ask leaves with [color = 57] [
    set previous-color color
  ]

  tick
end

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

to plot-leaves
  let new leaves with [color = 57]
  let ready leaves with [color = yellow]
end

to create-ready-leaves
  if ticks mod multiples-of = 0 [
    ask one-of leaves [ set color yellow ]
  ]
end

to check-radius
  let ready-leaves-in-r leaves with [color = yellow] in-radius Closeness
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    face target
    set leaves-seen leaves-seen + count ready-leaves-in-r
  ]
end

to pluck-leaves
  let ready-leaves-in-r leaves with [color = yellow] in-radius harvest
  if any? ready-leaves-in-r [
    let target one-of ready-leaves-in-r
    face target
    move-to target
    harvest-leaf target
    set leaves-harvested leaves-harvested + 1
  ]
end

to harvest-leaf [target-leaf]
  ask target-leaf [
    set previous-color color
    set color 57
  ]
  set harvesting-ticks 20
end

to get-hungry
  if (ready-leaves-in-r = nobody and ticks mod 1 = 0 ) [
    ask myself [set color red]
  ]
end

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

to check-happiness
  ask gardeners [
    if ticks mod 5 = 0 [
      if leaves-harvested >= 5 [
        set happy true
      ] else [
        set happy false
      ]
      ; Reset counters
      set leaves-seen 0
      set leaves-harvested 0
    ]
  ]
end

to update-leaves-plot
  set-current-plot "Leaves Status"
  set-current-plot-pen "New Leaves"
  plot count leaves with [color = 57]

  set-current-plot-pen "Ready Leaves"
  plot count leaves with [color = yellow]
end

to update-gardeners-activity-plot
  set-current-plot "Gardeners' Activity"
  set-current-plot-pen "Active Harvesting"
  plot count gardeners with [harvesting-ticks > 0]

  set-current-plot-pen "Searching for Leaves"
  plot count gardeners with [harvesting-ticks = 0]
end

to update-average-harvesting-ticks-plot
  set-current-plot "Average Harvesting Ticks"
  set-current-plot-pen "Harvesting Ticks"
  if any? gardeners [
    plot mean [harvesting-ticks] of gardeners
  ] [plot 0]
end

to update-leaf-harvest-rate-plot
  set-current-plot "Leaf Harvest Rate"
  set-current-plot-pen "Harvest Rate"
  plot leaves-harvested-last-tick
end

to update-happiness-plot
  set-current-plot "Gardeners' Happiness"
  set-current-plot-pen "Happy"
  plot count gardeners with [happy]

  set-current-plot-pen "Sad"
  plot count gardeners with [not happy]
end

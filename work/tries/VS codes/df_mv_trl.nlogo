turtles-own [ buddy_a buddy_b initial-color initial-shape wall-timer move-timer turtle-eaten wall-reached ]

;globals [ wall-reached ]
breed [ happy-faces happy-face ]
breed [ neutral-faces neutral-face ]
breed [ sad-faces sad-face ]

to setup
  clear-all
  setup-patches

  lets-hatch-happy-faces
  lets-hatch-neutral-faces
  lets-hatch-sad-faces

  initialize-plots
  reset-ticks
end

to lets-hatch-happy-faces
  create-happy-faces random 10 [
    set size 1.5
    set shape "face happy"
    set color yellow
    set initial-color yellow
    set initial-shape "face happy"
    avoid-wall
    set buddy_a one-of other turtles
    set buddy_b one-of other turtles
    set wall-reached false
  ]
end

to lets-hatch-neutral-faces
  create-neutral-faces random 10 [
    set size 1.5
    set shape "face neutral"
    set color gray
    set initial-color gray
    set initial-shape "face neutral"
    avoid-wall
    ;setxy random-xcor random-ycor
    set buddy_a one-of other turtles
    set buddy_b one-of other turtles
    set wall-reached false
  ]
end

to lets-hatch-sad-faces
  create-sad-faces random 10 [
    set size 1.5
    set shape "face sad"
    set color blue
    set initial-color blue
    set initial-shape "face sad"
    avoid-wall
    ;setxy random-xcor random-ycor
    set buddy_a one-of other turtles
    set buddy_b one-of other turtles
    set wall-reached false
  ]
end

to setup-patches
  ask patches [
    set pcolor white
  ]
end

to avoid-wall
  let x (random-float (max-pxcor - 2) - (max-pxcor / 2 - 1))
  let y (random-float (max-pycor - 2) - (max-pycor / 2 - 1))
  setxy x y
end

to initialize-plots
  set-current-plot "Face Counts"
  set-current-plot-pen "face happy"
  set-plot-pen-color yellow
  set-current-plot-pen "face neutral"
  set-plot-pen-color gray
  set-current-plot-pen "face sad"
  set-plot-pen-color blue
end

to go
  ask turtles [
    if breed = happy-faces [
      go-between
    ]
    if breed = neutral-faces [
      go-behind
    ]
    if breed = sad-faces [
      go-behind
    ]
    check-wall
    collision
    update-state
  ]
  modify-plots
  tick
end

to check-wall
  if (xcor >= max-pxcor or xcor <= min-pxcor or ycor >= max-pycor or ycor <= min-pycor) [
    set wall-reached true
    react-to-wall
  ]
end

to go-between
  if not wall-reached [
    facexy ([xcor] of buddy_a + [xcor] of buddy_b) / 2
           ([ycor] of buddy_a + [ycor] of buddy_b) / 2
    collision
    fd 0.1
    check-wall
    ;react-to-wall
  ]
end

to go-behind
  if not wall-reached [
    facexy [xcor] of buddy_a + ([xcor] of buddy_a - [xcor] of buddy_b) / 2
           [ycor] of buddy_a + ([ycor] of buddy_a - [ycor] of buddy_b) / 2
    collision
    fd 0.1
    check-wall
    ;react-to-wall
  ]
end

to react-to-wall
  set color red

  if (member? shape ["face happy" "face neutral"]) [
    set shape "face sad"
  ]

  update-state
  collisionreaction

  fd 0.1
end


to collision
  ask other turtles in-radius (size) [
    collisionreaction
    ask myself [ collisionreaction ]
  ]
end

to collisionreaction
  right 45
end

to update-state
  if wall-timer > 0 [
    set wall-timer wall-timer - 1
    if wall-timer = 0 [
      set color initial-color
      set shape initial-shape
    ]
  ]
end

to modify-plots
  set-current-plot "Face Counts"
  set-current-plot-pen "face happy"
  plot count happy-faces
  set-current-plot-pen "face neutral"
  plot count neutral-faces
  set-current-plot-pen "face sad"
  plot count sad-faces
end

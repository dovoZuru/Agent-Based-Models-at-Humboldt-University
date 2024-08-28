turtles-own [ friend_a friend_b initial-color initial-shape wall-timer move-timer ]

directed-link-breed [black-links black-link]
directed-link-breed [green-links green-link]
directed-link-breed [pink-links pink-link]

globals [numred numblue wall-reached]

breed [happy-faces happy-face]
breed [neutral-faces neutral-face]
breed [sad-faces sad-face]

to setup
  clear-all
  setup-patches
  create-happy-faces 10 [
    set shape "face happy"
    set color yellow
    set initial-color yellow
    set initial-shape "face happy"
    setxy random-xcor random-ycor
    set friend_a one-of other turtles
    set friend_b one-of other turtles
    set move-timer random 10
  ]
  create-neutral-faces 10 [
    set shape "face neutral"
    set color gray
    set initial-color gray
    set initial-shape "face neutral"
    setxy random-xcor random-ycor
    set friend_a one-of other turtles
    set friend_b one-of other turtles
    set move-timer random 10
  ]
  create-sad-faces 10 [
    set shape "face sad"
    set color blue
    set initial-color blue
    set initial-shape "face sad"
    setxy random-xcor random-ycor
    set friend_a one-of other turtles
    set friend_b one-of other turtles
    set move-timer random 10
  ]
  reset-ticks
  set wall-reached false
end

to setup-patches
  ask patches [
    set pcolor white
  ]
end

to go
  ask turtles [
    if color = yellow [
      go-between
    ]
    if color = gray [
      go-between
    ]
    if color = blue [
      go-behind
    ]
    check-wall
    collision
    update-state
  ]
  tick
end

to check-wall
  if (xcor >= max-pxcor or xcor <= min-pxcor or ycor >= max-pycor or ycor <= min-pycor) [
    set wall-reached true
    react-to-wall
  ]
end

to react-to-wall
  set color red
  if (member? breed ["happy-faces" "neutral-faces"]) [
    set breed sad-faces
    set shape "face sad"
  ]
  set wall-timer 5
  set heading heading + 180
  fd 1
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

to influence-others
  ask turtles in-radius 1 with [breed != happy-faces] [
    set breed happy-faces
    set shape "face happy"
  ]
end

to collision
  ask other turtles in-radius 1 [
    collisionreaction
    ask myself [collisionreaction]
  ]
end

to collisionreaction
  right 90
end

to go-between
  if not wall-reached and move-timer = 0 [
    facexy ([xcor] of friend_a + [xcor] of friend_b) / 2
           ([ycor] of friend_a + [ycor] of friend_b) / 2
    collision
    fd 0.1
    check-wall
    set move-timer random 10 ;; Reset move-timer to a random value
  ]
  if not wall-reached and move-timer > 0 [
    set move-timer move-timer - 1   ;; Decrease move-timer if not yet zero
  ]
end

to go-behind
  if not wall-reached and move-timer = 0 [
    facexy [xcor] of friend_a + ([xcor] of friend_a - [xcor] of friend_b) / 2
           [ycor] of friend_a + ([ycor] of friend_a - [ycor] of friend_b) / 2
    collision
    fd 0.1
    check-wall
    set move-timer random 10 ;; Reset move-timer to a random value
  ]
  if not wall-reached and move-timer > 0 [
    set move-timer move-timer - 1   ;; Decrease move-timer if not yet zero
  ]
end

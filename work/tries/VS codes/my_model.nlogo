globals [wall-reached] 

breed [happy-faces happy-face]
breed [neutral-faces neutral-face]
breed [sad-faces sad-face]

turtles-own [friend_a friend_b initial-color initial-shape wall-timer] 


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
  ]
  create-neutral-faces 10 [  
    set shape "face neutral"
    set color gray
    set initial-color gray
    set initial-shape "face neutral"
    setxy random-xcor random-ycor
    set friend_a one-of other turtles 
    set friend_b one-of other turtles 
  ]
  create-sad-faces 10 [
    set shape "face sad"
    set color blue
    set initial-color blue
    set initial-shape "face sad"
    setxy random-xcor random-ycor 
    set friend_a one-of other turtles 
    set friend_b one-of other turtles 
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
  ask happy-faces [
    move
    check-wall
    collision
    update-state
  ]
  ask neutral-faces [
    move
    check-wall
    collision
    update-state
  ]
  ask sad-faces [
    move
    check-wall
    collision
    update-state
    influence-others
  ]
  tick
end

to move
  fd 1
end

to check-wall
  if (xcor >= max-pxcor or xcor <= min-pxcor or ycor >= max-pycor or ycor <= min-pycor) [
    set wall-reached true
    react-to-wall
  ]
end

to react-to-wall
  set color red

  if (member? shape ["face happy" "face neutral"]) [
    set shape "face sad"
  ]

  set wall-timer 5

  set heading heading + 180
  fd 1
end

to update-state
  if (wall-timer > 0) [
    set wall-timer wall-timer - 1
    if (wall-timer = 0) [
      set color initial-color
      set shape initial-shape
    ]
  ]
end

to influence-others
  ask turtles in-radius 0.5 with [shape = "face neutral" or shape = "face sad"] [
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

to wallcollide
  right 180
end

to go-between
  facexy ([xcor] of friend_a + [xcor] of friend_b) / 2  
         ([ycor] of friend_a + [ycor] of friend_b) / 2  
  fd 1
end

to go-beside
  facexy [xcor] of friend_a + ([xcor] of friend_a - [xcor] of friend_b) / 2
         [ycor] of friend_a + ([ycor] of friend_a - [ycor] of friend_b) / 2
  fd 1
end
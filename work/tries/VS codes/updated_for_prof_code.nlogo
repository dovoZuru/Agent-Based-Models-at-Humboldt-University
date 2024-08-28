turtles-own [ friend_a friend_b wall-reached move-timer] ;; an agent has two properties: friend_a, friend_b, and wall-reached

directed-link-breed [black-links black-link]
directed-link-breed [green-links green-link]
directed-link-breed [pink-links pink-link]

;; build the world
to setup
  clear-all   ;; clear the universe
  ask patches [ set pcolor white ]   ;; ask the world to be white
  set-default-shape links "sm"
  create-turtles numberall [    ;; create 'number' of agents, and ask each agent to do the following
    set shape "default"
    set size 1.5
    ;;set move-timer random 30 ;;set on a random no.
    ;; Spread out turtles avoiding edges
    let x (random-float (max-pxcor - 2) - (max-pxcor / 2 - 1))
    let y (random-float (max-pycor - 2) - (max-pycor / 2 - 1))
    setxy x y

    set wall-reached false           ;; initialize wall-reached to false
    if (personalities = "between-blue")     [ set color blue ]      ;; if agent goes in-between, color it blue
    if (personalities = "behind-red")  [ set color red ]         ;; if agent goes behind, color it red
    if (personalities = "mixed")     [ set color one-of [ red blue ] ]  ;; if agents are mixed, color it either color above
    if (personalities = "set-reds")     [ inputnumred ]
    if (personalities = "set-blues")     [ inputnumblue ]

    set friend_a one-of other turtles ;; make another turtle to friendA
    set friend_b one-of other turtles ;; make another turtle to friendB
    
    if (visualization = "on") [
      create-black-link-from friend_a [set color green]
      create-green-link-from friend_b [set color pink]
    ]
  ]
  reset-ticks    ;; put clock back to 0
end

to inputnumred
  ifelse who < numred
    [ set color red ]
    [ set color blue ]
end

to inputnumblue
  ifelse who < numblue
    [ set color blue ]
    [ set color red ]
end

;; running the world
to go
  ask turtles [   ;; ask every agent to do the following
    ifelse color = blue [
      go-between
    ] [
      if color = red [
        go-behind
      ]
    ]
  ]
  tick  ;; the clock is ticking
end


to check-wall
  if (xcor >= max-pxcor or xcor <= min-pxcor or ycor >= max-pycor or ycor <= min-pycor) [
    set wall-reached true
  ]
end

to go-between
  if not wall-reached ;and move-timer = 0 
  [
    facexy ([xcor] of friend_a + [xcor] of friend_b) / 2
           ([ycor] of friend_a + [ycor] of friend_b) / 2
    collision
    fd 0.1
    check-wall
  ]
  ;if not wall-reached ;and move-timer > 0 
  ;[
    ;set move-timer move-timer - 1   ;; Decrease move-timer if not yet zero
  ;]
end

to go-behind
  if not wall-reached ;and move-timer = 0 
  [
    facexy [xcor] of friend_a + ([xcor] of friend_a - [xcor] of friend_b) / 2
           [ycor] of friend_a + ([ycor] of friend_a - [ycor] of friend_b) / 2
    collision
    fd 0.1
    check-wall
  ]
  ;if not wall-reached and move-timer > 0 [
  ;  set move-timer move-timer - 1   ;; Decrease move-timer if not yet zero
  ;]
end


to collision
  ask other turtles in-radius (size) [
    collisionreaction
    ask myself [collisionreaction]
  ]
end

to collisionreaction
  right 45
end
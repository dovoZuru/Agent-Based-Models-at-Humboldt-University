breed [gardeners gardener]
breed [leaves leaf]

gardeners-own [reviving-ticks]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP & GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape gardeners "person"
  set-default-shape leaves "leaf"
  create-gardeners 12 [
    set color 21
    set size 2.5
    set reviving-ticks 0
  ]
  space
  location
  creating-plants
  reset-ticks
end

to go
  ask gardeners [
    ifelse reviving-ticks = 0 [
      move
      check-radius
      cure-the-plants
    ][
      set reviving-ticks reviving-ticks - 1
    ]
  ]
  create-sick-plants
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CREATE PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to creating-plants
  create-leaves 30 [
    set color 57
    set size 1.5
    let x (random-float 32) - 16
    let y (random-float 10) - (-6)
    setxy x y
  ]

  create-leaves 20 [
    set color 57
    set size 1.5
    let x (random-float 16) - 0
    let y (random-float 19) - 16
    setxy x y
  ]

  create-leaves 18 [
    set color 57
    set size 1.5
    let x (random-float 13.5) - 16
    let y (random-float 19) - 16
    setxy x y
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MOVEMENT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move
  if (rule = "Segregation") [
    move-segregation
  ]
  if (rule = "Commoning") [
    fd 0.5
  ]
end

to move-segregation
  let new-x random-xcor
  let new-y random-ycor
  ifelse (who < 3) [
    while [new-x > -2 or new-y > 3] [
      set new-x random-xcor
      set new-y random-ycor
    ]
  ] [
    ifelse (who < 7) [
      while [new-x < 0 or new-y > 3] [
        set new-x random-xcor
        set new-y random-ycor
      ]
    ] [
      while [new-x > 17 or new-y < 6] [
        set new-x random-xcor
        set new-y random-ycor
      ]
    ]
  ]
  setxy new-x new-y
  check-radius
  cure-the-plants
  fd 0.5
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create-sick-plants
  if ticks mod 5 = 0 [
    ask one-of leaves [ set color yellow ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RADIUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to check-radius
  let sick-leaves-in-r leaves with [color = yellow] in-radius Closeness
  if any? sick-leaves-in-r [
    let target one-of sick-leaves-in-r
    face target
  ]
end

to cure-the-plants
   let sick-leaves-in-r leaves with [color = yellow] in-radius 0.3
  if any? sick-leaves-in-r [
    let target one-of sick-leaves-in-r
    face target
    move-to target
    revive-leaf target
  ]
end

to revive-leaf [target-leaf]
  ask target-leaf [ set color 57 ]
  set reviving-ticks 20
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

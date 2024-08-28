;; Jotoropa 2024
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INITIALS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
patches-own [ garbage ]
turtles-own [ money ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETUP & GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  ask patches [ set pcolor black ]
  create-turtles 20 [
    set size 2
    set shape "house"
    set color white
    location
    setup-money
  ]
  reset-ticks
end

to go
  ask turtles [
    produce-garbage
    be-happy
    be-sad
    be-angry
    be-scared
    be-happy-commonism
    be-angry-commonism
    generate-surprises
  ]
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MONEY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-money
  set money random 101
  set label (word money "            ")
  if (Organization = "Commonism") [
    set money ( 0 )
    set label ("            ") ]
end


to change-money-centralism
  let money-collection (money * tax) / 100
  let centralism-rent centralist-rent
  set money int(money - money-collection) + centralism-rent
  set label (word money "            ")
end

to change-money-separation
  let money-collection (money * cost-of-the-cleaning) / 100
  let separation-rent (money * worker-rent) / 100
  set money int(money - money-collection) + int(separation-rent)
  set label (word money "            ")
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; GARBAGE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to produce-garbage
    let garbage-disposal patches in-radius 5
    let garbage-dropping random 5
  ask n-of garbage-dropping garbage-disposal [ set pcolor brown ]
end

to generate-surprises
  let surprise random 10
  let surprise2 random 10
  if surprise = surprise2 [ factor-surprise ]
end

to factor-surprise
  let garbage-disposal patches in-radius 5
  let surprise-numbers [10 11 12 13 14 15]
  let surprise-garbage one-of surprise-numbers
  ask n-of surprise-garbage garbage-disposal [ set pcolor brown ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EMOTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to be-happy
   if (Organization = "Centralism") or (Organization = "Separation") [
    let garbage-around count patches in-radius Awareness with [pcolor != black]
    if money >= 50 and (garbage-around < 5) [ set color yellow ] ]
end

to be-sad
   if (Organization = "Centralism") or (Organization = "Separation") [
    let garbage-around count patches in-radius Awareness with [pcolor != black]
    if money < 50 and (garbage-around > 5) [ set color blue ] ]
end

to be-angry
  if (Organization = "Centralism") or (Organization = "Separation") [
    let garbage-around count patches in-radius Awareness with [pcolor != black]
    if money >= 50 and (garbage-around > 5) [ set color red ] ]
end

to be-scared
  if (Organization = "Centralism") or (Organization = "Separation") [
    let garbage-around count patches in-radius Awareness with [pcolor != black]
    if money < 50 and (garbage-around < 5) [ set color magenta ] ]
end

to be-happy-commonism
   if (Organization = "Commonism") [
    let garbage-around count patches in-radius Awareness with [pcolor != black]
    if garbage-around < 5 [ set color yellow ] ]
end

to be-angry-commonism
  if (Organization = "Commonism") [
    let garbage-around count patches in-radius Awareness with [pcolor != black]
    if garbage-around > 5 [ set color red ] ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLEANING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to clean-garbage
 ask turtles [
  if (Organization = "Centralism") [ clean-garbage-centralism ]
  if (Organization = "Separation") [ clean-garbage-separation ]
  if (Organization = "Commonism") [ clean-garbage-commonism ]
  if (Organization = "Centralism") [ change-money-centralism ]
  if (Organization = "Separation") [ change-money-separation ]
  ]
end

to clean-garbage-centralism
  let garbage-disposal patches in-radius 5
  let garbage-cleaning random 10
  ask n-of garbage-cleaning garbage-disposal [ set pcolor black ]
end

to clean-garbage-separation
  let separation-rent (money * worker-rent) / 100
  let garbage-disposal patches in-radius 5
  let money-collection efficiency-separation * (separation-rent)
  ask n-of money-collection garbage-disposal [ set pcolor black ]
end

to clean-garbage-commonism
  let neighbours turtles in-radius Information
  if any? neighbours with [color = red] [
    let garbage-disposal patches in-radius 5
    ask n-of efficiency-commonism garbage-disposal [ set pcolor black ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOTS AND REPORTERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report happy-houses
  let happys count turtles with [color = yellow]
  let households count turtles
  let percentage (happys / households) * 100
  report percentage
end

to-report crisis
 let happys count turtles with [color = yellow]
  let households count turtles
  let percentage (happys / households) * 100
  let crisis-message "Crisis!"
  if percentage < 50 [ report crisis-message ]
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LOCATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to location
  ask turtle 0 [ setxy -8 -4 ]
  ask turtle 1 [ setxy -8  4 ]
  ask turtle 2 [ setxy  0 -4 ]
  ask turtle 3 [ setxy  0  4 ]
  ask turtle 4 [ setxy  8 -4 ]
  ask turtle 5 [ setxy  8  4 ]
  ask turtle 6 [ setxy  16  4 ]
  ask turtle 7 [ setxy  16  -4 ]
  ask turtle 8 [ setxy  -16  4 ]
  ask turtle 9 [ setxy  -16 -4 ]
  ask turtle 10 [ setxy -8 -12 ]
  ask turtle 11 [ setxy -8  12 ]
  ask turtle 12 [ setxy  0 -12 ]
  ask turtle 13 [ setxy  0  12 ]
  ask turtle 14 [ setxy  8 -12 ]
  ask turtle 15 [ setxy  8  12 ]
  ask turtle 16 [ setxy  16  12 ]
  ask turtle 17 [ setxy  16  -12 ]
  ask turtle 18 [ setxy  -16  12 ]
  ask turtle 19 [ setxy  -16 -12 ]
end
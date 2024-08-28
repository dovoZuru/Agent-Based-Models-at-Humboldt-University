
to Pwait-time
    if  > 0[
        set Pwait-time Pwait-time - 1 
        ask one-of turtles random 64 [
            set color yellow
        ]
        if turtle color = yellow [
            set Pwait-time = 10
        ]
    ]
end
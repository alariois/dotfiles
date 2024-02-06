" Check if we have at least one argument
if argc() >= 1
    " Get the first argument
    let cmd = argv(0)

    " Print the command for debugging
    echom "Executing command: " . cmd

    " Execute the command
    execute cmd
endif
echom "Executing command: "

" Print the buffer to stdout
%print

" Quit without saving
q!

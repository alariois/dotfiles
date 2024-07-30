# xcompmgr tool is needed to run this script:
# sudo apt install xcompmgr

setopacity() {
    if [ "$1" -ge 0 ] && [ "$1" -le 100 ]; then
        opacity=$(printf '0x%x' $((0xffffffff * $1 / 100)))
        xprop -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY $opacity
    else
        echo "Please provide a valid opacity percentage between 0 and 100."
    fi
}

export -f setopacity

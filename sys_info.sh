#!/bin/bash

# Program to output a system information page

PROGNAME=$(basename $0)
TITLE="$HOSTNAME"
CURRENT_TIME=$(date +"%x %r %z")
TIMESTAMP="Generated $CURRENT_TIME, by $USER"


system_info () {
    cat <<- _EOF_
        <H2 style="background-color: 27a8fa">System Information</H2>
        <PRE>Operating System: $(uname -o)</PRE>
        <PRE>Kernel Version: $(uname -r)</PRE>
        <PRE>Kernel Release: $(uname -v)</PRE>
        <PRE>Distro: $(head -n 1 /etc/issue)</PRE>
_EOF_
return
}

report_uptime () {
    cat <<- _EOF_
        <H2 style="background-color: 27a8fa">System Uptime</H2>
        <PRE>$(uptime)</PRE>
_EOF_
return
}

report_disk_space () {
    cat <<- _EOF_
        <H2 style="background-color: 27a8fa">Disk Space Utilization</H2>
        <PRE>$(df -h)</PRE>
_EOF_
return
}

report_memory_utilization () {
    cat <<- _EOF_
        <H2 style="background-color: 27a8fa">Memory Utilization</H2>
        <PRE>$(free -th)</PRE>
_EOF_
return
}

report_home_space () {
    local format="%8s%10s%10s\n"
    local i dir_list total_files total_dirs total_size user_name

    if [[ $(id -u) -eq 0 ]]; then
        dir_list=/home/*
        user_name="All User"
    else
        dir_list=$HOME
        user_name=$USER
    fi
    
    cat <<- _EOF_
     <H2 style="background-color: 27a8fa">Home Space Utilization ($user_name)</H2>
_EOF_

    for i in $dir_list; do

        total_files=$(find $i -type f | wc -l)
        total_dirs=$(find $i -type d | wc -l)
        total_size=$(du -sh $i | cut -f 1)

        echo "<PRE>$i</PRE>"
        echo "<PRE>"
        printf "$format" "Dirs" "Files" "Size"
        printf "$format" "----" "----" "----"
        printf "$format" $total_dirs $total_files $total_size
        echo "</PRE>"
    done
    return
}    

#    if [[ $(id -u) -eq 0 ]]; then
#        cat <<- _EOF_
#            <H2 style="background-color: 27a8fa">Home Utilization (All User)</H2>
#            <PRE>$(du -sh /home/*)</PRE>
#_EOF_
#    else 
#        cat <<- _EOF_
#            <H2 style="background-color: 27a8fa">Home Space Utilization ($USER)</H2>
#            <PRE>$(du -sh $HOME)</PRE>
#_EOF_
#    fi
#    return

usage () {
    echo "$PROGNAME: usage: $PROGNAME [ -f file | -i ]"
    return
}

write_html_page () {
cat << _EOF_
<HTML>
	<HEAD>
		<TITLE>$TITLE</TITLE>
	</HEAD>
	<BODY bgcolor="c5dae7">
		<H1 style="background-color: 27a8fa">$TITLE</H1>
        <P><B>$TIMESTAMP</B></P>
        <B>$(system_info)</P>
        <B>$(report_uptime)</P>
        <B>$(report_memory_utilization)</B>
        <B>$(report_disk_space)</B>
        <B>$(report_home_space)</B>
	</BODY>
</HTML>
_EOF_
return
}

# Process command line options

interactive=
filename=  

while [[ -n $1 ]]; do 
    case $1 in 
        -f | --file)    shift
                        filename=$1
                        ;;
        -i | --interactive) interactive=1
                        ;;
        -h | --help)    usage
                        exit
                        ;;
        *)              usage >&2
                        exit 1
                        ;;
    esac
    shift
done

# Interactive mode

if [[ -n $interactive ]]; then
    while true; do
        read -p "Enter name of output file: " filename
        if [[ -e $filename ]]; then
            read -p "'$filename' exists. Overwrite? [y/n/q]"
            case $REPLY in
                Y|y)    break
                        ;;
                Q|q)    echo "Program Terminated."
                        exit
                        ;;
                *)      continue
                        ;;
            esac
        elif [[ -z $filename ]]; then
            continue
        else
            break
        fi
    done
fi

# output html page

if [[ -n $filename ]]; then
    if touch $filename && [[ -f $filename ]]; then
        write_html_page > $filename
    else
        echo "$PROGNAME: Cannot write file '$filename'" >&2
        exit
    fi
else
    write_html_page
fi

# To Be added
# Option where to put the file
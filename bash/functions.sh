function extract() {
    local e=0 i c
    for i; do
        if [ -f $i && -r $i ]; then
            c=
            case $i in
                *.tar.bz2) c='tar xjf'    ;;
                *.tar.gz)  c='tar xzf'    ;;
                *.bz2)     c='bunzip2'    ;;
                *.gz)      c='gunzip'     ;;
                *.tar)     c='tar xf'     ;;
                *.tbz2)    c='tar xjf'    ;;
                *.tgz)     c='tar xzf'    ;;
                *.7z)      c='7z x'       ;;
                *.Z)       c='uncompress' ;;
                *.exe)     c='cabextract' ;;
                *.rar)     c='unrar x'    ;;
                *.xz)      c='unxz'       ;;
                *.zip)     c='unzip'      ;;
                *)     echo "$0: cannot extract \`$i': Unrecognized file extension" >&2; e=1 ;;
            esac
            [ $c ] && command $c "$i"
        else
            echo "$0: cannot extract \`$i': File is unreadable" >&2; e=2
        fi
    done
    return $e
}

TRASH_DIR="$HOME/.trash"

# replace `rm`,  put files to trash instead of a real delete action
trash() {
    if [ ! -d "$TRASH_DIR" ]; then
        mkdir -p "$TRASH_DIR"
    fi
    for i in $*; do
        if [[ ! $i =~ ^- ]]; then
            local filename=`realpath $i`
            if [ -a "$filename" ]; then
                local DT=`date +%Y-%m-%d`
                local p=`dirname "$TRASH_DIR"/"$DT"/"$filename"`
                if [ ! -d "$p" ];then
                    mkdir -p "$p"
                fi
                mv -f "$filename" "$TRASH_DIR/$DT$filename"
            fi
        fi
        
    done
}


function aenv() {
    local d=$1
    if [ -z $d ]; then
        $d="."
    fi
    if [ -d "$d/.env" ]; then
        source "$d/.env/bin/activate"
        elif [ -d "$d/venv" ]; then
        source "$d/venv/bin/activate"
        elif [ -d "$d/.venv" ]; then
        source "$d/.venv/bin/activate"
    else
        echo "don't have env"
    fi
}


function history-stat() {
    if [ "$1" == "-h" ]; then
        echo "stat history shell command, accept a number like head -n"
        return 1
    fi
    if [ -n $1 ]; then
        __history_limit=$1
    else
        __history_limit=10
    fi
    history |\
    awk '{CMD[$2]++;count++;} END { for (a in CMD )print CMD[ a ]" " CMD[ a ]/count*100 "% " a }' |\
    grep -v "./" | column -c3 -s " " -t |sort -nr | nl | head -n$__history_limit
}


function pidofport() {
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "get pid of process listen on given port"
        return 1
    else
        local __port_pid=$(ss -tnlp | grep ":$1" | tr ',' "\n" | grep "pid" | awk -F '=' '{print $2}')
        echo $__port_pid
    fi
}


function cmdofpid() {
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "get process command of given pid"
        return 1
    else
        ps -F -p 67992 | grep -v CMD | awk '{for(i=11;i<=NF;i++) printf"%s ",$i};NF>11 {print ""}'
    fi
}

function topof() {
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "top filter by command names"
    else
        top -c -p $(pgrep -d',' -f $1) -o PID
    fi
}


function memofpid() {
    if [ $# != 2 ]; then
        echo "Usage(kb): memofpid [share|private|rss|pss|size] [pid]"
        return 1
    fi
    
    [[ ! -a /proc/$2 ]] && echo "pid $2 not exist" && return 1;
    
    case $1 in
        s|share)
            grep ^Share /proc/$2/smaps  | awk '{sum += $2} END {print sum}'
        ;;
        p|private)
            grep ^Private /proc/$2/smaps  | awk '{sum += $2} END {print sum}'
        ;;
        r|rss|Rss)
            grep ^Rss /proc/$2/smaps  | awk '{sum += $2} END {print sum}'
        ;;
        pss|Pss)
            grep ^Pss /proc/$2/smaps  | awk '{sum += $2} END {print sum}'
        ;;
        size)
            grep ^Size /proc/$2/smaps  | awk '{sum += $2} END {print sum}'
        ;;
        *)
            echo "Usage(kb): memofpid [share|private|rss|pss|size] [pid]"
            return 1
        ;;
    esac
}

function kill-jobs() {
    jobs -l | awk '{print $2}' | xargs kill
}

function __kill_benchmark() {
    [[ -a "./__pid_file_temp" ]] && cat "./__pid_file_temp" | xargs kill >/dev/null 2>&1
    rm -f "./__pid_file_temp"
    set -m
    set -b
}

function benchmark() {
    set +m
    set +b
    if [ -z "$1" -o "$1" == "-h" ]; then
        echo "Usage: benchmark [-n10] command..."
        return 1
    else
        local currency=10
        local cmd
        if [ "${1:0:2}" == "-n" ]; then
            currency=${1#*n}
            cmd=${@:2}
        else
            cmd=$*
        fi
        [[ -a "./__pid_file_temp" ]] && rm "./__pid_file_temp"
        echo "COMMAND: $cmd"
        echo "START $currency jobs"
        echo
        trap __kill_benchmark SIGINT
        trap __kill_benchmark SIGTERM
        
        for (( i=1; i<($currency + 1); i++ ))
        do
            {
                local __cost=`/usr/bin/time -p  $cmd 2>&1  | grep real | awk '{print $2}'`
                echo "$(printf "%03d" $i) finish cost $__cost"
                echo $! > __pid_file_temp
            } &
            echo "$(printf "%03d" $i) start"
        done
        wait
        
        __kill_benchmark
        echo
        echo FINISH!
    fi
}

benchmark $*
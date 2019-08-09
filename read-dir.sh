#! /bin/bash

function    fn_read_directory
{
                                                                         target=${1}
    prompt=${2}
                                              directorylist="$(for i in $target/*;  do [ -f "$i" ] && echo $i;  done)"
    assert_not_empty       "directorylist" "${directorylist}"           #PREVENT INFINITE LOOP IF ZERO RESULTS
                            directory=''
    PS3='Enter number for   directory   or 0 to quit:'                  #SET A USEFUL PROMPT
    until               [ "$directory"  == "Quit"   ];    do
                printf    "$%b"    "\a\n\n${prompt}:\n"    >&2
                select      directory in    ${directorylist};    do     #USER TYPES A NUM THAT WE STORE IN \${REPLY}, BUT SELECT RETURNS ENTRY VALUE
                    if      [ ${REPLY} == 0         ]; then
                                exit_without_error "yer outta the directorylist, thanks fer directorying."
                    elif    [ -n "${directory}"     ];    then
                        echo     "${directory}"
                                    directory="Quit"
                        break
                    else
                        echo    "Invalid selection"
                    fi                                                #END OF USER-SELECTS-DIRECTORY USE-CASE
    done                                                              #END OF UNTIL DIRECTORY == Quit
}
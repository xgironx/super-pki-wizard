#! /bin/bash
                        #REGISTER SIGNAL HANDLER
trap    "exit 0"    SIGUSR1
trap    "exit 1"    TERM
export              TOP_PID=$$

function    fn_exit_with_error 
{
                    message=${1}
    >&2     echo ${message}
    kill -s TERM ${TOP_PID}
}

function    fn_exit_without_error
{
                      message=${1}
            echo    ${message}
    kill -s SIGUSR1 ${TOP_PID}
}

function    fn_print_usage
{
    echo    "usage:  ${0}   <CMD>   [args]"
    echo    "commands:"
    echo    "gen_key_and_csr:      gen PK private key and CSR certificate signing request"
    echo    "gencertsandstores: gen all permutations of certs & keystores"
    exit    1
}

function    fn_init_defaults                #SETUP DEFAULTS
{
    ORGANIZATION="US Government"
    ORGANIZATIONAL_UNIT="DOD"
             CN=${hostname}
    COMMON_NAME=${hostname}
    FQDN=${CN}.${SSP}
    COUNTRY="US"
    STATE="MD"
    LOCALITY="LAUREL"
    O="US Government"
    OU="DOD"
    FILE_PASSWORD='password.txt'
    PASSWORD_DATA=$(fn_gen_random_password)
    SSP="BRINYSTAND"
    EMAIL="jkgiron"
    EMAIL_ALIAS="brinystand_support@ic.gov"
}

function    fn_lowercase_cn
{
           #unset ${DIR_OUT}
           local  COMMON_NAME=${1}
           #echo "_______________________"
           #echo     ${CN}                                       '  --CN'
           #echo     ${CN}     | tr    '[:upper:]' '[:lower:]'
                  #COMMON_NAME_LC=`${COMMON_NAME}    | tr    '[:upper:]' '[:lower:]'`
            #echo ${COMMON_NAME}    | tr    '[:upper:]' '[:lower:]'
            COMMON_NAME_LC=`echo ${COMMON_NAME}    | tr    '[:upper:]' '[:lower:]'`
           #export COMMON_NAME_LC=${CN}     | tr    '[:upper:]' '[:lower:]'
           echo ${COMMON_NAME_LC}
}

function    fn_set_filename_vars 
{
        #   COMMON_NAME=${1}
        #   COMMON_NAME=${hostname}
        #   CN=${hostname}
        #   COMMON_NAME_LC=$(fn_lowercase_cn  ${COMMON_NAME})

    # echo $CN                                                    '  --CN, at fn_set_filename_vars' 
    #echo $COMMON_NAME                                            '  --COMMON_NAME, at fn_set_filename_vars' 
    ENV_SCRIPT='super-pki-wizard-env.sh'
    #PASSWORD='password.txt'
        KEY_PRIVATE_ENCRYPTED=${COMMON_NAME_LC}.key-private-encrypted.pem
    KEY_PRIVATE_ENCRYPTED_NOT=${COMMON_NAME_LC}.key-private-encrypted-not.pem
               KEY_PUBLIC_SSH=${COMMON_NAME_LC}.key-public-ssh.pem
}

function    fn_gen_random_password
{
    length=${1}
    if  [ ${length}=="" ]; then
            length=32
    fi
    LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 32 | xargs     #FOR MAC ONLY
    #head /dev/urandom   | tr -dc A-Za-z0-9  | head -c ${length}                                #FOR MAC-NOTs
}

function    fn_read_required
{
    VAR_NAME=${1}
    PROMPT=${2}
                REPLY=""
    while   [[ "${REPLY}==""" ]]; do
                read -p "${PROMPT}:" REPLY
    done  
    eval    "${VAR_NAME}=\"${REPLY}\""
}

function    fn_read_optional
{
               VAR_NAME=${1}
    DEFAULT=${!VAR_NAME}
              PROMPT=${2}
    read -p ${PROMPT}:     REPLY
                       if [ -n ${REPLY} ]; then
        eval    "${VAR_NAME}=\"${REPLY}\""
    fi
}

# function    fn_read_file
# {
#                                                                     target=${1}
#     prompt=${2}
#                                               filelist="$(for i in $target/*;  do [ -f "$i" ] && echo $i;  done)"
#     assert_not_empty       "filelist"      "${filelist}"               #PREVENT INFINITE LOOP IF ZERO RESULTS
#                             directory=''
#     PS3='Enter number for   directory   or 0 to quit:'                 #SET A USEFUL PROMPT
#     until               [ "$directory"  == "Quit"   ];    do
#                 printf    "$%b"    "\a\n\n${prompt}:\n"    >&2
#                 select      directory in    ${filelist};    do         #USER TYPES A NUM THAT WE STORE IN \${REPLY}, BUT SELECT RETURNS ENTRY VALUE
#                     if      [ ${REPLY} == 0         ]; then
#                                 exit_without_error "yer outta the filelist, thanks fer fileing."
#                     elif    [ -n "${directory}"     ];    then
#                         echo     "${directory}"
#                                     directory="Quit"
#                         break
#                     else
#                         echo    "Invalid selection"
#                     fi                                                #END OF USER-SELECTS-DIRECTORY-FILE USE-CASE
#     done                                                              #END OF UNTIL DIRECTORY-FILE == Quit
# }

# function    fn_read_directory
# {
#                                                                          target=${1}
#     prompt=${2}
#                                               directorylist="$(for i in $target/*;  do [ -f "$i" ] && echo $i;  done)"
#     assert_not_empty       "directorylist" "${directorylist}"           #PREVENT INFINITE LOOP IF ZERO RESULTS
#                             directory=''
#     PS3='Enter number for   directory   or 0 to quit:'                  #SET A USEFUL PROMPT
#     until               [ "$directory"  == "Quit"   ];    do
#                 printf    "$%b"    "\a\n\n${prompt}:\n"    >&2
#                 select      directory in    ${directorylist};    do     #USER TYPES A NUM THAT WE STORE IN \${REPLY}, BUT SELECT RETURNS ENTRY VALUE
#                     if      [ ${REPLY} == 0         ]; then
#                                 exit_without_error "yer outta the directorylist, thanks fer directorying."
#                     elif    [ -n "${directory}"     ];    then
#                         echo     "${directory}"
#                                     directory="Quit"
#                         break
#                     else
#                         echo    "Invalid selection"
#                     fi                                                #END OF USER-SELECTS-DIRECTORY USE-CASE
#     done                                                              #END OF UNTIL DIRECTORY == Quit
# }

function    fn_gen_key_private
{
    #echo "_______________________"
    echo "  --inside fn_gen_key_private"
    echo   `pwd`                            '  --PWD'
    echo   ${DIR_OUT}                       '  --DIR_OUT'
    #openssl genrsa  -out        server201907221709/${KEY_PRIVATE_ENCRYPTED_NOT}  2048                                                     #GEN UNENCIPHERED  PRIVATE KEY    
    #openssl genrsa  -out        $DIR_OUT/${KEY_PRIVATE_ENCRYPTED_NOT}  2048                                                               #GEN UNENCIPHERED  PRIVATE KEY    
    openssl genrsa  -out        ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT}  2048                                                              #GEN UNENCIPHERED  PRIVATE KEY    
    openssl rsa     -des3   -in ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT}        -out ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED}    -passout "file:${DIR_OUT}/${FILE_PASSWORD}"   #ENCIPHER          PRIVATE KEY
    chmod 0600 ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT}
    chmod 0600 ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED}
   #openssl rsa     -des3   -in ${KEY_PRIVATE_ENCRYPTED_NOT}        -out ${KEY_PRIVATE_ENCRYPTED}    -passout "file:${DIR_OUT}/${FILE_PASSWORD}"   #ENCIPHER          PRIVATE KEY
}				


function    fn_gen_key_public_ssh
{
    rm -rf                                                                              ${DIR_OUT}/${KEY_PUBLIC_SSH}
    ssh-keygen  -f              ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT} -y  -t rsa  >   ${DIR_OUT}/${KEY_PUBLIC_SSH}                     #GEN KEY_PUBLIC_SSH   
    chmod 0444                                                                          ${DIR_OUT}/${KEY_PUBLIC_SSH}
}	


function    fn_mkdir_out
{
                                                                                   echo ${COMMON_NAME}
                                                     FILENAME_PREFIX=$(fn_lowercase_cn  ${COMMON_NAME})
                                              echo ${FILENAME_PREFIX}
                                                    #FILENAME_PREFIX="${FILENAME_PREFIX/'*'/wildcard}"                         #REPLACE '*' WITH 'wildcard'
                                          DIR_OUT="${FILENAME_PREFIX}-$((`date '+%Y'` + 3))"                                   #ADD 3 YEARS TO EXPIRY
    if  [[ -d                           ${DIR_OUT}      ]]; then
                    i=1
        while   [[ -d                   ${DIR_OUT}.$i   ]]; do
                let i++
        done
                                 #echo   ${DIR_OUT} '  --ECHO DIR_OUT inside IF LOOP'  
    fi
                                 mkdir  ${DIR_OUT}
                            chmod 0770  ${DIR_OUT}
                                 echo   `pwd`      '  --PWD'
}	

function    fn_gen_enviro_script
{
    cat  << EOF > ${ENV_SCRIPT}
#!/bin/bash
                        #########################################
                        #HOSTING ENV
                        ###########
export SSP=${SSP}
DIR_BASE='/etc/pki'
                        #########################################
                        # PUBLIC SIGNED CERT / PRIVATE KEYS
                        ###########
DIR_PKI='\${DIR_BASE}/\${COMMON_NAME}'
if  [ -r '\${DIR_PKI/password.txt' ]; then
    PKI_PASSWORD=\$(  cat '\${DIR_PKI}/password.txt'  )
}
EOF
    chmod 0770 ${ENV_SCRIPT}
}


function fn_record_password {
    echo ${PASSWORD_DATA}   >   ${DIR_OUT}/${FILE_PASSWORD} 
}


function    fn_gen_key_and_csr
{
                                                            # IFS=$','
    IFS=,
                                                            # declare -a arraylist=(server201907231822L,domain.com,server201907231822L.domain.com,7.7.7.7,10.1.1.1,us@email.com,ssp201907231822L,saBob,saHenry)
    fn_init_defaults
    mkdir       requests && \
    chmod 0770  requests
    while read -a COMMON_NAME; do
                                                            #echo "_______________________"
                                                            #arraylistlength=${COMMON_NAME[@]}
            for x in ${COMMON_NAME[@]}; do echo ${x}; done;
                                                            # echo ${arraylistlength}
                                                            # echo ${COMMON_NAME[0]} '  --COMMON_NAME'
                                                            # echo ${COMMON_NAME[1]} '  --COMMON_NAME'
            fn_set_filename_vars     ${COMMON_NAME}
            fn_mkdir_out
                                                            #echo ${PASSWORD_DATA}                   '  --PASSWORD_DATA'
            fn_record_password
                                                            #cat ${DIR_OUT}/password.txt
                                                            #echo "_______________________"
            echo `pwd`                                      '  --PWD'
                                                            #echo "_______________________"
            echo ${DIR_OUT}                                 '  --DIR_OUT'
                                                            #cd ${DIR_OUT}
                                                            #echo `pwd`                              '  --PWD'
                                                            # fn_gen_enviro_script
                                                            #echo "_______________________"
            echo "NOW:  fn_gen_key_private"
                        fn_gen_key_private
            fn_gen_key_public_ssh
            cd -
                                                            #echo "_______________________"
                                                            #echo `pwd`                              '  --PWD'
                                                    #done    < hostinfo.txt
                                                    #done    <<< hostinfo.txt.array
        done    < hostinfo.txt.array
}

                                                            #umask 337                              #PROTECT GENERATED FILES
CMD=${1}                                                    #PARSE CLI ARGS
FILENAME=${2}
if  [ ${CMD} == "gen_key_and_csr"  ]; then
    fn_gen_key_and_csr
else
    >&2 echo -e 'ERROR:  Invalid Arg ${1}\n'
fi

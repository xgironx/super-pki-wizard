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
    echo    "genkeyandcsr:      gen PK private key and CSR certificate signing request"
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
         PASSWORD=${fn_gen_random_password}
    PASSWORD_DATA=${fn_gen_random_password}
    SSP="BRINYSTAND"
    EMAIL="jkgiron"
    EMAIL_ALIAS="brinystand_support@ic.gov"
}

function    fn_lowercase_cn
{
    local      CN=${1}
    echo     ${CN}     | tr    '[:upper:]' '[:lower:]'
}

function    fn_gen_filename_vars 
{
                                             COMMON_NAME=${1}
                                             CN=${hostname}
    echo "at generate_filename_vars, CN:  " $CN
    ENV_SCRIPT="super-pki-wizard-env.sh"
    PASSWORD="password.txt"
        KEY_PRIVATE_ENCRYPTED='${COMMON_NAME}.key-private-encrypted.pem'
    KEY_PRIVATE_ENCRYPTED_NOT='${COMMON_NAME}.key-private-encrypted-not.pem'
}

function    fn_gen_random_password
{
    length=${1}
    if  [ ${length}=="" ]; then
            length=32
    fi
    head /dev/urandom   | tr -dc A-Z0-9a-z  | head -c ${length}
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
    PROMPT=${2}
    DEFAULT=${!VAR_NAME}
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

function    fn_gen_private_key
{
    openssl genrsa  -out        ${KEY_PRIVATE_ENCRYPTED_NOT}  2048                                                               #GEN UNENCIPHERED  PRIVATE KEY    
    openssl rsa     -des3   -in ${KEY_PRIVATE_ENCRYPTED_NOT}        -out ${KEY_PRIVATE_ENCRYPTED}    -passout "file:$PASSWORD"   #ENCIPHER          PRIVATE KEY
}				

function    fn_gen_dir_out
{
                                     FILENAME_PREFIX=$(fn_lowercase_cn  "$COMMON_NAME")
                  FILENAME_PREFIX="${FILENAME_PREFIX/'*'/wildcard}"                                                 #REPLACE '*' WITH 'wildcard'
    DIR_OUT="${FILENAME_PREFIX}.$((`date '+%Y'` + 3))"                                                           #ADD 3 YEARS TO EXPIRY
    if  [[ -d           ${DIR_OUT} ]]; then
        i=1
        while   [[ -d   ${DIR_OUT}.$i  ]]; do
                let i++
        done
            echo "ECHO DIR_OUT inside IF LOOP:  "  ${DIR_OUT}
    fi
    echo 'PWD:  ' `pwd`
    echo "ECHO DIR_OUT OUTSIDE IF LOOP:  "  ${DIR_OUT}
    DIR_OUT_PLUS_CERT_TTL="${DIR_OUT}"
    echo "ECHO DIR_OUT_PLUS_CERT_TTL:  "  ${DIR_OUT_PLUS_CERT_TTL}
    mkdir       ${DIR_OUT_PLUS_CERT_TTL} && \
    chmod 0770  ${DIR_OUT_PLUS_CERT_TTL}
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
    chmod 0444 ${ENV_SCRIPT}
}

function    fn_gen_key_and_csr
{
    echo before fn_init_defaults
    fn_init_defaults
    mkdir       requests && \
    chmod 0700  requests
    while read COMMON_NAME; do
                           echo ${COMMON_NAME}
        fn_gen_filename_vars    ${COMMON_NAME}
        fn_gen_dir_out
            echo 'PWD:  ' `pwd`
        cd ${DIR_OUT_PLUS_CERT_TTL}
            echo 'PWD:  ' `pwd`
        # fn_gen_random_password
        # fn_gen_enviro_script
        # fn_gen_private_key
        cd -
            echo 'PWD:  ' `pwd`
        done    < hostinfo.txt
}

umask 337                              #PROTECT GENERATED FILES
CMD=${1}                               #PARSE CLI ARGS
FILENAME=${2}
if  [ ${CMD} == "genkeyandcsr"  ]; then
    fn_gen_key_and_csr
else
    >&2 echo -e 'ERROR:  Invalid Arg ${1}\n'
fi


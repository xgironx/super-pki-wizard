#! /bin/bash
             
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
    echo    "gen_key_and_csr:   gen PK private key and CSR certificate signing request"
    echo    "gencertsandstores: gen all permutations of certs & keystores"
    exit    1
}

function    fn_init_defaults     
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
           local  COMMON_NAME=${1}
                  COMMON_NAME_LC=`echo ${COMMON_NAME}    | tr    '[:upper:]' '[:lower:]'`
           echo ${COMMON_NAME_LC}
}

function    fn_set_filename_vars 
{     
    ENV_SCRIPT='super-pki-wizard-env.sh'
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
    LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 32 | xargs
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
    read -p ${PROMPT}:                    REPLY
                if                 [ -n ${REPLY} ]; then
                    eval "${VAR_NAME}=\"${REPLY}\""
                fi
}

function    fn_gen_key_private
{
    echo "  --inside fn_gen_key_private"
    echo   `pwd`                            '  --PWD'
    echo   ${DIR_OUT}                       '  --DIR_OUT'                                                   
    openssl genrsa  -out        ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT}  2048                                                   
    openssl rsa     -des3   -in ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT}        -out ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED}    -passout "file:${DIR_OUT}/${FILE_PASSWORD}"   #ENCIPHER          PRIVATE KEY
                     chmod 0600 ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT}
                     chmod 0600 ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED}
}				


function    fn_gen_key_public_ssh
{
    rm -rf                                                                              ${DIR_OUT}/${KEY_PUBLIC_SSH}
    ssh-keygen  -f              ${DIR_OUT}/${KEY_PRIVATE_ENCRYPTED_NOT} -y  -t rsa  >   ${DIR_OUT}/${KEY_PUBLIC_SSH}          
    chmod 0444                                                                          ${DIR_OUT}/${KEY_PUBLIC_SSH}
}	


function    fn_mkdir_out
{
                                                                                   echo ${COMMON_NAME}
                                                     FILENAME_PREFIX=$(fn_lowercase_cn  ${COMMON_NAME})
                                              echo ${FILENAME_PREFIX}                                         
                                          #DIR_OUT="${FILENAME_PREFIX}-$((`date '+%Y'` + 3))"                        
                                          DIR_OUT=output/${FILENAME_PREFIX}-$((`date '+%Y'` + 3))                      
    if  [[ -d                           ${DIR_OUT}      ]]; then
                    i=1
        while   [[ -d                   ${DIR_OUT}.$i   ]]; do
                let i++
        done                  
    fi
                                 mkdir  ${DIR_OUT}
                            chmod 0770  ${DIR_OUT}
                                 echo   `pwd`      '  --PWD'
}	

function    fn_gen_enviro_script
{
    cat  << EOF > ${ENV_SCRIPT}
#!/bin/bash          
export SSP=${SSP}
DIR_BASE='/etc/pki'           
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
    IFS=,                                                      
    fn_init_defaults
    mkdir       requests && \
    chmod 0770  requests
    while read -a COMMON_NAME; do                                                                                            
            for x in                 ${COMMON_NAME[@]}; do echo ${x}; done;                                 
            fn_set_filename_vars     ${COMMON_NAME}
            fn_mkdir_out
            fn_record_password
            echo `pwd`                                      '  --PWD'
            echo ${DIR_OUT}                                 '  --DIR_OUT'
            echo "NOW:  fn_gen_key_private"
                        fn_gen_key_private
                        fn_gen_key_public_ssh
#           cd -                               
        done    < input/hostinfo.txt.array
}

                                                 
CMD=${1}                                         
FILENAME=${2}
if  [ ${CMD} == "gen_key_and_csr"  ]; then
    fn_gen_key_and_csr
else
    >&2 echo -e 'ERROR:  Invalid Arg ${1}\n'
fi

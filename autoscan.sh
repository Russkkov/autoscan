#!/bin/bash

#Desarrollado por Russkkov
#https://github.com/Russkkov

#Script para escanear el rango de direcciones IP de las redes a las que estamos conectados

###########################################
#---------------[ Colores ]---------------#
###########################################
C=$(printf '\033')
RED="${C}[1;31m"
GREEN="${C}[1;32m"
YELLOW="${C}[1;33m"
BLUE="${C}[1;34m"
LIGHT_MAGENTA="${C}[1;95m"
LIGHT_CYAN="${C}[1;96m"
LG="${C}[1;37m" #LightGray
DG="${C}[1;90m" #DarkGray
NC="${C}[0m"
###########################################
#---------------[ Abortar ]---------------#
###########################################
function ctrl_c(){
	echo -e ${RED}"\n\t[!] Escaneo interrumpido manualmente.\n"
	exit 1
}
trap ctrl_c INT
###########################################
#----------------[ Ayuda ]----------------#
###########################################
ayuda(){
        echo -e ${YELLOW}"\n[+] Panel de ayuda de AutoSCAN\n"${NC}
        echo -e ${DG}"AutoSCAN es un script para esanear el rango de direcciones IP de las redes con las que tenemos conexión y detectar las IP que están activas"
        echo -e "También puede escanearse únicamente una red concreta dada (ver Uso 2).\n"
        echo -e "En cualquiera de las dos formas de escaneo puede guardarse en un archivo la información obtenida (ver Uso 3 y Uso 4).\n\n"
        echo -e ${YELLOW}"[-] Uso 1: autoscan.sh"
        echo -e ${DG}"\tSi se ejecuta el script sin parámetros realizará un escaneo en todas las redes a las que estén conectadas nuestras interfaces de red.\n\n"
        echo -e ${YELLOW}"[-] Uso 2: autoscan.sh [-i][-ip] <IP>"
        echo -e ${DG}"\tPara escanear solo una red se usa el parámetro -i o --ip seguido de la dirección IP (-i 127.0.0.0 o --ip 127.0.0.0)."
	echo -e "\tPuede usarse cualquier dirección IP que pertenezca al rango de direcciones, no es necesario que sea nuestra propia IP."
        echo -e "\tPara guardar en un archivo el resultado del escaneo ve al Uso 4.\n\n"
        echo -e ${YELLOW}"[-] Uso 3: autoscan.sh [-e][--exportar]"
        echo -e ${DG}"\tSi se usa el parámetro -e o --exportar se realizará el escaneo descrito en el Uso 1 y se guardará en un archivo .txt en la ruta actual.\n\n"
        echo -e ${YELLOW}"[-] Uso 4: autoscan.sh [-i][--ip] <IP> [-e][--exportar]"
        echo -e ${DG}"\tSi se usa el parémtro -e o --exportar junto con el parámetro -i o --ip seguido de la IP se realizará el escaneo descrito en el Uso 2 y se guardará un archivo .txt en la ruta actual.\n\n"
        echo -e ${YELLOW}"[-] Uso 5: autoscan.sh [-h][--help][--ayuda]"
        echo -e ${DG}"\tSi se usa el parémtro -h, --help o --ayuda se mostrará este panel de ayuda.\n\n"${NC}
}
###########################################
#---------------[ GETOPTS ]---------------#
###########################################
patch_lo() {
        local LO="$1" _OPT="$2"
        shift 2
        eval "[ \$$_OPT = '-' ] || return 0"
        local o=${OPTARG%%=*}
        eval $_OPT=\$o
        if ! echo "$LO" | grep -qw "$o"; then
                eval $_OPT='\?'
                OPTARG=-$o
                return 1
   fi
OPTARG=$(echo "$OPTARG" | cut -s -d= -f2-)
        if echo "$LO" | grep -q "\<$o:"; then
                if [ -z "$OPTARG" ]; then
                        eval OPTARG=\$$((OPTIND))
                                if [ -z "$OPTARG" ]; then
                                        eval $_OPT=":"
                                        OPTARG=-$o
                                        return 1
                                fi
                        OPTIND=$((OPTIND+1))
                fi
        elif [ -n "$OPTARG" ]; then
                OPTARG=""
        fi
}
patch_dash() {
        [ "$opt" = ":" -o "$opt" = "?" ] && return 0
        if echo $OPTARG | grep -q '^-'; then
                OPTARG=$opt
                opt=":"
        fi
}
###########################################
#--------------[ ESCANEAR ]---------------#
###########################################
escanear(){
	echo -e ${YELLOW}"[+] Buscando interfaces de red.\n"
	sleep 1
	echo -e "[+] Conexión de red en:\n"
	lista_ip=$(ip addr | grep "inet " | awk '{print $2}' FS=" "| awk '{print $1}' FS="/")
	for j in ${lista_ip[@]}; do
		echo -e ${BLUE}"\t$j"
	done
	sleep 1
	echo -e ${YELLOW}"\n[+] Buscando IP activas en las redes encontradas.\n"
	ips=$(ip addr | grep "inet " | awk '{print $2}' FS=" " | awk '{print $1"."$2"."$3}' FS="." | grep -v "127.0.0")
	for i in ${ips[@]}; do
		echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $i.0:\n"
		for h in $(seq 1 255); do
			timeout 2 bash -c "ping -c 1 $i.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$i.$h${BLUE} está activa"${NC} &
		done; wait
		echo
	done
}
###########################################
#---------[ ESCANEAR EXPORTADO ]----------#
###########################################
escanear_exp(){
        echo -e ${DG}"#AutoSCAN" > escaneo_completo.txt
        echo -e ${DG}"#Creado por Russkkov" >> escaneo_completo.txt
        echo -e ${DG}"https://github.com/Russkkov" >> escaneo_completo.txt
        echo -e "" >> escaneo_completo.txt
        echo -e "" >> escaneo_completo.txt
        echo -e "" >> escaneo_completo.txt
        echo -e ${YELLOW}"[+] Buscando interfaces de red.\n"
        sleep 1
        echo -e "[+] Conexión de red en:\n" | tee -a /dev/tty >> escaneo_completo.txt
        lista_ip=$(ip addr | grep "inet " | awk '{print $2}' FS=" "| awk '{print $1}' FS="/")
        for j in ${lista_ip[@]}; do
                echo -e ${BLUE}"\t$j"  | tee -a /dev/tty >> escaneo_completo.txt
        done
	echo "" >> escaneo_completo.txt
        sleep 1
        echo -e ${YELLOW}"\n[+] Buscando IP activas en las redes encontradas.\n"
        ips=$(ip addr | grep "inet " | awk '{print $2}' FS=" " | awk '{print $1"."$2"."$3}' FS="." | grep -v "127.0.0")
        for i in ${ips[@]}; do
                echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $i.0:\n" | tee -a /dev/tty >> escaneo_completo.txt
                for h in $(seq 1 255); do
                        timeout 2 bash -c "ping -c 1 $i.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$i.$h${BLUE} está activa"${NC} | tee -a /dev/tty >> escaneo_completo.txt &
                done; wait
                echo ${NC} | tee -a /dev/tty >> escaneo_completo.txt
        done
}
###########################################
#-------------[ ESCANEAR IP ]-------------#
###########################################
escanear_ip(){
	ipa=$(echo $ipe | awk '{print $1"."$2"."$3}' FS=".")
	echo -e ${YELLOW}"\n[+] Buscando IP activas en la red indicada.\n"
	sleep 1
	echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $ipa.0:\n"
	        for h in $(seq 1 255); do
	                timeout 2 bash -c "ping -c 1 $ipa.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$ipa.$h${BLUE} está activa"${NC} &
	        done; wait
	        echo
}
###########################################
#--------[ ESCANEAR IP EXPORTADO ]--------#
###########################################
escanear_ip_exp(){
	ipad=$(echo $ipe | awk '{print $1 $2 $3}' FS=".")
	ipa=$(echo $ipe | awk '{print $1"."$2"."$3}' FS=".")
	echo -e ${DG}"#AutoSCAN" > escaneo_$ipad.txt
	echo -e ${DG}"#Creado por Russkkov" >> escaneo_$ipad.txt
	echo -e ${DG}"https://github.com/Russkkov" >> escaneo_$ipad.txt
	echo -e "" >> escaneo_$ipad.txt
        echo -e "" >> escaneo_$ipad.txt
        echo -e "" >> escaneo_$ipad.txt
        echo -e ${YELLOW}"\n[+] Buscando IP activas en la red indicada.\n"
	sleep 1
        echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $ipa.0:\n" | tee -a /dev/tty >> escaneo_$ipad.txt
                for h in $(seq 1 255); do
                        timeout 2 bash -c "ping -c 1 $ipa.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$ipa.$h${BLUE} está activa" | tee -a /dev/tty >> escaneo_$ipad.txt &
                done; wait
                echo ${NC} | tee -a /dev/tty >> escaneo_$ipad.txt
}
###########################################
#--------------[ AUTOSCAN ]---------------#
###########################################
i_c=0
e_c=0
while getopts ":he-:i:" opt; do
   patch_lo "help ayuda ip: exportar" opt "$@"
   patch_dash
   case $opt in
        h|help|ayuda)
                ayuda
                exit 0
        ;;
        \?)
                echo -e ${RED}"\n[!] El parámetro introducido [-$OPTARG] no es válido."${NC}
                echo -e ${LG}"\tUsa la opción --ayuda, --help o -h para más información."${NC}
                exit 1
        ;;
        :)
                echo -e ${RED}"\n[!] El parámetro [-$OPTARG] requiere un argumento."${NC}
                echo -e ${LG}"\tUsa la opción --ayuda, --help o -h para más información."${NC}
                exit 1
        ;;
        i|ip)
		i_c=1
                ipe=$OPTARG
        ;;
        e|exportar)
                e_c=1
        ;;
   esac
done
        if [[ $# -eq 0 ]]; then
                 escanear
	elif [[ $i_c -eq 1 ]] && [[ $e_c -eq 1 ]]; then
		escanear_ip_exp
	elif [[ $i_c -eq 1 ]] && [[ $e_c -eq 0 ]]; then
		escanear_ip
	elif [[ $e_c -eq 1 ]]; then
		escanear_exp
        else
                echo -e ${RED}"\n[!] Usa la opción --ayuda, --help o -h para más información."${NC}
                exit 1

        fi


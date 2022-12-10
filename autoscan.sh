#!/bin/bash

#Desarrollado por Russkkov
#https://github.com/Russkkov

#Script para escanear el rango de direcciones IP de las redes a las que estamos conectados y los puertos abiertos en las IP que estén activas.
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
DG_ITALIC="${C}[1;90m${C}[3m"
NC="${C}[0m"
###########################################
#--------------[ Variables ]--------------#
###########################################
dia=$(date +"%d/%m/%Y")
hora=$(date +"%H:%M")
mensaje_inicio=$(echo -e ${DG}"[i] ${DG_ITALIC}Iniciando AutoScan (https://github.com/Russkkov/autoscan) a las $hora del $dia"${NC})
###########################################
#-------------[ COMPROBAR ]---------------#
###########################################
function comprobar_ip(){
	ip_c=$1
	stat=1
	if [[ $ip_c =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip_c=($ip_c)
		IFS=$OIFS
		[[ ${ip_c[0]} -le 255 && ${ip_c[1]} -le 255  && ${ip_c[2]} -le 255 && ${ip_c[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}
function comprobar_puerto(){
        puer_c=$1
        stat=1
        if [[ $puer_c =~ ^[0-9]{1,3}$ ]]; then
                OIFS=$IFS
                IFS='.'
                puer_c=($puer_c)
                IFS=$OIFS
                [[ ${puer_c[0]} -le 255 ]]
                stat=$?
        fi
        return $stat
}
###########################################
#--------------[ Progreso ]---------------#
###########################################
barra_escala=2
function mostrar_progreso {
	actual="$1"
	total="$2"
	porcentaje=$((100 * $actual / $total))
	timeout 2 echo -ne "\r                ${DG_ITALIC}Progreso: [${porcentaje}%]\r"
	if [ $total -eq $actual ]; then
		echo -e "\n"
	fi
}
###########################################
#---------------[ Abortar ]---------------#
###########################################
function ctrl_c(){
	echo -e ${RED}"\n\t[!] Escaneo interrumpido manualmente.\n"
	if [[ -f listado_ip.tmp ]]; then
		rm listado_ip.tmp
	fi
	if [[ -f listado_2.tmp ]]; then
		rm listado_2.tmp
	fi
	if [[ -f listado_22.tmp ]]; then
		rm listado_22.tmp
	fi
	if [[ -f listado_3.tmp ]]; then
		rm listado_3.tmp
	fi
	if [[ -f listado_excluir.tmp ]]; then
		rm listado_excluir.tmp
	fi
	if [[ -f listado_excluir2.tmp ]]; then
		rm listado_excluir2.tmp
	fi
	exit 1
}
trap ctrl_c INT
###########################################
#----------------[ Ayuda ]----------------#
###########################################
ayuda(){
        echo -e ${YELLOW}"\n[+] Panel de ayuda de AutoSCAN\n"${NC}
        echo -e ${DG}"AutoSCAN es un script para esanear el rango de direcciones IP de las redes con las que tenemos conexión y detectar las IP que están activas."
	echo -e "Opcionalmente se pueden escanear los puertos de cada dirección IP activa y localizar aquellos puertos que estén abiertos (${YELLOW}ver Uso 5${DG}).\n\n"
        echo -e "Asimismo puede escanearse únicamente una red concreta dada (${YELLOW}ver Uso 2${DG}) y también los puertos que estén abiertos en las IP que se localicen (${YELLOW}ver Uso 6${DG}).\n\n"
        echo -e "También pueden buscarse los puertos abiertos para una única IP (${YELLOW}ver Uso 7${DG})."
	echo -e "O puede comprobarse si un puerto concreto está abierto o cerrado para una IP específica (${YELLOW}ver Uso 8${DG}).\n\n"
	echo -e "La información obtenida en los escaneos puede guardarse en un archivo (${YELLOW}ver Uso 3 y Uso 4${DG}).\n\n"
	echo -e ${YELLOW}"[-] Uso 1: autoscan.sh"
        echo -e ${DG}"\tSi se ejecuta el script sin parámetros realizará un escaneo en todas las redes a las que estén conectadas nuestras interfaces de red.\n\n"
        echo -e ${YELLOW}"[-] Uso 2: autoscan.sh [-i][-ip] <IP>"
        echo -e ${DG}"\tPara escanear solo una red se usa el parámetro -i o --ip seguido de la dirección IP (-i 127.0.0.0 o --ip 127.0.0.0)."
	echo -e "\tPuede usarse cualquier dirección IP que pertenezca al rango de direcciones, no es necesario que sea nuestra propia IP."
        echo -e "\tPara guardar en un archivo el resultado del escaneo ve al Uso 4.\n\n"
        echo -e ${YELLOW}"[-] Uso 3: autoscan.sh [-e][--exportar]"
        echo -e ${DG}"\tSi se usa únicamente el parámetro -e o --exportar se realizará el escaneo descrito en el Uso 1 y se guardará en un archivo .txt en la ruta actual (visualizar con cat).\n\n"
        echo -e ${YELLOW}"[-] Uso 4: autoscan.sh [-i][--ip] <IP> [-e][--exportar]"
        echo -e ${DG}"\tSi se usa el parémtro -e o --exportar junto con el parámetro -i o --ip seguido de la IP se realizará el escaneo descrito en el Uso 2 y se guardará un archivo .txt en la ruta actual (visualizar con cat).\n\n"
        echo -e ${YELLOW}"[-] Uso 5: autoscan.sh [-p][--puerto][--port]"
	echo -e ${DG}"\tSi se usa únicamente el parámetro -p, --puerto o --port se realizará el escaneo descrito en el Uso 1 y se buscarán puertos abiertos en cada IP que haya encontrado activa (este modo puede consumir muchos recursos y demorar bastante tiempo).\n\n"
	echo -e ${YELLOW}"[-] Uso 6: autoscan.sh [-i][--ip] <IP> [-p][--puerto][--port]"
	echo -e ${DG}"\tSi se usa el parámetro -i o --ip seguido de la dirección IP junto con el parámetro -p, --puerto o --port (-i 127.0.0.0 -p) se realizará el escaneo descrito en el Uso 2 y se buscarán los puertos abiertos en cada IP que haya encontrado activa (este modo puede consumir muchos recursos y demorar bastante tiempo).\n\n"
	echo -e ${YELLOW}"[-] Uso 7: autoscan.sh [-d] <IP>"
	echo -e ${DG}"\tSi se usa el parámetro -d seguido de la dirección IP (-d 127.0.0.0) se buscarán los puertos abiertos para la IP indicada.\n\n"
	echo -e ${YELLOW}"[-] Uso 8: autoscan.sh [-d] <IP> [-t] <Puerto>"
	echo -e ${DG}"\tSi se usa el parámatro -d seguido de la dirección IP junto con el parámetro -t seguido del número de puerto (-d 127.0.0.0 -t 8080) se comprobará si para esa IP el puerto indicado está abierto o cerrado.\n\n"
	echo -e ${YELLOW}"[-] Uso 9: autoscan.sh [-h][--help][--ayuda]"
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
	momento_inicio=$(date +%T)
        inicio_segundos=$(date -d "$momento_inicio" +%s)
        echo -e "\n$mensaje_inicio\n\n"
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
			timeout 2 bash -c "ping -c 1 $i.$h" &>/dev/null && echo -e ${BLUE}"                La IP ${RED}$i.$h${BLUE} está activa"${NC} &
		done; wait
		echo
	done
        momento_fin=$(date +%T)
        fin_segundos=$(date -d "$momento_fin" +%s)
        diferencia_segundos=$(($fin_segundos - $inicio_segundos))
        transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
        transcurrido_segundos=$(($diferencia_segundos % 60))
        echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
}
###########################################
#---------[ ESCANEAR EXPORTADO ]----------#
###########################################
escanear_exp(){
	momento_inicio=$(date +%T)
        inicio_segundos=$(date -d "$momento_inicio" +%s)
        echo -e "\n$mensaje_inicio\n\n"
        echo -e ${DG}"#AutoSCAN" > escaneo_completo.txt
        echo -e ${DG}"#Creado por Russkkov" >> escaneo_completo.txt
        echo -e "${DG}#https://github.com/Russkkov" >> escaneo_completo.txt
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
        momento_fin=$(date +%T)
        fin_segundos=$(date -d "$momento_fin" +%s)
        diferencia_segundos=$(($fin_segundos - $inicio_segundos))
        transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
        transcurrido_segundos=$(($diferencia_segundos % 60))
        echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
}
###########################################
#--------[ ESCANEAR CON PUERTOS ]---------#
###########################################
escanear_puertos(){
	momento_inicio=$(date +%T)
	inicio_segundos=$(date -d "$momento_inicio" +%s)
	echo -e "\n$mensaje_inicio\n\n"
        echo -e ${YELLOW}"[+] Buscando interfaces de red.\n"
        sleep 1
        echo -e "[+] Conexión de red en:\n"
        lista_ip=$(ip addr | grep "inet " | awk '{print $2}' FS=" "| awk '{print $1}' FS="/")
	ip addr | grep "inet " | awk '{print $2}' FS=" "| awk '{print $1}' FS="/" | grep -vE "*127.0.0" > listado_excluir.tmp
        for j in ${lista_ip[@]}; do
                echo -e ${BLUE}"\t$j"
        done
        sleep 1
        echo -e ${YELLOW}"\n[+] Buscando IP activas en las redes encontradas.\n"
        ips=$(ip addr | grep "inet " | awk '{print $2}' FS=" " | awk '{print $1"."$2"."$3}' FS="." | grep -v "127.0.0")
        for i in ${ips[@]}; do
                echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $i.0:\n"
                for h in $(seq 1 255); do
                        timeout 2 bash -c "ping -c 1 $i.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$i.$h${BLUE} está activa"${NC} | tee -a /dev/tty >> listado_ip.tmp  &
                done; wait
                echo
        done
	cat listado_ip.tmp | awk '{print $4}' FS=" " | sed "s/^.//g" | sed 's/\[1;31m//g' | sed 's/\[1;34m//g' | sed 's/.$//g' > listado_2.tmp
	sort -u listado_2.tmp > listado_22.tmp
	sort -u listado_excluir.tmp > listado_excluir2.tmp
	comm -3 listado_22.tmp listado_excluir2.tmp > listado_3.tmp
        echo -e ${YELLOW}"\n[+] Buscando puertos abiertos en las IP encontradas.\n"
	while read -r ipli; do
		echo -e ${LIGHT_MAGENTA}"\t[-] Puertos abiertos en la IP $ipli:\n"
		total_puertos=65535
		for port in $(seq 1 65535); do
			mostrar_progreso $port $total_puertos
			timeout 2 bash -c "echo '' > /dev/tcp/$ipli/$port" &>/dev/null && echo -e ${BLUE}"                Puerto ${RED}$port ${BLUE}abierto" &
		done; wait
		echo ${NC}
	done < listado_3.tmp
	momento_fin=$(date +%T)
	fin_segundos=$(date -d "$momento_fin" +%s)
	diferencia_segundos=$(($fin_segundos - $inicio_segundos))
	transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
	transcurrido_segundos=$(($diferencia_segundos % 60))
	echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
	rm listado_ip.tmp
	rm listado_2.tmp
	rm listado_3.tmp
	rm listado_22.tmp
	rm listado_excluir.tmp
	rm listado_excluir2.tmp
}

###########################################
#-------------[ ESCANEAR IP ]-------------#
###########################################
escanear_ip(){
	if comprobar_ip $ipe; then
		momento_inicio=$(date +%T)
                inicio_segundos=$(date -d "$momento_inicio" +%s)
	        echo -e "\n$mensaje_inicio\n\n"
		ipa=$(echo $ipe | awk '{print $1"."$2"."$3}' FS=".")
		echo -e ${YELLOW}"[+] Buscando IP activas en la red indicada.\n"
		sleep 1
		echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $ipa.0:\n"
		        for h in $(seq 1 255); do
		                timeout 2 bash -c "ping -c 1 $ipa.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$ipa.$h${BLUE} está activa"${NC} &
		        done; wait
		        echo
		        momento_fin=$(date +%T)
	        fin_segundos=$(date -d "$momento_fin" +%s)
        	diferencia_segundos=$(($fin_segundos - $inicio_segundos))
        	transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
        	transcurrido_segundos=$(($diferencia_segundos % 60))
        	echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
	else
		echo -e ${RED}"\n[!] Introduce una IP válida.\nUsa la opción --ayuda, --help o -h para más información."${NC}
		exit 1
	fi
}
###########################################
#--------[ ESCANEAR IP EXPORTADO ]--------#
###########################################
escanear_ip_exp(){
	if comprobar_ip $ipe; then
	        momento_inicio=$(date +%T)
                inicio_segundos=$(date -d "$momento_inicio" +%s)
		echo -e "\n$mensaje_inicio\n\n"
		ipad=$(echo $ipe | awk '{print $1 $2 $3}' FS=".")
		ipa=$(echo $ipe | awk '{print $1"."$2"."$3}' FS=".")
		echo -e ${DG}"#AutoSCAN" > escaneo_$ipad.txt
		echo -e ${DG}"#Creado por Russkkov" >> escaneo_$ipad.txt
		echo -e ${DG}"#https://github.com/Russkkov" >> escaneo_$ipad.txt
		echo -e "" >> escaneo_$ipad.txt
	        echo -e "" >> escaneo_$ipad.txt
	        echo -e "" >> escaneo_$ipad.txt
	        echo -e ${YELLOW}"[+] Buscando IP activas en la red indicada.\n"
		sleep 1
	        echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $ipa.0:\n" | tee -a /dev/tty >> escaneo_$ipad.txt
	                for h in $(seq 1 255); do
	                        timeout 2 bash -c "ping -c 1 $ipa.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$ipa.$h${BLUE} está activa" | tee -a /dev/tty >> escaneo_$ipad.txt &
	                done; wait
	                echo ${NC} | tee -a /dev/tty >> escaneo_$ipad.txt
	        momento_fin=$(date +%T)
        	fin_segundos=$(date -d "$momento_fin" +%s)
        	diferencia_segundos=$(($fin_segundos - $inicio_segundos))
        	transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
        	transcurrido_segundos=$(($diferencia_segundos % 60))
        	echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
        else
                echo -e ${RED}"\n[!] Introduce una IP válida.\nUsa la opción --ayuda, --help o -h para más información."${NC}
		exit 1
        fi
}
###########################################
#--------[ ESCANEAR IP Y PUERTOS]---------#
###########################################
escanear_ip_puertos(){
	if comprobar_ip $ipe; then
	        momento_inicio=$(date +%T)
	        inicio_segundos=$(date -d "$momento_inicio" +%s)
	        echo -e "\n$mensaje_inicio\n\n"
	        ipa=$(echo $ipe | awk '{print $1"."$2"."$3}' FS=".")
		ip addr | grep "inet " | awk '{print $2}' FS=" "| awk '{print $1}' FS="/" | grep "$ipa*" > listado_excluir.tmp
	        echo -e ${YELLOW}"\n[+] Buscando IP activas en la red indicada.\n"
	        sleep 1
	        echo -e ${LIGHT_MAGENTA}"\t[-] IP activas para la dirección $ipa.0:\n"
	                for h in $(seq 1 255); do
	                        timeout 2 bash -c "ping -c 1 $ipa.$h" &>/dev/null && echo -e ${BLUE}"\t\tLa IP ${RED}$ipa.$h${BLUE} está activa"${NC} | tee -a /dev/tty >> listado_ip.tmp &
	                done; wait
	                echo
	        cat listado_ip.tmp | awk '{print $4}' FS=" " | sed "s/^.//g" | sed 's/\[1;31m//g' | sed 's/\[1;34m//g' | sed 's/.$//g' > listado_2.tmp
	        sort -u listado_2.tmp > listado_22.tmp
	        sort -u listado_excluir.tmp > listado_excluir2.tmp
	        comm -3 listado_22.tmp listado_excluir2.tmp > listado_3.tmp
	        echo -e ${YELLOW}"\n[+] Buscando puertos abiertos en las IP encontradas.\n"
	        while read -r ipli; do
	                echo -e ${LIGHT_MAGENTA}"\t[-] Puertos abiertos en la IP $ipli:\n"
	                total_puertos=65535
	                for port in $(seq 1 65535); do
	                        mostrar_progreso $port $total_puertos
	                        timeout 2 bash -c "echo '' > /dev/tcp/$ipli/$port" &>/dev/null && echo -e ${BLUE}"                Puerto ${RED}$port ${BLUE}abierto" &
	                done; wait
	                echo ${NC}
	        done < listado_3.tmp
	        momento_fin=$(date +%T)
	        fin_segundos=$(date -d "$momento_fin" +%s)
	        diferencia_segundos=$(($fin_segundos - $inicio_segundos))
	        transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
	        transcurrido_segundos=$(($diferencia_segundos % 60))
	        echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
	        rm listado_ip.tmp
	        rm listado_2.tmp
	        rm listado_3.tmp
	        rm listado_22.tmp
	        rm listado_excluir.tmp
	        rm listado_excluir2.tmp
        else
                echo -e ${RED}"\n[!] Introduce una IP válida.\nUsa la opción --ayuda, --help o -h para más información."${NC}
		exit 1
        fi

}
###########################################
#--------[ ESCANEAR PUERTOS DE IP]--------#
###########################################
escanear_puertos_ip(){
	if comprobar_ip $ipd; then
	        momento_inicio=$(date +%T)
	        inicio_segundos=$(date -d "$momento_inicio" +%s)
	        echo -e "\n$mensaje_inicio\n\n"
		echo -e ${YELLOW}"\n[+] Buscando puertos abiertos en la IP indicada.\n"
		sleep 1
	        echo -e ${LIGHT_MAGENTA}"\t[-] Puertos abiertos en la IP $ipd:\n"
	        total_puertos=65535
	        for port in $(seq 1 65535); do
		        mostrar_progreso $port $total_puertos
	        	timeout 2 bash -c "echo '' > /dev/tcp/$ipd/$port" &>/dev/null && echo -e ${BLUE}"                Puerto ${RED}$port ${BLUE}abierto" &
	        done; wait
	        echo ${NC}
	        momento_fin=$(date +%T)
	        fin_segundos=$(date -d "$momento_fin" +%s)
	        diferencia_segundos=$(($fin_segundos - $inicio_segundos))
	        transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
	        transcurrido_segundos=$(($diferencia_segundos % 60))
	        echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
        else
                echo -e ${RED}"\n[!] Introduce una IP válida.\nUsa la opción --ayuda, --help o -h para más información."${NC}
		exit 1
        fi

}
###########################################
#--------[ ESCANEAR PUERTO DE IP]--------#
###########################################
escanear_puerto_ip(){
        if comprobar_ip $ipd; then
		if comprobar_puerto $puer; then
	                momento_inicio=$(date +%T)
	                inicio_segundos=$(date -d "$momento_inicio" +%s)
	                echo -e "\n$mensaje_inicio\n\n"
	                echo -e ${YELLOW}"[+] Comprobando el puerto ${BLUE}$puer${YELLOW} para la IP ${BLUE}$ipd${YELLOW}:\n"
	                sleep 1
                        timeout 2 bash -c "echo '' > /dev/tcp/$ipd/$puer" &>/dev/null && echo -e ${BLUE}"        [-] Puerto ${GREEN}abierto" || echo -e ${BLUE}"        [-] Puerto ${RED}cerrado"
	                echo ${NC}
			echo
		else
			echo -e ${RED}"\n[!] Introduce un puerto válido.\nUsa la opción --ayuda, --help o -h para más información."${NC}
                	exit 1
		fi
		momento_fin=$(date +%T)
                fin_segundos=$(date -d "$momento_fin" +%s)
                diferencia_segundos=$(($fin_segundos - $inicio_segundos))
                transcurrido_minutos=$((($diferencia_segundos % 3600)/60))
                transcurrido_segundos=$(($diferencia_segundos % 60))
                echo -e ${DG}"[i] ${DG_ITALIC}Escaneo con AutoSCAN finalizado en $transcurrido_minutos minutos y $transcurrido_segundos segundos a las $hora del $dia."${NC}
        else
                echo -e ${RED}"\n[!] Introduce una IP válida.\nUsa la opción --ayuda, --help o -h para más información."${NC}
                exit 1
        fi

}
###########################################
#--------------[ AUTOSCAN ]---------------#
###########################################
i_c=0
e_c=0
while getopts ":he-:i:pd:t:" opt; do
   patch_lo "help ayuda ip: exportar puerto port" opt "$@"
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
	p|puerto|port)
		p_c=1
	;;
	d)
		d_c=1
		ipd=$OPTARG
	;;
	t)
		t_c=1
		puer=$OPTARG
   esac
done
        if [[ $# -eq 0 ]]; then
                 escanear
	elif [[ $i_c -eq 1 ]] && [[ $e_c -eq 1 ]] && [[ $p_c -eq 0 ]] && [[ $d_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
		escanear_ip_exp
	elif [[ $i_c -eq 1 ]] && [[ $e_c -eq 0 ]] && [[ $p_c -eq 0 ]] && [[ $d_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
		escanear_ip
	elif [[ $# -eq 1 ]] && [[ $e_c -eq 1 ]] && [[ $d_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
		escanear_exp
	elif [[ $# -eq 0 ]] && [[ $p_c -eq 0 ]] && [[ $d_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
		escanear
	elif [[ $# -eq 1 ]] && [[ $p_c -eq 1 ]]; then
		escanear_puertos
	elif [[ $i_c -eq 1 ]] && [[ $p_c -eq 1 ]] && [[ $e_c -eq 0 ]] && [[ $d_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
		escanear_ip_puertos
        elif [[ $i_c -eq 1 ]] && [[ $p_c -eq 1 ]] && [[ $e_c -eq 1 ]] && [[ $d_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
                echo -e ${RED}"\n[!] Exportación no disponible para este modo.\n${LG}\tUsa la opción --ayuda, --help o -h para más información."${NC}
                exit 1
	elif [[ $d_c -eq 1 ]] && [[ $i_c -eq 0 ]] && [[ $e_c -eq 0 ]] && [[ $p_c -eq 0 ]] && [[ $t_c -eq 0 ]]; then
		escanear_puertos_ip
	elif [[ $d_c -eq 1 ]] && [[ $i_c -eq 0 ]] && [[ $e_c -eq 0 ]] && [[ $p_c -eq 0 ]] && [[ $t_c -eq 1 ]]; then
		escanear_puerto_ip
        else
                echo -e ${RED}"\n[!] Parámetro incorrecto o incompleto.\n${LG}\tUsa la opción --ayuda, --help o -h para más información."${NC}
                exit 1

        fi



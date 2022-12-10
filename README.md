# AutoSCAN

AutoSCAN es un script para esanear el rango de direcciones IP de las redes con las que tenemos conexión y detectar las IP que están activas.
Opcionalmente se pueden escanear los puertos de cada dirección IP activa y localizar aquellos puertos que estén abiertos (ver Uso 5)

Asimismo puede escanearse únicamente una red concreta dada (ver Uso 2) y también los puertos que estén abiertos en las IP que se localicen (ver Uso 6).

También pueden buscarse los puertos abiertos para una única IP (ver Uso 7).
O puede comprobarse si un puerto concreto está abierto o cerrado para una IP específica (ver Uso 8).

La información obtenida en los escaneos puede guardarse en un archivo (ver Uso 3 y Uso 4).

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

# v2.0

Añadidas nuevas funciones:

**-Buscar puertos abiertos en las IP activas encontradas al escanear las redes a las que estamos conectados.**

**-Buscar puertos abiertos en las IP activas encontradas al escanear la red indicada.**

**-Buscar puertos abiertos para una única dirección IP indicada.**

**-Comprobar si un puerto concreto está abierto o cerrado para una IP indicada.**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

# Instalación

git clone https://github.com/Russkkov/autoscan.git

cd autoscan

chmod +x autoscan.sh

cp autoscan.sh /usr/bin

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

# Uso

**- Uso 1: autoscan.sh**

```
autoscan.sh
```
 Si se ejecuta el script sin parámetros realizará un escaneo en todas las redes a las que estén conectadas nuestras interfaces de red.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 2: autocan.sh [-i][-ip] {IP}**
  
 ```
 p.e.: autoscan.sh -i 127.0.0.1
 ```
 
Para escanear solo una red se usa el parámetro -i o --ip seguido de la dirección IP (-i 127.0.0.0 o --ip 127.0.0.0).

Puede usarse cualquier dirección IP que pertenezca al rango de direcciones, no es necesario que sea nuestra propia IP.

Para guardar en un archivo el resultado del escaneo ver Uso 4.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 3: autoscan.sh [-e][--exportar]**

```
autoscan.sh -e
```

Si se usa el parámetro -e o --exportar se realizará el escaneo descrito en el Uso 1 y se guardará en un archivo .txt en la ruta actual.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 4: autoscan.sh [-i][--ip] {IP} [-e][--exportar]**

```
p.e.: autoscan.sh -i 127.0.0.1 -e
```

Si se usa el parémtro -e o --exportar junto con el parámetro -i o --ip seguido de la IP se realizará el escaneo descrito en el Uso 2 y se guardará un archivo .txt en la ruta actual.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 5: autoscan.sh [-p][--puerto][--port]**

```
autoscan.sh -p
```
Si se usa únicamente el parámetro -p, --puerto o --port se realizará el escaneo descrito en el Uso 1 y se buscarán puertos abiertos en cada IP que haya encontrado activa (este modo puede consumir muchos recursos y demorar bastante tiempo).

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 6: autoscan.sh [-i][--ip] {IP} [-p][--puerto][--port]**

```
p.e.: autoscan.sh -i 127.0.0.1 -p
```
Si se usa el parámetro -i o --ip seguido de la dirección IP junto con el parámetro -p, --puerto o --port (-i 127.0.0.0 -p) se realizará el escaneo descrito en el Uso 2 y se buscarán los puertos abiertos en cada IP que haya encontrado activa (este modo puede consumir muchos recursos y demorar bastante tiempo).

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 7: autoscan.sh [-d] {IP}**

```
p.e.: autoscan.sh -d 127.0.0.1
```
Si se usa el parámetro -d seguido de la dirección IP (-d 127.0.0.0) se buscarán los puertos abiertos para la IP indicada.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 8: autoscan.sh [-d] <IP> [-t] <Puerto>**

```
p.e.: autoscan.sh -d 127.0.0.1 -t 8080
```
Si se usa el parámatro -d seguido de la dirección IP junto con el parámetro -t seguido del número de puerto (-d 127.0.0.0 -t 8080) se comprobará si para esa IP el puerto indicado está abierto o cerrado.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 9: autoscan.sh [-h][--help][--ayuda]**

```
autoscan.sh -h
```

Si se usa el parémtro -h, --help o --ayuda se mostrará este panel de ayuda.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

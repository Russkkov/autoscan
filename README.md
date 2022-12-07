# AutoSCAN

AutoSCAN es un script para esanear el rango de direcciones IP de las redes con las que tenemos conexión y detectar las IP que están activas.

También puede escanearse únicamente una red concreta dada (ver Uso 2).

En cualquiera de las dos formas de escaneo puede guardarse en un archivo la información obtenida (ver Uso 3 y Uso 4).

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
p.e.: autoscan.sh -e
```

Si se usa el parámetro -e o --exportar se realizará el escaneo descrito en el Uso 1 y se guardará en un archivo .txt en la ruta actual.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 4: autoscan.sh [-i][--ip] {IP} [-e][--exportar]**

```
autoscan.sh -i 127.0.0.1 -e
```

Si se usa el parémtro -e o --exportar junto con el parámetro -i o --ip seguido de la IP se realizará el escaneo descrito en el Uso 2 y se guardará un archivo .txt en la ruta actual.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

**- Uso 5: autoscan.sh [-h][--help][--ayuda]**

```
autoscan.sh -h
```

Si se usa el parémtro -h, --help o --ayuda se mostrará este panel de ayuda.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

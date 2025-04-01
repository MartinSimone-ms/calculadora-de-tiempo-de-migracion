#!/bin/bash

# Solicitud de datos del usuario

# Pedir tamaño de datos con validación
echo -n "Ingrese el tamaño total de datos a migrar: "
read tamano_total

while true; do
	echo -n "Ingrese la unidad (PT, TB, GB, MB, KB): "
	read unidad_tamanio
	
	# Calcular el tamaño en MB, independientemente de la unidad que ingresemos
	case "$unidad_tamanio" in
		PT|pt) tamano_parseado=$(echo "$tamano_total * 1024 * 1024 * 1024" | bc); break ;;
		TB|tb) tamano_parseado=$(echo "$tamano_total * 1024 * 1024" | bc); break ;;
		GB|gb) tamano_parseado=$(echo "$tamano_total * 1024" | bc); break ;;
		MB|mb) tamano_parseado=$tamano_total; break ;;
		KB|kb) tamano_parseado=$(echo "$tamano_total / 1024" | bc); break ;;
		*)
			echo -e "Unidad no válida. Usa PT, TB, GB, MB o KB."
			continue
		;;
	esac
done

# Pedir velocidad de transferencia con validación
echo -n "Ingrese la velocidad de transferencia: "
read velocidad_transferencia

while true; do
	echo -n "Ingresa la unidad (Tb/s (5), Gb/s (4), Mb/s (3), Kb/s (2), b/s (1)): "
	read unidad_transferencia

	# Calcular la velocidad en MB/s, independientemente de la unidad que ingresemos
	case "$unidad_transferencia" in
		Tb/s|5) velocidad_parseada=$(echo "($velocidad_transferencia * 1000 * 1000) / 8" | bc); break ;;
    		4) velocidad_parseada=$(echo "$velocidad_transferencia * 1000 / 8" | bc); break ;;
    		3) velocidad_parseada=$(echo "$velocidad_transferencia / 8" | bc); break ;;
    		2) velocidad_parseada=$(echo "($velocidad_transferencia / 1000) / 8" | bc); break ;;
    		1) velocidad_parseada=$(echo "$velocidad_transferencia / (8 * 1000000)" | bc); break ;;  # Convierte b/s a MB/s
    		*)
        		echo "Unidad no válida. Usa Tb/s, Gb/s, Mb/s, Kb/s o b/s."
        		continue
    		;;
	esac
done

# Calcular el tiempo de la migracion 
tiempo_segundos=$(echo "scale=2; $tamano_parseado / $velocidad_parseada" | bc)

# Extraer la parte entera del tiempo en segundos
tiempo_segundos_entero=$(echo "$tiempo_segundos" | bc | awk '{print int ($1)}')

# Calcular días, horas, minutos y segundos

# Dias completos que caben en tiempo_segundos_entero
dias=$((tiempo_segundos_entero / 86400))
# Segundos restantes luego de contar los dias, dividido por 3600 para convertirlos en horas restantes luego de contar los dias
horas=$(((tiempo_segundos_entero % 86400) / 3600))
# Minutos restantes luego de contar los dias y las horas
minutos=$(((tiempo_segundos_entero % 3600) / 60))
# Segundos restantes luego de contar los dias, horas y minutos
segundos=$((tiempo_segundos_entero % 60))

# Mostrar el resultado segun la duración
if [ $dias -gt 0 ]; then
	echo "La migración de $tamano_total TB a $velocidad_transferencia Gb/s tardará $dias días, $horas horas, $minutos minutos y $segundos segundos."
elif [ $horas -gt 0 ]; then
	echo "La migración de $tamano_total TB a $velocidad_transferencia Gb/s tardará $horas horas, $minutos minutos y $segundos segundos."
elif [ $minutos -gt 0 ]; then
	echo "La migración de $tamano_total TB a $velocidad_transferencia Gb/s tardará $minutos minutos y $segundos segundos."
else
	echo "La migración de $tamano_total TB a $velocidad_transferencia Gb/s tardará $segundos segundos."
fi


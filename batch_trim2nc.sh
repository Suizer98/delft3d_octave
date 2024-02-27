# Get the directory path of the script
script_dir=$(dirname "$0")

for filename in $(find "$script_dir" -type f -name "trim-scsmCddb*.dat"); do
	echo "Currently converting $filename"
	if [ -f "${filename%.dat}.nc" ]; then
		echo "${filename%.dat}.nc already exists"
		echo ""
	else
		log_file="$(basename "${filename%.dat}.log")"
		echo "Writing log $log_file"
       		octave --eval "vs_trim2nc2( '$filename', 'timezone', '+08:00' )"
			# octave --eval "vs_trim2nc( '$filename',  'Format', '64bit', 'epsg', 32651, 'timezone', '+08:00' )" > "$log_file"  2>&1
	fi
done
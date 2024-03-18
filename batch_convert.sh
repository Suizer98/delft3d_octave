# Get the directory path of the script
script_dir=$(dirname "$0")

for filename in $(find "$script_dir" -type f -name "trim*.dat"); do
	echo "Currently converting $filename"
	if [ -f "${filename%.dat}.nc" ]; then
		echo "${filename%.dat}.nc already exists"
		echo ""
	else
		log_file="$(basename "${filename%.dat}.log")"
		echo "Writing log $log_file"
       		octave --eval "vs_trim2nc( '$filename' )"
			# octave --eval "vs_trim2nc( '$filename',  'Format', '64bit', 'epsg', 32651, 'timezone', '+08:00' )" > "$log_file"  2>&1
	fi
done

for filename in $(find "$script_dir" -type f -name "trih*.dat"); do
	echo "Currently converting $filename"
	if [ -f "${filename%.dat}.nc" ]; then
		echo "${filename%.dat}.nc already exists"
		echo ""
	else
		log_file="$(basename "${filename%.dat}.log")"
		echo "Writing log $log_file"
       		octave --eval "vs_trih2nc( '$filename' )"
			# octave --eval "vs_trim2nc( '$filename',  'Format', '64bit', 'epsg', 32651, 'timezone', '+08:00' )" > "$log_file"  2>&1
	fi
done

# Run Python
python3 slicedata.py
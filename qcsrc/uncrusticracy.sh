FILES=`find client common menu server warpzonelib -name \*.c -o -name \*.h -o -name \*.qc -o -name \*.qh`
out_raw()
{
	printf "%s\n" "$LINE"
}
out()
{
	printf "%-40s = %-8s # %s\n" "$KEY" "$VAL" "$COMMENT"
}
decide()
{
	verybestchoice=
	verybestscore=2147483647
	bestchoice=
	bestscore=2147483647
	secondbestchoice=
	secondbestscore=2147483647
	worstscore=0
	haveignore=false
	havefalse=false
	have0=false
	seen=
	for choice in "$VAL" "$@"; do
		case " $seen " in
			*" $choice "*)
				continue
				;;
			*)
				seen=$seen" $VAL"
				;;
		esac
		if [ x"$choice" = x"force" ]; then
			continue
		fi
		if [ x"$choice" = x"ignore" ]; then
			haveignore=true
		fi
		if [ x"$choice" = x"false" ]; then
			havefalse=true
		fi
		if [ x"$choice" = x"0" ]; then
			have0=true
		fi
		if [ x"$MODE" = x"initialize" ]; then
			if [ x"$choice" = x"ignore" ]; then
				score=0
			else
				score=2147483647
			fi
		else
			{
				cat uncrustify.cfg
				printf "%s = %s\n" "$KEY" "$choice"
			} > uncrustify.cfg.test
			UNCRUSTIFY_CONFIG=uncrustify.cfg.test sh uncrustify.sh $FILES >/dev/null 2>&1
			status=$?
			if [ $status -gt 1 ]; then
				echo "# ERROR: $KEY = $choice crashes with status $status."
				continue
			fi
			score=0
			git diff --numstat > diffstat.tmp
			while read -r add del rest; do
				if [ x"$add" != x"-" ]; then
					score=$(($score + $add))
				fi
				if [ x"$del" != x"-" ]; then
					score=$(($score + $del))
				fi
			done < diffstat.tmp
			git reset --hard >/dev/null 2>&1
		fi
		echo >&2 "$KEY = $choice: $score"
		if [ x"$choice" != x"ignore" ]; then
			if [ $score -lt $bestscore ]; then
				secondbestscore=$bestscore
				secondbestchoice=$bestchoice
				bestscore=$score
				bestchoice=$choice
			elif [ $score -lt $secondbestscore ]; then
				secondbestscore=$score
				secondbestchoice=$choice
			fi
		fi
		if [ $score -lt $verybestscore ]; then
			verybestscore=$score
			verybestchoice=$choice
		fi
		if [ $score -gt $worstscore ]; then
			worstscore=$score
			worstchoice=$choice
		fi
	done
	if [ -z "$bestchoice" ]; then
		echo "# WARNING: No best choice identified"
	elif [ $verybestscore -ge $worstscore ]; then
		echo "# WARNING: Code doesn't seem to use this feature - delete from the config?"
		if $haveignore; then
			VAL=ignore
		elif $havefalse; then
			VAL=false
		elif $have0; then
			VAL=0
		fi
	elif [ $bestscore -ge $worstscore ]; then
		echo "# WARNING: Indifferent... please decide manually."
	elif [ $bestscore -ge $secondbestscore ]; then
		echo "# WARNING: Best is not unique ($bestchoice $secondbestchoice)"
	elif [ $bestscore -gt $verybestscore ]; then
		echo "# NOTE: is $(($bestscore - $verybestscore)) worse than $verybestchoice"
		VAL=$bestchoice
	else
		VAL=$bestchoice
	fi
}
while read -r LINE; do
	case "$LINE" in
		"# NOTE: "*)
			continue
			;;
		"# WARNING: "*)
			continue
			;;
		"# ERROR: "*)
			continue
			;;
		"#"*)
			out_raw
			continue
			;;
		*"#force"*|*"#ignore"*)
			out_raw
			continue
			;;
	esac
	printf "%s\n" "$LINE" | while read KEY EQ VAL DELIM COMMENT; do
		if \
			[ x"$EQ" != x"=" ] || \
			[ x"$DELIM" != x"#" ]; then
			out_raw
			continue
		fi
		case "$COMMENT" in
			number)
				case "$KEY" in
					indent_columns|*tab*)
						decide 1 2 4 8
						;;
					*)
						decide 0 1 2 3 indent_columns
						;;
				esac
				out
				;;
			string)
				printf "# WARNING: unsupported %s\n" "$COMMENT"
				out_raw
				;;
			*[!a-z/_]*)
				printf "# ERROR: invalid characters %s\n" "$COMMENT"
				out_raw
				;;
			*/*)
				decide `echo "$COMMENT" | tr / ' '`
				out
				;;
			*)
				printf "# ERROR: only once choice %s\n" "$COMMENT"
				out_raw
				;;
		esac
	done
done < uncrustify.cfg

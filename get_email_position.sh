filename=$1
arr_pos_mail=()
arr_pos_head_stop=()
line_idx=0
flag_email=0

# seach From r to split each email
while read line; do

    ((line_idx=line_idx+1))

    # detect email
    start_email=$(echo $line | sed -n -e '/From r/p')

    if [ ! -z "$start_email" ]

        then
            arr_pos_mail+=($line_idx)
            flag_email=1
            # echo "$line_idx"
            # echo $start_email
    fi

    # detect header stop
    space=$(echo $line | sed -n -e '/^[[:space:]]$/p')
    if [ ! -z "$space" ]

        then

            if [[ "$flag_email" -gt 0 ]]

                then
                arr_pos_head_stop+=($line_idx)
                flag_email=0
                # echo "found space"
                # echo "$line_idx"

            fi
    fi

done < $filename

arr_pos_mail+=($line_idx)
len_arr_pos_mail=${#arr_pos_mail[@]}
line_idx=0
idx=0

echo "Line is contain From r and Last Line"
for value in "${arr_pos_mail[@]}"
do
    echo "Line:" "$value"
done
echo "<><><><>"
echo "Line is stop header"
for value in "${arr_pos_head_stop[@]}"
do
    echo "Line:" "$value"
done
# echo "$#arr_pos_maili[@]"
# echo "$arr_pos_head_stop[@]"
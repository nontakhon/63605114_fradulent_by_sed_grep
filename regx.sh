#!/bin/bash
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

# Iterate the loop to read and print each array element
for value in "${arr_pos_mail[@]}"
do

    ((line_idx=line_idx+1))

    if [[ $line_idx -lt $len_arr_pos_mail ]]
    then

        start_pos=$value
        end_pos=${arr_pos_mail[$line_idx]}
        head_stop=${arr_pos_head_stop[$idx]}
        ((end_pos=end_pos-1))
        row=$start_pos,$end_pos'p'
        row_content=$head_stop,$end_pos'p'
        # echo $row_content
        # exit
        email_raw=$(cat $filename | sed -n $row)
        email_body=$(cat $filename | sed -n $row_content)

        # sender_name=$(echo "$email_raw" | sed -n -e '/From:/p'|sed -n -e '/".*"/p'|sed -e 's/From: //g'| sed -e 's/<.*>//g')
        # sender_email=$(echo "$email_raw" | sed -n -e '/From:/p'|sed -e 's/.*<//g'|sed -e 's/>.*//g')
        # recipient_name=$(echo "$email_raw" | sed -n -e '/^To:/p'|sed -n -e '/".*"/p'|sed -e 's/To: //g'| sed -e 's/<.*>//g')
        # recipient_email=$(echo "$email_raw" | sed -n -e '/^To:/p'|sed -e 's/To: //g'|sed -e 's/.*<//g'|sed -e 's/>.*//g')
        # date=$(echo "$email_raw" | sed -n -e '/Date:/p'|sed -e 's/Date:.[[:alpha:]]*[[:punct:]][[:space:]]//')
        # date=$(echo "$date" | sed -e 's/[[:digit:]][[:digit:]][[:punct:]].*$//g')

        sender_name=$(echo "$email_raw" | sed -n -e '/From:/p'|grep -o '".*"')
        sender_email=$(echo "$email_raw" | sed -n -e '/From:/p'|grep -o "[[:alpha:]][[:graph:]]*@[[:graph:]]*[[:alpha:]]")
        recipient_name=$(echo "$email_raw" | sed -n -e '/^To:/p'|grep -o '".*"')
        recipient_email=$(echo "$email_raw" | sed -n -e '/^To:/p'|grep -o "[[:alpha:]][[:graph:]]*@[[:graph:]]*[[:alpha:]]")
        date=$(echo "$email_raw" | sed -n -e '/Date:/p'|grep -o "[[:digit:]]\+[[:space:]][[:alpha:]]\+[[:space:]][[:digit:]]\+")
        about_money=$(echo "$email_raw" |grep -o -in "[USus ]*[$][0-9,.]*[Billion|Millon| ]*")
        about_money_data=$(echo "$email_raw" |grep -in "[USus ]*[$][0-9,.]*[Billion|Million| ]*")

        echo "sender name: ""$sender_name"
        echo "sender email: ""$sender_email"
        echo "recipient name: ""$recipient_name"
        echo "recipient email: ""$recipient_email"
        echo "Date: ""$date"
        echo "Email Body: "
        echo "$email_body"
        echo ""
        echo "--end of email--"
        echo "*** Analyze wording about money"
        echo $about_money        
        echo ""
        echo "*** sentence about money"
        echo -e $about_money_data        
        echo "<><><> END <><><>><>"
        ((idx=idx+1))
    fi

done

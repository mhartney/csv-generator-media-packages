
#!/usr/bin/bash

# Change working directory.
cd /home/mhartney/Documents/csv_drafts/new_deliver_csv/

# Set variable for date, month and outgoing paths.
date_month=$(date +"%Y.%m") # Date format YYYY.MM
date_day=$(date +"%Y.%m.%d") # Date format YYYY.MM.DD
date=$(date +"%Y%m%d") # Date format YYYYMMDD

outgoing_directory=$(echo "/lucas/ilm/show/paradox/staging/outgoing/to_client/$date_month/$date_day")
outgoing_dir_month=$(echo "/lucas/ilm/show/paradox/staging/outgoing/to_client/$date_month/")

# If statement to determine if we've sent a package today or not.
if [ -d "$outgoing_directory" ]; then
  echo -e "\nOutgoing directory path exists.\n"
else
  mkdir -p "$outgoing_directory"
fi

# Get the folder previously created. Which will be yesterday or day before.
last_folder=$(find "$outgoing_dir_month" -maxdepth 1 -type d | sort -nr | head -n 2 | tail -n 1)

# Set variables for sum to get new package number.
b=1

# Check if there's a folder within the outgoing directory, then get new package number.
if [ "$(find "$outgoing_directory" -maxdepth 1 -type d | grep ILM_)" ]; then
    echo "There is a previously sent folder in outgoing directory. Getting package number for new delivery."
    last_delivery_number=$(ls "$outgoing_directory" | cut -d '_' -f3 | cut -b1-4 | sort -nr | head -n1)
    echo -e "Last delivery number: $last_delivery_number"
    new_package_num=$(($last_delivery_number + $b))
    echo -e "New package number: $new_package_num"
else
    echo "There are no folders within the outer folder. Getting new package number from yesterdays folder."
    last_delivery_number=$(ls "$last_folder" | cut -d '_' -f3 | cut -b1-4 | sort -nr | head -n1)
    new_package_num=$(($last_delivery_number + $b))
    echo -e "Last delivery number: $last_delivery_number"
    new_package_num=$(($last_delivery_number + $b))
    echo -e "New package number: $new_package_num"
fi

# Package name and directory 1.
mov_package_name=$(echo "ILM_$date"_"$new_package_num") ; echo $mov_package_name
mov_package_path=$(echo "$outgoing_directory/$mov_package_name") ; echo $mov_package_path
mov_description=$(echo "MOVs for final submissions: ILM Tech Check Approved") ; echo $mov_description

# Package name and directory 2.
sum=$(($new_package_num + $b))
exr_package_name=$(echo "ILM_$date"_"$sum") ; echo $exr_package_name
exr_package_path=$(echo "$outgoing_directory/$exr_package_name") ; echo $exr_package_path
exr_description=$(echo "EXRs for final submissions: ILM Tech Check Approved") ; echo $exr_description

# Create CSV variables.
header=$(echo "Title,From,To,Date Delivered,Description,Package Path,Delivery Method,Type")
package_info_1=$(echo "$mov_package_name,$mov_description,$date_day,$mov_package_path")
package_info_2=$(echo "$exr_package_name,$exr_description,$date_day,$exr_package_path")

# Produce CSV file.
echo "$header" > header.csv 
echo "$package_info_1" > csv_file.csv
echo "$package_info_2" >> csv_file.csv
awk 'BEGIN{FS=OFS=","}{print $1,"paradox-lon","Client",$3,$2,$4,"Falcon","Final"}' csv_file.csv > csv_file_2.csv
cat header.csv csv_file_2.csv > new_delivery.csv

/usr/bin/libreoffice new_delivery.csv

clear
echo "done. removing csv."
rm -f new_delivery.csv

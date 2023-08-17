python3 read_envs_into_temp.py

while read row
do
  export $row
done < read_envs_temp

rm -f read_envs_temp
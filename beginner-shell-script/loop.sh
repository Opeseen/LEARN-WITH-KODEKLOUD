# We have a few different applications running on this system. The list of applications is stored in the /home/bob/apps.txt file. Each application 
# has it's logs stored in the /var/log/apps directory under a file with its name. Check it out!


# A simple version of the script has been developed for you named /home/bob/count-requests.sh, which inspects 
# the log file of an application and prints the number of GET, POST, and DELETE requests. Update the script to use a for loop 
# to read the list of applications from the apps.txt file, and count the number of requests for 
# each application, and display it in a tabular format like this.

# Log name         GET         POST          DELETE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  - 

# finance            10           20            50  

# marketing          20           10            30
# -----------------------------------------------------------
#                         SOLUTION
# ---------------------------------------------------------

# echo -e " Log name   \t      GET      \t      POST    \t   DELETE "
# echo -e "------------------------------------------------------------"

for app in $(cat /home/bob/apps.txt)
do
  get_requests=$(cat /var/log/apps/${app}_app.log | grep "GET" | wc -l)
  post_requests=$(cat /var/log/apps/${app}_app.log | grep "POST" | wc -l)
  delete_requests=$(cat /var/log/apps/${app}_app.log | grep "DELETE" | wc -l)
  echo -e " ${app}    \t ${get_requests}    \t    ${post_requests}   \t   ${delete_requests}"

done


# We have some images under the directory /home/bob/images. Develop a script /home/bob/rename-images.sh to rename all files within the images folder that has extension jpeg to jpg. A file with any other extension should remain the same.


# Tip: Use a for loop to iterate over the files within /home/bob/images

# Tip: Use an if conditional to check if the file extension is jpeg.

# Tip: Use mv to rename a file.

# To replace jpeg to jpg in a filename use echo user1.jpeg | sed 's/jpeg/jpg/g'.

for file in $(ls images)
do
  if [[ $file = *.jpeg ]]
    then
    new_name=$(echo $file| sed 's/jpeg/jpg/g')
    mv images/$file images/$new_name
  fi
done
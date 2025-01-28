to_number=$1
number=0
while [ $number -lt $to_number ]
do
  echo $(( number++ ))
done

# Calculator Programme
while true
do
  echo "1. Add"
  echo "2. Subtract"
  echo "3. Multiply"
  echo "4. Divide"
  echo "5. Quit"

  read  -p "Enter your choice: " choice

  if [ $choice -eq 1 ]
  then
    read -p "Enter Number1: " number1
    read -p "Enter Number2: " number2
    echo Answers=$(($number1 + $number2))
  elif [ $choice -eq 2 ]
  then
    read -p "Enter Number1: " number1
    read -p "Enter Number2: " number2
    echo Answers=$(($number1 - $number2))
  elif [ $choice -eq 3 ]
  then
    read -p "Enter Number1: " number1
      read -p "Enter Number2: " number2
      echo Answers=$(($number1 * $number2))
  elif [ $choice -eq 4 ]
  then
    read -p "Enter Number1: " number1
    read -p "Enter Number2: " number2
    echo Answers=$(($number1 / $number2))
  elif [ $choice -eq 5 ]
  then
    break
  else
    echo "Invalid choice"
  fi
done
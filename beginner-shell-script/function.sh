#!/bin/bash
function read_numbers(){
  read -p "Enter Number1: " number1
  read -p "Enter Number2: " number2
}

while true
do
  echo "1. Add"
  echo "2. Subtract"
  echo "3. Multiply"
  echo "4. Divide"
  echo "5. Quit"

  read -p "Enter your choice: " choice

  case $choice in
    1)  read_numbers
        echo $(( $number1 + $number2 )) ;;
    2)
        read_numbers
        echo $(( $number1 - $number2 )) ;;

    3)
        read_numbers
        echo $(( $number1 * $number2 )) ;;

    4)
        read_numbers
        echo $(( $number1 / $number2 )) ;;

    5)  break
  esac

done


# -----------------------------------------------
function launch_rocket(){
  mission_name=$1

  mkdir $mission_name

  rocket-add $mission_name

  rocket-start-power $mission_name
  rocket-internal-power $mission_name
  rocket-start-sequence $mission_name
  rocket-start-engine $mission_name
  rocket-lift-off $mission_name

  rocket_status=$(rocket-status $mission_name)

  echo "The status of launch is $rocket_status"

  if [ $rocket_status = "launching" ]
  then
    sleep 2
    rocket_status=$(rocket-status $mission_name)
  fi

  if [ $rocket_status = "failed" ]
  then
    rocket-debug
    exit 1
  fi
}
launch_rocket $1
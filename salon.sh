#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU_SERVICES(){
  if [[ $1 ]] 
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services")
  #while read SERVICES
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
      do 
        echo "$SERVICE_ID) $SERVICE_NAME"
      done
}

MAIN_MENU_SERVICES

read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nOption is not a number. What would you like today?"
    MAIN_MENU_SERVICES
  else if [[ -z $($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]
    #SERVICE_EXISTANCE=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    #if [[ -z $SERVICE_EXISTANCE ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      MAIN_MENU_SERVICES
   
  else
    # ask for phone number
    echo -e "What's your phone number?"
    read CUSTOMER_PHONE
    # get customer id by phone number
    CUSTOMER_QUERY=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    # if not found ask name
    if [[ -z $CUSTOMER_QUERY ]]
    then
      echo -e "\nI could not find that phone number, What's your name?"
      read CUSTOMER_NAME
      # add new customer with phone and name
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      if [[ $CUSTOMER_INSERT_RESULT == 'INSERT 0 1' ]]
      then
        echo -e "\nCustomer $CUSTOMER_NAME added with phone number $CUSTOMER_PHONE"
        # get customer ID using phone number just added
        CUSTOMER_QUERY=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE';")
      fi
    fi
    CUSTOMER_NAME=$(echo $CUSTOMER_QUERY | sed -r 's/^[\ ]+[\ ]+$//' | sed -r 's/^[a-z0-9]+[| ]+//i')
    CUSTOMER_ID=$(echo $CUSTOMER_QUERY | sed -r 's/^[\ ]+[\ ]+$//' | sed -r 's/[ |]+[a-z0-9]+$//i')
      echo "$CUSTOMER_ID"
    # ask for time
    echo -e "\nWhat time, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # insert into appointments
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi

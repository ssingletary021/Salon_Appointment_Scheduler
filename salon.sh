#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ NuHAIR SALON ~~~~~\n"

echo -e "\nWelcome to NuHAIR SALON, how may I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  # show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  [1-5]) SCHEDULE_MENU ;;
  *) MAIN_MENU "I could not find that service. What service would you like?" ;;
  esac
}

SCHEDULE_MENU() {
  # get customer phone number
  echo -e "\nWhat's your phone number?\n"
  read CUSTOMER_PHONE
# check if is a new customer or not
  GET_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# if new customer

  if [[ -z $GET_CUSTOMER_NAME ]]
  then 
  echo -e "\n I don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  SAVE_TO_TABLE=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE=$(echo $GET_SERVICE_NAME| sed 's/ //g')
  echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?\n"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
  SCHEDULE_SERVICE=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
 
 #if old customer
 else
    
    echo -e "\nWelcome back.\n"
    CUSTOMER_NAME=$(echo $GET_CUSTOMER_NAME | sed 's/ //g')
    GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE=$(echo $GET_SERVICE_NAME| sed 's/ //g')
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?\n"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
    SCHEDULE_SERVICE=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}



MAIN_MENU
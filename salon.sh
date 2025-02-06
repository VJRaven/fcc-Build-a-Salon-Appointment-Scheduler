#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {

  echo -e "\n~~~~~ Salon Appointment ~~~~~\n"
  

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services order by service_id")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

  read SERVICE_ID_SELECTED

  SERVICE_EXIST=$($PSQL "select count(*) from services where service_id = '$SERVICE_ID_SELECTED'")

  if [[ ! $SERVICE_EXIST -eq 1 ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else
    echo -e "\nWhat's your phone number?"

    read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
      
      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      echo -e "\nWhat's your desire service time?"
      read SERVICE_TIME

      # insert service appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      GET_APPOINTMENT_RESULT=$($PSQL "select customers.name, services.name, appointments.time from customers inner join appointments using(customer_id) inner join services using(service_id) where customer_id='$CUSTOMER_ID' and service_id='$SERVICE_ID_SELECTED' and time='$SERVICE_TIME'")
    

      echo "$GET_APPOINTMENT_RESULT" | while read CUSTOMER_NAME BAR SERVICE_NAME BAR APPOINTMENT_TIME
      do
        echo "I have put you down for a $SERVICE_NAME AT $APPOINTMENT_TIME, $CUSTOMER_NAME."
      done
  fi

}

MAIN_MENU

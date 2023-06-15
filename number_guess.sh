#!/bin/bash
PSQL="psql --username=kvothe_snow --dbname=number_guess -t --no-align -c"
#Truncate tables 
#TRUNCATE="$($PSQL "TRUNCATE users, games, player_info")"
#Program that let user guess number between one and a thousand. Then the info games is stored in a database called number_guess 
echo Enter your username:
CHECK_USERNAME_IN_DATABASE() {
	if [[ $1 ]]
	then 
		echo -e "\n$1"
	fi
	read USERNAME
	shopt -s nocasematch
	if [[ "$USERNAME" =~ ^([0-9]|[a-z]){1,11}([0-9]|[a-z]){,11}$ ]]
	then 
    # Check if username is in database 
    USER_ID="$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")"
    if [[ -z $USER_ID ]]
    then 
    # Insert into user table 
    SET_USERNAME="$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")"
    # Select user from table 
    GET_USERNAME="$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")"
    # Then in table, give greetings
    echo -e "\nWelcome, $GET_USERNAME! It look like this is your first time here."
    else 
      #Set username to a variable
      GET_USERNAME="$USERNAME"
      #get games_played 
      GAMES_PLAYED="$($PSQL "SELECT games_played FROM player_info JOIN users USING(user_id) WHERE user_id=$USER_ID")" 
      if [[ -z $GAMES_PLAYED ]]
      then 
        GAMES_PLAYED="0"
      fi
      #get best_game 
      BEST_GAME="$($PSQL "SELECT best_game FROM player_info JOIN users USING(user_id) WHERE user_id=$USER_ID")"
      if [[ -z $BEST_GAME ]]
      then 
        BEST_GAME="0"
      fi  
        echo -e "\nWelcome back, $GET_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses. " 
    fi # Here's the ending of the [[ -z $USER_ID ]] if  LINE(18:43)
else
		CHECK_USERNAME_IN_DATABASE "That's not a valid username. Try again."
fi # Here's the ending of the [[ "$USERNAME" ... ]] if that check the username LINE(15:46) 
	}

GUESS=$(( $RANDOM % 1001 ))
TIMES_GUESSING=0; 
GUESSING_GAME() {
if [[ $1 ]]
then 
  echo -e "$1\n"
fi
echo $GUESS
read X # holding input value 
	if [[ $X == $GUESS ]]
	then
    echo "You guess right"
	else
    TIMES_GUESSING=$(( TIMES_GUESSING + 1 ))
    echo -e "$GUESS=$X"
    echo $TIMES_GUESSING
		GUESSING_GAME "Try Again."
	fi
}
CHECK_USERNAME_IN_DATABASE
GUESSING_GAME

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
    GET_USER_ID=$USER_ID
    if [[ -z $USER_ID ]]
    then 
    # Insert into user table 
    SET_USERNAME="$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")"
    # Select user from table 
    GET_USERNAME="$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")"
    # Then in table, give greetings
    GET_USER_ID="$($PSQL "SELECT user_id FROM users WHERE name='$GET_USERNAME'")"
    echo -e "\nWelcome, $GET_USERNAME! It look like this is your first time here."
    else 
      #Set username to a variable
      GET_USERNAME="$USERNAME"
      #get games_played 
      GAMES_PLAYED="$($PSQL "SELECT MAX(game_number) FROM games WHERE user_id=$USER_ID")" 
      if [[ -z $GAMES_PLAYED ]]
      then 
        GAMES_PLAYED="0"
      fi
      #get best_game 
      BEST_GAME="$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")"
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
read X # holding input value 
  if [[ ! $X =~ ^[0-9]+$ ]]
  then 
    GUESSING_GAME "That is not an integer, guess again:"
  else 
	if [[ $X == $GUESS ]]
	then
    #get user_id
    #Insert values from game into database 
    INSERT_GUESS_TIMES_RESULT="$($PSQL "INSERT INTO games(number_of_guesses, secret_number_of_the_game, date_played, time_played, user_id) VALUES($TIMES_GUESSING, $GUESS, NOW(), NOW(), $GET_USER_ID)")"
    echo -e "\nYou guessed it in $TIMES_GUESSING tries. The secret number was $GUESS. Nice job!"
	else
    TIMES_GUESSING=$(( TIMES_GUESSING + 1 ))
    #echo -e "$GUESS=$X"
    #echo $TIMES_GUESSING
    if [[ $X -gt $GUESS ]]
    then 
		  GUESSING_GAME "It's lower than that, guess again:"
      elif [[ $X -lt $GUESS ]]
      then 
      GUESSING_GAME "It's higher than that, try again:"
    fi
	fi
fi
}
CHECK_USERNAME_IN_DATABASE
echo -e "\nGuess the secret number between 1 and 1000:"
GUESSING_GAME

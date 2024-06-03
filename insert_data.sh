#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE TABLE games, teams")"


insert_teams() {
  tail -n +2 games.csv | cut -d',' -f3,4 | tr ',' '\n' | sort | uniq | while read team
  do
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$team') ON CONFLICT (name) DO NOTHING;")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams: $team"
    fi
  done
}

insert_games() {

  tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals
  do

    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $winner vs $opponent in $year $round"
    fi
  done
}

insert_teams
insert_games
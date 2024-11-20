#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
    # Skip the header row in the CSV file
    if [[ "$year" != "year" ]]; then
        # Insert winner and opponent teams into the teams table, avoiding duplicates
        # Insert the winner team if it doesn't already exist
        $PSQL "INSERT INTO teams (name) VALUES ('$winner') ON CONFLICT (name) DO NOTHING;"
        # Insert the opponent team if it doesn't already exist
        $PSQL "INSERT INTO teams (name) VALUES ('$opponent') ON CONFLICT (name) DO NOTHING;"

        # Retrieve the team_id for winner and opponent
        winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
        opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")

        # Insert the game data into the games table with references to the winner and opponent teams
        $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                 VALUES ('$year', '$round', $winner_id, $opponent_id, '$winner_goals', '$opponent_goals');"
    fi
done < games.csv  # Specify the CSV file to read

# Step 4: Final confirmation message
echo "Data insertion complete!"
#!/bin/bash
DB_NAME="periodic_table"
DB_USER="postgres"

# Check if argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Query the database
RESULT=$(psql -U $DB_USER -d $DB_NAME -t --no-align -c "
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE e.atomic_number::TEXT = '$1' OR e.symbol = '$1' OR e.name = '$1';
")

# Check if an element was found
if [[ -z "$RESULT" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the result
IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

# Display the output in the required format
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."

exit 0

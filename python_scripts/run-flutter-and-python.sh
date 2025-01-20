#!/bin/bash

# Run the Python scripts in the background
echo "Starting Python script getSchorlaships2.py..."
python3 getSchorlaships2.py &

echo "Starting Python script getScholarship.py..."
python3 getScholarship.py &


echo "Starting Python script getBursaries.py..."
python3 getBursaries.py &


echo "Starting Python script getBursaries2.py..."
python3 getBursaries2.py &


echo "Starting Python script importBursaries.py..."
python3 importBursaries.py &

# Get the process IDs of the background Python commands
SCHOLARSHIPS2_PID=$!
SCHOLARSHIP_PID=$!
getBursaries_PID=$!
getBursaries2_PID=$!
IMPORTBURSARIES_PID=$!

# Wait for both processes to complete
wait $SCHOLARSHIPS2_PID
wait $SCHOLARSHIP_PID
wait $getBursaries2_PID
wait $getBursaries2_PID
wait $IMPORTBURSARIES_PID


echo "all 5 Python scripts have finished."

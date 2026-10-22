#!/bin/bash

# Create /tmp/tutors.txt containing tutor usernames
while IFS=, read -r username account_type || [[ -n "$username" ]]; do
    if [[ "$account_type" == "tutor" ]]; then
        echo "$username"
    fi 
done < Accounts.txt > /tmp/tutors.txt
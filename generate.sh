#!/usr/bin/env bash

# Function to load the .env file
load_env() {
    export $(grep -v '^#' ./filemaker-installs/auto/.env | xargs)
}

# Function to convert a relative path to an absolute path
convert_to_absolute_path() {
    local path="$1"
    echo "$(cd "$(dirname "$path")"; pwd)/$(basename "$path")"
}

# Function to generate the certificate hook script
generate_certificate_hook() {
    local template="./templates/renewalhook-certificates.sh"
    local output="./generated/renewalhook-certificates.sh"

    # Ensure the output directory exists
    mkdir -p ./generated

    # Load environment variables from .env file
    load_env

    # Determine the default certificate path
    local DEFAULT_CERT_PATH=""
    if [ -n "$FM_APP_DOMAIN" ]; then
        DEFAULT_CERT_PATH="/etc/letsencrypt/live/$FM_APP_DOMAIN"
    fi

    # Use DEFAULT_PATH if defined, otherwise use the determined default or prompt the user
    if [ -z "$DEFAULT_PATH" ]; then
        read -p "Enter the absolute path for the system certificates (default: $DEFAULT_CERT_PATH): " CERT_SYSTEM
        CERT_SYSTEM=${CERT_SYSTEM:-$DEFAULT_CERT_PATH}
    else
        CERT_SYSTEM="$DEFAULT_PATH"
    fi

    # Get the CERT_DOCKER path from the environment variable and convert to absolute path
    local CERT_DOCKER=$(convert_to_absolute_path "$FM_CERTIFICATE_PATH")

    # Determine email settings
    local enable_email="$EMAIL_ON"
    if [ -z "$enable_email" ]; then
        read -p "Would you like to receive email notifications? (yes/no): " enable_email
    fi

    local ENABLE_EMAIL=false
    local TO="$EMAIL_TO"
    local FROM="$EMAIL_FROM"

    if [[ "$enable_email" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
        ENABLE_EMAIL=true
        echo "Please make sure that mail is set up on the host machine for this functionality to work."
        if [ -z "$FROM" ]; then
            read -p "Enter the 'from' email address: " FROM
        fi
        if [ -z "$TO" ]; then
            read -p "Enter the 'to' email address: " TO
        fi
    fi

    # Fill in the template with the provided information
    sed -e "s|CERT_SYSTEM=|CERT_SYSTEM=${CERT_SYSTEM}|g" \
        -e "s|CERT_DOCKER=|CERT_DOCKER=${CERT_DOCKER}|g" \
        -e "s|ENABLE_EMAIL=|ENABLE_EMAIL=${ENABLE_EMAIL}|g" \
        -e "s|TO=|TO=${TO}|g" \
        -e "s|FROM=|FROM=${FROM}|g" \
        "$template" > "$output"

    echo "The certificate hook script has been generated at $output"
}

# Main function
main() {
    local type=""

    # Parse the command line arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -t|--type)
                type="$2"
                shift
                ;;
            *)
                echo "Unknown parameter passed: $1"
                exit 1
                ;;
        esac
        shift
    done

    # Check the type and call the corresponding function
    case "$type" in
        certificate-hook)
            generate_certificate_hook
            ;;
        *)
            echo "Invalid type specified. Supported types: certificate-hook"
            exit 1
            ;;
    esac
}

# Execute the main function
main "$@"

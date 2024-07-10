#!/bin/bash
source ./filemaker-installs/auto/.env
source ./filemaker-installs/current/version.sh

# Variables for storing current state of FMS
version_installed=false
image_built=false
container_running=false
container_exists=false
total_databases_open=0
total_databases_closed=0
total_databases_verifying=0

# Function to display the menu
show_menu() {
    local show_disabled=$1

    # Calc current state before drawing menu   
    calc_state

    echo "=========================="
    echo " FileMaker Server Manager"
    echo "=========================="
    echo ""

    local index=1
    echo "FileMaker Server Installation Section"
    printf "\t%02d. Download FileMaker Server installation media\n" $index

    index=$((index + 1))
    if $container_running || $container_exists; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Set FileMaker Server version (disabled)\n" $index
        fi
    else
        printf "\t%02d. Set FileMaker Server version\n" $index
    fi
    echo ""

    echo "Docker Container Section"
    index=$((index + 1))
    if $container_exists; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Build Docker image (disabled)\n" $index
        fi
    else
        printf "\t%02d. Build Docker image\n" $index
    fi

    index=$((index + 1))
    if $container_exists && ! $container_running; then
        printf "\t%02d. Remove Docker container\n" $index
    else
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Remove Docker container (disabled)\n" $index
        fi
    fi

    index=$((index + 1))
    if ! $container_exists || $container_running; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Start Docker container (disabled)\n" $index
        fi
    else
        printf "\t%02d. Start Docker container\n" $index
    fi

    index=$((index + 1))
    if [ $total_databases_open -gt 0 ] || ! $container_exists || ! $container_running; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Stop Docker container (disabled)\n" $index
        fi
    else
        printf "\t%02d. Stop Docker container\n" $index
    fi

    index=$((index + 1))
    if ! $container_running; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. SSH into Docker container (disabled)\n" $index
        fi
    else
        printf "\t%02d. SSH into Docker container\n" $index
    fi
    echo ""

    echo "FileMaker Server Section"
    index=$((index + 1))
    if ! $container_running || [ $total_databases_closed -eq 0 ]; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Start all FileMaker databases (disabled)\n" $index
        fi
    else
        printf "\t%02d. Start all FileMaker databases\n" $index
    fi

    index=$((index + 1))
    if ! $container_running || [ $total_databases_open -eq 0 ]; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Stop all FileMaker databases (disabled)\n" $index
        fi
    else
        printf "\t%02d. Stop all FileMaker databases\n" $index
    fi

    index=$((index + 1))
    if ! $container_running; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Verify FileMaker databases (disabled)\n" $index
        fi
    else
        printf "\t%02d. Verify FileMaker databases\n" $index
    fi

    index=$((index + 1))
    if ! $container_running; then
        if [ "$show_disabled" = true ]; then
            printf "\t%02d. Import SSL certificates (disabled)\n" $index
        fi
    else
        printf "\t%02d. Import SSL certificates\n" $index
    fi
    echo ""

    echo "Type 'Exit' or use 'ctrl+c' to exit\n"
    echo "========================="
}

# Function to calculate variables
calc_state(){
    
    # Check if the version is installed
    if [ -n "$VERSION" ]; then
        version_installed=true
    else
        version_installed=false
    fi

    # Check if the Docker image is built
    if [ -n "$(docker images -q fmsdocker:ubuntu22.04-fms$VERSION)" ]; then
        image_built=true
    else
        image_built=false
    fi

    # Check if the Docker container is running
    if [ -n "$(docker ps -q -f name=$NAME$VERSION)" ]; then
        container_running=true
    else
        container_running=false
    fi

    # Check if the Docker container exists
    if [ -n "$(docker ps -a -q -f name=$NAME$VERSION)" ]; then
        container_exists=true
    else
        container_exists=false
    fi

    # Check if there are open or closed databases
    if $container_running; then
        total_databases_open=$(docker exec $NAME$VERSION fmsadmin LIST FILES -u $FM_USERNAME -p $FM_PASSWORD -s | grep -c "Normal")
        total_databases_closed=$(docker exec $NAME$VERSION fmsadmin LIST FILES -u $FM_USERNAME -p $FM_PASSWORD -s | grep -c "Closed")
        total_databases_verifying=$(docker exec $NAME$VERSION fmsadmin LIST FILES -u $FM_USERNAME -p $FM_PASSWORD -s | grep -c "Verifying")
    else
        total_databases_open=0
        total_databases_closed=0
        total_databases_verifying=0
    fi

}

# Function to check for risky tasks
safety_barrier() {
    echo "Warning: You are about to perform a risky operation."
    echo "Please type 'I understand' to proceed."
    read -p "Confirmation: " confirmation
    if [[ "$confirmation" != "I understand" && "$confirmation" != "i understand" ]]; then
        echo "Operation cancelled."
        return 1
    fi
    return 0
}

# Function to check for SSL certificate files
check_certificate_files() {
    local cert_path="$FM_CERTIFICATE_PATH/"
    local cert_files=("cert.pem" "privkey.pem" "fullchain.pem")

    for file in "${cert_files[@]}"; do
        if [ ! -f "${cert_path}${file}" ]; then
            echo "Error: ${cert_path}${file} not found."
            return 1
        fi
    done
    return 0
}

# Function to build the Docker image
build_image() {
    docker image build -t fmsdocker:ubuntu22.04-fms$VERSION ./ --build-arg VERSION=$VERSION
    run_container
}

# Function to run the Docker container
run_container() {
    bash scripts/run.sh
}

# Function to stop the Docker container
stop_container() {
    docker stop $NAME$VERSION
}

# Function to start the Docker container
start_container() {
    docker start $NAME$VERSION
    sleep 5 # wait for fms to become active and open databases
}

# Function to remove the Docker container
remove_container() {
    docker rm $NAME$VERSION
}

# Function to SSH into the Docker container
ssh_container() {
    docker exec -it $NAME$VERSION /bin/bash
}

# Function to download FileMaker Server installation media
download_fmsim() {
    bash scripts/downloadFMSIM.sh
}

# Function to set the FileMaker Server version
set_version() {
    bash scripts/switchFMSIM.sh
}

# Function to start all FileMaker databases
start_databases() {
    docker exec $NAME$VERSION fmsadmin OPEN -u $FM_USERNAME -p $FM_PASSWORD -y
}

# Function to stop all FileMaker databases
stop_databases() {
    docker exec $NAME$VERSION fmsadmin CLOSE -u $FM_USERNAME -p $FM_PASSWORD -y
}

# Function to verify FileMaker databases
verify_databases() {
    docker exec $NAME$VERSION fmsadmin VERIFY -u $FM_USERNAME -p $FM_PASSWORD -y
}

# Function to import SSL certificates
import_ssl_certificates() {
    if check_certificate_files; then
        docker exec $NAME$VERSION fmsadmin certificate import /install/certificates/cert.pem --keyfile /install/certificates/privkey.pem --intermediateCA /install/certificates/fullchain.pem -u $FM_USERNAME -p $FM_PASSWORD -y
    else
        echo "Import SSL certificates operation aborted."
    fi
}

# Function to print the error
print_error_disabled(){
    text="$1 is disabled."
    if [ "$2" ]; then
        text="$text $2"
    fi
    echo $text
}

# Main loop
show_disabled=false
if [[ "$1" == "--disabled" || "$1" == "-d" ]]; then
    show_disabled=true
fi

while true; do
    show_menu $show_disabled
    read -p "Enter your choice: " choice

    # Recheck current state - maybe the user waited long time before selecting an option!
    calc_state
    case $choice in
        1)
            download_fmsim
            ;;
        2)
            if ! $container_running && ! $container_exists; then
                safety_barrier && set_version
            else
                print_error_disabled "Set FileMaker Server version"
            fi
            ;;
        3)
            if ! $container_exists; then
                build_image
            else
                print_error_disabled "Build Docker image"
            fi
            ;;
        4)
            if $container_exists && ! $container_running; then
                safety_barrier && remove_container
            else
                print_error_disabled "Remove Docker container" "The container is either running or does not exist."
            fi
            ;;
        5)
            if $container_exists && ! $container_running; then
                start_container
            else
                print_error_disabled "Start Docker container" "The container does not exist or is already running."
            fi
            ;;
        6)
            if $container_exists && [ $total_databases_open -eq 0 ] && $container_running; then
                safety_barrier && stop_container
            else
                print_error_disabled "Stop Docker container" "Databases are still open or container does not exist."
            fi
            ;;
        
        7)
            if $container_running; then
                ssh_container
            else
                print_error_disabled "SSH into Docker container" "The container is not running."
            fi
            ;;

        8)
            if $container_running && [ $total_databases_closed -gt 0 ]; then
                start_databases
            else
                print_error_disabled "Start all FileMaker databases" "The container is not running or there are no closed databases."
            fi
            ;;
        9)
            if $container_running && [ $total_databases_open -gt 0 ]; then
                safety_barrier && stop_databases
            else
                print_error_disabled "Stop all FileMaker databases" "The container is not running or there are no open databases."
            fi
            ;;
       
        10)
            if $container_running; then
                safety_barrier && verify_databases
            else
                print_error_disabled "Verify FileMaker databases" "The container is not running or databases are open."
            fi
            ;;
        11)
            if $container_running; then
                import_ssl_certificates
            else
                print_error_disabled "Import SSL certificates" "The container is not running."
            fi
            ;;
        Exit|exit)
            echo "Thank you! Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
    echo ""
    echo ""
    echo ""
done

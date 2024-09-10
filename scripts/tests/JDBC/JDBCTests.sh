#!/bin/bash
source ../../../filemaker-installs/auto/.env
source ../../../filemaker-installs/current/version.sh

# Check if .env is loaded correctly
if [ -z "$NAME" ]; then
   echo "Could not load needed data... Do you have a .env file? Are you missing key-values?"
   exit 1
fi

# Test if the Java service is listening on port 4444
test_java_internal() {
    echo "Checking if Java service is listening on port 4444..."
    if docker exec -it $NAME$VERSION /bin/bash -c "netstat -an | grep ':4444 ' | grep 'LISTEN'"; then
        echo "Java service is running and listening on port 4444!"
    else
        echo "Java service is not running or not listening on port 4444!"
        exit 1
    fi
}

# Test if the PHP can connect to the JAVA
test_php_internal() {
    echo "Testing PHP connection to Java process..."
    if docker exec -it $NAME$VERSION php /opt/FileMaker/JDBC/php/test.php "$JDBC_USERNAME" "$JDBC_PASSWORD" "$JDBC_DATABASE" "SELECT * from contact"; then
        echo "PHP successfully connected to Java process and returned query results!"
    else
        echo "PHP connection to Java process failed!"
        exit 1
    fi
}

# Execute the tests
test_java_internal
test_php_internal

echo "All tests passed successfully!"
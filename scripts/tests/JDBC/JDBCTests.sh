#!/bin/bash
source ./filemaker-installs/auto/.env
source ./filemaker-installs/current/version.sh

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
        echo "Java service is not running or not listening on port 4444! Fase 1 error!"
        exit 1
    fi
}

# Test if PHP can connect to JAVA and receive data
test_php_internal() {
    echo "Testing PHP connection to Java process..."
    if docker exec -it $NAME$VERSION php /opt/FileMaker/JDBC/php/test.php "$JDBC_USERNAME" "$JDBC_PASSWORD" "$JDBC_DATABASE" "$JDBC_TEST_QUERY"; then
        echo "PHP successfully connected to Java process and returned query results!"
    else
        echo "PHP connection to Java process failed! Fase 2/3 error."
        exit 1
    fi
}

# Test if apache is listening on port 10073
test_apache_internal() {
    echo "Checking if Apache is listening on port 10073..."
    if docker exec -it $NAME$VERSION /bin/bash -c "netstat -an | grep ':10073 ' | grep 'LISTEN'"; then
        echo "Apache is running and listening on port 10073!"
    else
        echo "Apache is not running or not listening on port 10073! Fase 4 error!"
        exit 1
    fi
}

# Test if CURL inside the docker container is working
test_curl_request_internal() {
    echo "Testing CURL request inside Docker container..."

    # Capture HTTP status and the full JSON response
    full_response=$(docker exec -it $NAME$VERSION curl -s -X POST -H "Content-Type: application/json" -d "{\"sql\": \"$JDBC_TEST_QUERY\"}" http://localhost:10073/api/make-request)
    response_status=$(docker exec -it $NAME$VERSION curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"sql\": \"$JDBC_TEST_QUERY\"}" http://localhost:10073/api/make-request)
    error_key=$(echo "$full_response" | jq -e '.error' >/dev/null 2>&1; echo $?)

    # Print the response and status
    echo "Response status: $response_status"
    echo "Full response: $full_response"

    # Check if HTTP status is 200 and no error key exists
    if [[ "$response_status" == "200" && "$error_key" != "0" ]]; then
        echo "CURL request inside Docker succeeded and returned data!"
    else
        echo "CURL request inside Docker failed! Fase 6 error!"
        exit 1
    fi
}

# Test if CURL works outside the docker container (on host machine)
test_curl_request_external() {
    echo "Testing CURL request from host machine..."

    # Capture HTTP status and the full JSON response
    full_response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"sql\": \"$JDBC_TEST_QUERY\"}" http://localhost:10073/api/make-request)
    response_status=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"sql\": \"$JDBC_TEST_QUERY\"}" http://localhost:10073/api/make-request)
    error_key=$(echo "$full_response" | jq -e '.error' >/dev/null 2>&1; echo $?)

    # Print the response and status
    echo "Response status: $response_status"
    echo "Full response: $full_response"

    # Check if HTTP status is 200 and no error key exists
    if [[ "$response_status" == "200" && "$error_key" != "0" ]]; then
        echo "CURL request from host machine succeeded and returned data!"
    else
        echo "CURL request from host machine failed! Fase 7 error!"
        exit 1
    fi
}

echo "Tying to see if JDBC is working and ready to be used!"
printf "\n\n"

# Execute the tests
echo "Testing Java..."
test_java_internal
echo "Java OK"
printf "\n\n"
echo "Testing Java connection to DB"
test_php_internal
echo "Java connection to DB OK"
printf "\n\n"
echo "Testing Apache2"
test_apache_internal
echo "Apache 2 OK"
printf "\n\n"
echo "Testing internal POST request"
test_curl_request_internal
echo "Internal POST request OK"
printf "\n\n"
echo "Testing external POST request"
test_curl_request_external
echo "External POST request OK"
printf "\n\n"

echo "All tests passed successfully!"
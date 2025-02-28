# Sales Journal Aggregator API

This README documents the steps necessary to get the Sales Journal Aggregator API up and running.

## Table of Contents

- [Ruby Version](#ruby-version)
- [System Dependencies](#system-dependencies)
- [Configuration](#configuration)
- [Database Creation](#database-creation)
- [Database Initialization](#database-initialization)
- [Run the Application](#run-the-application)
- [How to Run the Test Suite](#how-to-run-the-test-suite)
- [Services](#services)
- [Deployment Instructions](#deployment-instructions)
- [Implementation Decisions](#implementation-decisions)

## Ruby Version

- Ruby 3.3.4

## System Dependencies

- Rails 7.2.2.1
- SQLite (for development and testing)
- PostgreSQL (recommended for production)
- Devise Token Auth (for authentication)
- React (for frontend)

## Configuration

1. Clone the repository:
    ```sh
    git clone https://github.com/delian7/sales_journal_aggregator_api.git
    cd sales_journal_aggregator_api
    ```

2. Install dependencies:
    ```sh
    bundle install
    ```

## Database Creation

1. Create the database:
    ```sh
    rails db:create
    ```

## Database Initialization

1. Run database migrations:
    ```sh
    rails db:migrate
    ```

2. Seed the database:
    ```sh
    rails db:seed
    ```

   This will create the test user
   ```
    # Test User (use this in the React Login Page)
    email: test@example.com
    password: password
   ```

## Run the application

1. Run the server:
    ```sh
    rails s
    ```

2. Follow the readme on the [Sales Journal Frontend](https://github.com/delian7/sales-journal) and then
    ```sh
      npm run dev
    ```

## How to Run the Test Suite

1. Run the test suite:
    ```sh
    bundle exec rspec
    ```

2. To run the test suite with caching enabled:
    ```sh
    ENABLE_CACHING=true bundle exec rspec
    ```

## Implementation Decisions

- **Schema Design**: Designed a schema to store the data from the CSV file.
- **Data Import**: Imported data from the CSV file into the database using the following rake task:
    ```sh
    rake import:payments_and_orders FILE_PATH=/path/to/file
    ```
- **Backend API Endpoint**: Initialized the backend API endpoint at `/api/v1/journal_entries`.
- **Authentication**: Implemented authentication using Devise Token Auth.
- **Database Seeds**: Set up database seeds to pull data and create users for authentication.
  ```
    # Test User (use this in the React Login Page)
    email: test@example.com
    password: password
  ```
- **Frontend**: Developed a React frontend for the application.
- **Month Selection**: Set up a view for choosing a month instead of displaying all months.

### Explanation of Decisions

- **Database Choice**: Chose SQLite for development and testing due to its ease of configuration. For production, PostgreSQL is recommended.
- **Data Aggregation**: Chose to generate the order data journal entry and cache it for 1 hour rather than creating a JournalEntry record. This ensures that new orders are always included in the latest data for the month. The TTL for the cache can be adjusted based on business requirements. In production, Redis caching is recommended.
- **Route Design**: Broke RESTful conventions by using the route `/api/v1/journal_entries/:year/:month` for the show action. This is justified since journal entries are not stored as records.
- **Testing Cache**: Added a test to verify caching behavior. By default, caching is disabled in the test environment. To enable caching for the test suite, use the following command:
    ```sh
    ENABLE_CACHING=true bundle exec rspec
    ```
- **Frontend Authentication**: Used local storage to store the `client_id`, `access_token`, and `uid` needed for authentication. In a production system, Next.js or a similar framework should be used to avoid exposing these tokens to the client for better security.

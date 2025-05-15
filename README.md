# files_and_databases

## Overview

This repository contains multiple SQL files for creating and managing database tables. The purpose of this repository is to provide a set of SQL scripts that can be used to set up and manage a database for a shop.

## Structure

The repository is structured as follows:

- `commands.sql`: Contains various SQL queries for selecting and describing tables.
- `creation.sql`: Contains SQL commands for creating and dropping tables.
- `settings.sql`: Contains useful settings for the SQL session.
- `tables/`: Directory containing multiple SQL files for creating and populating specific tables.
- `update.sql`: Contains SQL commands for updating various tables in the database.

## Setup and Usage

To set up and use the database, follow these steps:

1. Clone the repository to your local machine.
2. Open your SQL client and connect to your database.
3. Run the `settings.sql` script to set up the session settings.
4. Run the `creation.sql` script to create the necessary tables.
5. Run the SQL scripts in the `tables/` directory to populate the tables with data.
6. Run the `commands.sql` script to execute various queries on the tables.
7. Run the `update.sql` script to update the tables as needed.

## SQL Files

- `commands.sql`: Contains various SQL queries for selecting and describing tables.
- `creation.sql`: Contains SQL commands for creating and dropping tables.
- `settings.sql`: Contains useful settings for the SQL session.
- `tables/1_catalogue.sql`: Contains SQL commands for creating and populating the `catalogue` table.
- `tables/2_products.sql`: Contains SQL commands for creating and populating the `products` table.
- `tables/3_marketing_format.sql`: Contains SQL commands for creating and populating the `marketing_format` table.
- `tables/4_reference.sql`: Contains SQL commands for creating and populating the `p_reference` table.
- `tables/5_replacement_order.sql`: Contains SQL commands for creating and populating the `replacement_order` table.
- `tables/6_supplier.sql`: Contains SQL commands for creating and populating the `supplier` table.
- `tables/7_customer.sql`: Contains SQL commands for creating and populating the `customers` table.
- `tables/8_purchase_order.sql`: Contains SQL commands for creating and populating the `purchase_order` table.
- `tables/11_registered.sql`: Contains SQL commands for creating and populating the `registered` table.
- `tables/15_comments.sql`: Contains SQL commands for creating and populating the `customer_comments` table.
- `update.sql`: Contains SQL commands for updating various tables in the database.

## Additional Information

- The `commands.sql` file contains various SQL queries for selecting and describing tables.
- The `creation.sql` file contains SQL commands for creating and dropping tables.
- The `settings.sql` file contains useful settings for the SQL session.
- The `tables` directory contains multiple SQL files for creating and populating specific tables.
- The `update.sql` file contains SQL commands for updating various tables in the database.

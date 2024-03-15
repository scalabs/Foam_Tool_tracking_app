from flask import Flask, jsonify
from flask_cors import CORS
import pyodbc

app = Flask(__name__)
CORS(app)

# Replace these variables with your database credentials
DB_HOST = '127.0.0.1'
DB_USER = 'faruk'
DB_PASSWORD = 'Fa87362/..aa!fF'
DB_NAME = 'faruk'

# Define the connection string
connection_string = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={DB_HOST};DATABASE={DB_NAME};UID={DB_USER};PWD={DB_PASSWORD}"

def get_db_connection():
    try:
        connection = pyodbc.connect(connection_string)
        cursor = connection.cursor()
        return connection, cursor
    except pyodbc.Error as e:
        print(f"Error connecting to the database: {e}")
        # Handle the error accordingly, e.g., exit the application

@app.route('/api/os', methods=['GET'])
def get_operating_systems():
    try:
        connection, cursor = get_db_connection()

        # Fetch data from the database
        sql = "SELECT os_name FROM MicrosoftOperatingSystems"
        cursor.execute(sql)

        # Fetch all the rows
        rows = cursor.fetchall()

        # Convert the result to a list of dictionaries
        os_list = [{'os_name': row[0]} for row in rows]

        return jsonify(os_list)

    except pyodbc.Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


@app.route('/api/active', methods=['GET'])
def get_active_tools():
    try:
        connection, cursor = get_db_connection()

        # Fetch data from the database
        sql = "SELECT Alat FROM Active"
        cursor.execute(sql)

        # Fetch all the rows
        rows = cursor.fetchall()

        # Convert the result to a list of dictionaries
        active_list = [{'Alat': row[0]} for row in rows]

        return jsonify(active_list)

    except pyodbc.Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


@app.route('/api/rezerva', methods=['GET'])
def get_rezerva_data():
    try:
        connection, cursor = get_db_connection()

        # Fetch data from the database for the 'rezerva' route
        sql = """
            SELECT
                Alat AS 'Tool',
                Lokacija AS 'Location',
                Pozicija AS 'Position',
                RB AS 'Row'
            FROM Rezerva
        """
        cursor.execute(sql)

        # Fetch all the rows
        rows = cursor.fetchall()

        # Convert the result to a list of dictionaries
        rezerva_list = [
            {
                'Tool': row[0],
                'Location': row[1],
                'Position': row[2],
                'Row': row[3]
            }
            for row in rows
        ]

        return jsonify(rezerva_list)

    except pyodbc.Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


@app.route('/api/karijeri', methods=['GET'])
def get_karijeri_data():
    try:
        connection, cursor = get_db_connection()

        # Fetch data from the database for the 'karijeri' route
        sql = """
            SELECT
                IB AS 'IB',
                Pozicija AS 'Position',
                Proizvodjac AS 'Manufacturer',
                RB AS 'Row',
                Serijski_broj AS 'Serijski_broj'
            FROM Karijeri
        """
        cursor.execute(sql)

        # Fetch all the rows
        rows = cursor.fetchall()

        # Convert the result to a list of dictionaries
        karijeri_list = [
            {
                'IB': row[0],
                'Position': row[1],
                'Manufacturer': row[2],
                'Row': row[3],
                'Serijski_broj': row[4]
            }
            for row in rows
        ]

        return jsonify(karijeri_list)

    except pyodbc.Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

@app.route('/api/trenutno_stanje', methods=['GET'])
def get_trenutno_stanje_data():
    try:
        connection, cursor = get_db_connection()

        # Fetch data from the database for the 'trenutno_stanje' route
        sql = """
            SELECT
                Alat AS 'Alat',
                Kerijer AS 'Kerijer',
                Pozicija AS 'Pozicija',
                RB AS 'RB'
            FROM Trenutno_stanje
        """
        cursor.execute(sql)

        # Fetch all the rows
        rows = cursor.fetchall()

        # Convert the result to a list of dictionaries
        trenutno_stanje_list = [
            {
                'Alat': row[0],
                'Kerijer': row[1],
                'Pozicija': row[2],
                'RB': row[3]
            }
            for row in rows
        ]

        return jsonify(trenutno_stanje_list)

    except pyodbc.Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()



@app.route('/api/oficijalno', methods=['GET'])
def get_oficijalno_data():
    try:
        connection, cursor = get_db_connection()

        # Fetch data from the database for the 'oficijalno' route
        sql = """
            SELECT
                Broj_proizvoda AS 'Broj_proizvoda',
                Interni_broj AS 'Interni_broj',
                Kavitet AS 'Kavitet',
                Kupac AS 'Kupac',
                Projekat AS 'Projekat',
                Vrsta_alata AS 'Vrsta_alata'
            FROM Oficijalno
        """
        cursor.execute(sql)

        # Fetch all the rows
        rows = cursor.fetchall()

        # Convert the result to a list of dictionaries
        oficijalno_list = [
            {
                'Broj_proizvoda': row[0],
                'Interni_broj': row[1],
                'Kavitet': row[2],
                'Kupac': row[3],
                'Projekat': row[4],
                'Vrsta_alata': row[5]
            }
            for row in rows
        ]

        return jsonify(oficijalno_list)

    except pyodbc.Error as e:
        print(f"Database error: {e}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

if __name__ == '__main__':
    app.run(debug=True)



# # Replace these variables with your database credentials
# DB_HOST = '127.0.0.1'
# DB_USER = 'faruk'
# DB_PASSWORD = 'Fa87362/..aa!fF'
# DB_NAME = 'faruk'


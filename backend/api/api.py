from flask import Flask, jsonify, request
from flask_cors import CORS  # Import CORS from flask_cors
import pyodbc

# app = Flask(__name__)
# #za live CORS(app, resources={r"/api/*": {"origins": "http://10.3.41.24"}})
# CORS(app, resources={r"/api/*": {"origins": "127.0.0.1"}})
# #CORS(app)


# # Replace these with your actual SQL Server credentials
# server = "127.0.0.1"
# port = 3306
# database = "Foam_tools"
# username = "bde"
# password = "!bde1234"
# driver = "ODBC Driver 17 for SQL Server"

# conn_str = (
#     f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}"
# )
# conn = pyodbc.connect(conn_str)
# cursor = conn.cursor()

app = Flask(__name__)
#CORS(app) 
CORS(app, resources={r"/api/*": {"origins": "*"}})
# Replace these with your actual SQL Server credentials
server = "NB-JI-0316\\SQLEXPRESS"
port = 3306
database = 'Foam_tools'
username = 'bde'
password = '!bde1234'
driver = 'ODBC Driver 18 for SQL Server'

conn_str = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};Encrypt=no'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

@app.route(
    "/api/active",
    methods=["GET", "POST", "DELETE"],
)
def handle_active():
    if request.method == "GET":
        cursor.execute(
            "SELECT TOP (1000)  [Alat] FROM [Foam_tools].[dbo].[Active]"
        )
        active_data = [
            dict(zip([column[0] for column in cursor.description], row))
            for row in cursor.fetchall()
        ]
        return jsonify(active_data)

    elif request.method == "POST":
        data = request.get_json()
        tool_name = data.get('tool')  # Assuming the key for tool name is 'tool'

        # Insert new tool into the Active table
        insert_query = """
            INSERT INTO [Foam_tools].[dbo].[Active] ([Alat])
            VALUES (?)
        """
        try:
            cursor.execute(insert_query, (tool_name,))
            conn.commit()
            print(f"Tool '{tool_name}' added to the database.")
            return jsonify({"message": "Tool added successfully"})
        except Exception as e:
            conn.rollback()
            print(f"Error adding tool '{tool_name}': {str(e)}")
            return jsonify({"error": str(e)}), 500

    elif request.method == "DELETE":
        data = request.get_json()
        tool_name = data.get('tool')  # Assuming the key for tool name is 'tool'

        # Delete tool from the Active table
        delete_query = """
            DELETE FROM [Foam_tools].[dbo].[Active]
            WHERE [Alat] = ?
        """
        try:
            cursor.execute(delete_query, (tool_name,))
            conn.commit()
            return jsonify({"message": "Tool deleted successfully"})
        except Exception as e:
            conn.rollback()
            return jsonify({"error": str(e)}), 500


# Route for /api/karijeri
@app.route("/api/karijers", methods=["GET"])
def handle_carriers():
    if request.method == "GET":
        cursor.execute(
            "SELECT TOP (1000)  [Serijski_broj] FROM [Foam_tools].[dbo].[Karijers]"
        )
        karijeri_data = [
            dict(zip([column[0] for column in cursor.description], row))
            for row in cursor.fetchall()
        ]
        return jsonify(karijeri_data)



@app.route('/api/users', methods=['GET', 'POST', 'DELETE'])
def handle_users():
    cursor = conn.cursor()

    if request.method == 'GET':
        cursor.execute('SELECT id, username, email, permissions FROM dbo.Users')
        rows = cursor.fetchall()

        users = []
        for row in rows:
            user = {
                'id': row[0],
                'username': row[1],
                'email': row[2],
                'permissions': row[3]
            }
            users.append(user)

        return jsonify(users)

    elif request.method == 'POST':
        # Example of handling POST request to add a new user
        data = request.json
        username = data.get('username')
        email = data.get('email')
        permissions = data.get('permissions')

        if username and email and permissions:
            cursor.execute('INSERT INTO dbo.Users (username, email, permissions) VALUES (?, ?, ?)',
                           (username, email, permissions))
            conn.commit()
            return jsonify({'message': 'User added successfully'}), 201
        else:
            return jsonify({'error': 'Missing data. Required fields: username, email, permissions'}), 400

    elif request.method == 'DELETE':
        # Example of handling DELETE request to delete a user
        user_id = request.args.get('id')

        if user_id:
            cursor.execute('DELETE FROM dbo.Users WHERE id = ?', (user_id,))
            conn.commit()
            return jsonify({'message': f'User with id {user_id} deleted successfully'}), 200
        else:
            return jsonify({'error': 'Missing user id parameter'}), 400


# Route for /api/oficijalno
@app.route("/api/oficijalno", methods=["GET"])
def handle_oficijalno():
    if request.method == "GET":
        cursor.execute(
            "SELECT TOP (1000) [Interni_broj], [Kupac], [Projekat], [Vrsta_alata], [Broj_proizvoda], [Kavitet] FROM [Foam_tools].[dbo].[Oficijalno]"
        )
        oficijalno_data = [
            dict(zip([column[0] for column in cursor.description], row))
            for row in cursor.fetchall()
        ]
        return jsonify(oficijalno_data)


# Route for /api/rezerva
@app.route("/api/rezerva", methods=["GET"])
def handle_rezerva():
    if request.method == "GET":
        cursor.execute(
            "SELECT TOP (1000) [RB], [Pozicija], [Alat], [Lokacija] FROM [Foam_tools].[dbo].[Rezerva]"
        )
        rezerva_data = [
            dict(zip([column[0] for column in cursor.description], row))
            for row in cursor.fetchall()
        ]
        return jsonify(rezerva_data)


# Route for /api/trenutno_stanje
@app.route("/api/trenutno_stanje", methods=["GET"])
def handle_trenutno_stanje():
    if request.method == "GET":
        cursor.execute(
            "SELECT TOP (1000) [RB], [Pozicija], [Alat], [Kerijer] FROM [Foam_tools].[dbo].[Trenutno_stanje]"
        )
        trenutno_stanje_data = [
            dict(zip([column[0] for column in cursor.description], row))
            for row in cursor.fetchall()
        ]
        return jsonify(trenutno_stanje_data)


if __name__ == "__main__":
    app.run(debug=True)


# Fa87362/..aa!fF

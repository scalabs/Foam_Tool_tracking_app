from flask import Flask, jsonify, request
from flask_cors import CORS  # Import CORS from flask_cors
import pyodbc

app = Flask(__name__)
CORS(app) 

# Replace these with your actual SQL Server credentials
server = '127.0.0.1'
port = 3306
database = 'Foam_tools'
username = 'bde'
password = '!bde1234'
driver = 'ODBC Driver 17 for SQL Server'

conn_str = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

@app.route('/api/active', methods=['GET', 'POST'])
def handle_active():
    if request.method == 'GET':
        cursor.execute('SELECT TOP (1000) [RB], [Pozicija], [Alat], [Kerijer] FROM [Foam_tools].[dbo].[Active]')
        active_data = [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]
        return jsonify(active_data)

    elif request.method == 'POST':
        data = request.get_json()
        # Add logic to handle the POST request if needed
        return jsonify({'message': 'POST request received'})

# Route for /api/karijeri
@app.route('/api/karijeri', methods=['GET'])
def handle_karijeri():
    if request.method == 'GET':
        cursor.execute('SELECT TOP (1000) [RB], [IB], [Proizvodjac], [Serijski_broj], [Pozicija] FROM [Foam_tools].[dbo].[Karijeri]')
        karijeri_data = [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]
        return jsonify(karijeri_data)

# Route for /api/oficijalno
@app.route('/api/oficijalno', methods=['GET'])
def handle_oficijalno():
    if request.method == 'GET':
        cursor.execute('SELECT TOP (1000) [Interni_broj], [Kupac], [Projekat], [Vrsta_alata], [Broj_proizvoda], [Kavitet] FROM [Foam_tools].[dbo].[Oficijalno]')
        oficijalno_data = [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]
        return jsonify(oficijalno_data)

# Route for /api/rezerva
@app.route('/api/rezerva', methods=['GET'])
def handle_rezerva():
    if request.method == 'GET':
        cursor.execute('SELECT TOP (1000) [RB], [Pozicija], [Alat], [Lokacija] FROM [Foam_tools].[dbo].[Rezerva]')
        rezerva_data = [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]
        return jsonify(rezerva_data)

# Route for /api/trenutno_stanje
@app.route('/api/trenutno_stanje', methods=['GET'])
def handle_trenutno_stanje():
    if request.method == 'GET':
        cursor.execute('SELECT TOP (1000) [RB], [Pozicija], [Alat], [Kerijer] FROM [Foam_tools].[dbo].[Trenutno_stanje]')
        trenutno_stanje_data = [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]
        return jsonify(trenutno_stanje_data)

if __name__ == '__main__':
    app.run(debug=True)


# Fa87362/..aa!fF
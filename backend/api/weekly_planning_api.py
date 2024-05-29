from flask import Flask, jsonify, request
from flask_cors import CORS
import pyodbc
 
app = Flask(__name__)
CORS(app)
 
# Replace these with your actual SQL Server credentials
server = '127.0.0.1'
port = 3306  # Default port for SQL Server
database = 'Foam_tools'
username = 'bde'
password = '!bde1234'
driver = 'ODBC Driver 17 for SQL Server'
 
conn_str = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}'
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()
 
@app.route('/api/weekly_shifts', methods=['GET', 'POST'])
def handle_weekly_shifts():
    if request.method == 'GET':
        cursor.execute('SELECT TOP (1000) * FROM [Foam_tools].[dbo].[weekly_shifts]')
        weekly_shifts_data = [dict(zip([column[0] for column in cursor.description], row)) for row in cursor.fetchall()]
        return jsonify(weekly_shifts_data)
 
    elif request.method == 'POST':
        data = request.get_json()
        tools_in_usage = data.get('ToolsInUsage')
        calendar_week = data.get('CalendarWeek')
        calendar_year = data.get('CalendarYear')
        ordered_units = data.get('OrderedUnits')
        adjusted_units_ordered = data.get('AdjustedUnitsOrdered')
        targeted_cycle_time = data.get('TargetedCycleTime')
        adjusted_cycle_time = data.get('AdjustedCycleTime')
        json_data = data.get('JsonData')
 
        if tools_in_usage and calendar_week and calendar_year and ordered_units and adjusted_units_ordered and targeted_cycle_time and adjusted_cycle_time and json_data:
            cursor.execute("INSERT INTO [Foam_tools].[dbo].[weekly_shifts] (ToolsInUsage, CalendarWeek, CalendarYear, OrderedUnits, AdjustedUnitsOrdered, TargetedCycleTime, AdjustedCycleTime, JsonData) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                           (tools_in_usage, calendar_week, calendar_year, ordered_units, adjusted_units_ordered, targeted_cycle_time, adjusted_cycle_time, json_data))
            conn.commit()
            return jsonify({'message': 'Data added successfully'})
        else:
            return jsonify({'error': 'Incomplete data provided'}), 400

@app.route('/api/weekly_shifts/<int:id>', methods=['PUT'])
def update_weekly_shift(id):
    data = request.get_json()
    tools_in_usage = data.get('ToolsInUsage')
    calendar_week = data.get('CalendarWeek')
    calendar_year = data.get('CalendarYear')
    ordered_units = data.get('OrderedUnits')
    adjusted_units_ordered = data.get('AdjustedUnitsOrdered')
    targeted_cycle_time = data.get('TargetedCycleTime')
    adjusted_cycle_time = data.get('AdjustedCycleTime')
    json_data = data.get('JsonData')
    
    if not (tools_in_usage and calendar_week and calendar_year and ordered_units and adjusted_units_ordered and targeted_cycle_time and adjusted_cycle_time and json_data):
        return jsonify({'error': 'Incomplete data provided'}), 400
    
    cursor.execute("""
        UPDATE [Foam_tools].[dbo].[weekly_shifts]
        SET ToolsInUsage = ?,
            CalendarWeek = ?,
            CalendarYear = ?,
            OrderedUnits = ?,
            AdjustedUnitsOrdered = ?,
            TargetedCycleTime = ?,
            AdjustedCycleTime = ?,
            JsonData = ?
        WHERE ID = ?
        """, (tools_in_usage, calendar_week, calendar_year, ordered_units, adjusted_units_ordered, targeted_cycle_time, adjusted_cycle_time, json_data, id))
    
    conn.commit()
    return jsonify({'message': 'Data updated successfully'}), 200

@app.route('/api/weekly_shifts/<int:id>', methods=['DELETE'])
def delete_weekly_shift(id):
    cursor.execute("DELETE FROM [Foam_tools].[dbo].[weekly_shifts] WHERE ID = ?", (id,))
    conn.commit()
    return jsonify({'message': 'Data deleted successfully'}), 200

if __name__ == '__main__':
    app.run(debug=True)

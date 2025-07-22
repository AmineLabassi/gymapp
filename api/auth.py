import sqlite3
import os
import base64
import face_recognition
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
CORS(app)

# Initialize DB
def init_db():
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            username TEXT PRIMARY KEY,
            password TEXT NOT NULL,
            gender TEXT,
            goal TEXT,
            height REAL,
            weight REAL,
            age INTEGER
        )
    ''')
    conn.commit()
    conn.close()

init_db()

# ========== AUTH ROUTES ==========

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password_raw = data.get('password')
    gender = data.get('gender')
    goal = data.get('goal')
    height = data.get('height')
    weight = data.get('weight')
    age = data.get('age')

    password = generate_password_hash(password_raw) if password_raw else ''

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()

    cursor.execute('SELECT * FROM users WHERE username = ?', (username,))
    if cursor.fetchone():
        conn.close()
        return jsonify({'message': 'User already exists'}), 400

    cursor.execute('''
        INSERT INTO users (username, password, gender, goal, height, weight, age)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (username, password, gender, goal, height, weight, age))

    conn.commit()
    conn.close()
    return jsonify({'message': 'User registered successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('SELECT password FROM users WHERE username = ?', (username,))
    result = cursor.fetchone()
    conn.close()

    if result and check_password_hash(result[0], password):
        return jsonify({'message': 'Login successful'}), 200
    return jsonify({'message': 'Invalid credentials'}), 401

@app.route('/user/<username>', methods=['GET'])
def get_user(username):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('SELECT username, weight, height, age, gender, goal FROM users WHERE username = ?', (username,))
    result = cursor.fetchone()
    conn.close()

    if result:
        return jsonify({
            'username': result[0],
            'weight': result[1],
            'height': result[2],
            'age': result[3],
            'gender': result[4],
            'goal': result[5]
        }), 200
    else:
        return jsonify({'message': 'User not found'}), 404

@app.route('/change-password', methods=['POST'])
def change_password():
    data = request.get_json()
    username = data.get('username')
    new_password_raw = data.get('password')
    new_password = generate_password_hash(new_password_raw)

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('UPDATE users SET password = ? WHERE username = ?', (new_password, username))
    conn.commit()
    conn.close()

    return jsonify({'message': 'Password updated successfully'}), 200

@app.route('/profile', methods=['POST'])
def update_profile():
    data = request.get_json()
    username = data.get('username')
    gender = data.get('gender')
    goal = data.get('goal')
    height = data.get('height')
    weight = data.get('weight')
    age = data.get('age')

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('''
        UPDATE users
        SET gender = ?, goal = ?, height = ?, weight = ?, age = ?
        WHERE username = ?
    ''', (gender, goal, height, weight, age, username))

    conn.commit()
    conn.close()
    return jsonify({'message': 'Profile updated successfully'}), 200

@app.route('/social-login', methods=['POST'])
def social_login():
    data = request.get_json()
    email = data.get('email')
    provider = data.get('provider')

    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users WHERE username = ?', (email,))
    user = cursor.fetchone()

    if not user:
        cursor.execute('''
            INSERT INTO users (username, password, gender, goal, height, weight, age)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (email, '', '', '', 0.0, 0.0, 0))
        conn.commit()

    conn.close()
    return jsonify({'message': f'Social login successful via {provider}', 'username': email}), 200

# ========== FACE RECOGNITION ROUTES ==========

@app.route('/upload-face', methods=['POST'])
def upload_face():
    data = request.get_json()
    username = data.get('username')
    face_data = data.get('face_image')  # base64 string

    if not username or not face_data:
        return jsonify({'message': 'Missing data'}), 400

    face_bytes = base64.b64decode(face_data.split(',')[1])
    os.makedirs('faces', exist_ok=True)
    filepath = f'faces/{username}.jpg'

    with open(filepath, 'wb') as f:
        f.write(face_bytes)

    return jsonify({'message': 'Face saved successfully'}), 200

@app.route('/verify-face', methods=['POST'])
def verify_face():
    data = request.get_json()
    username = data.get('username')
    face_data = data.get('face_image')

    filepath = f'faces/{username}.jpg'
    if not os.path.exists(filepath):
        return jsonify({'message': 'No face registered for this user'}), 404

    known_image = face_recognition.load_image_file(filepath)
    known_encodings = face_recognition.face_encodings(known_image)

    if not known_encodings:
        return jsonify({'message': 'No face found in registered image'}), 400

    uploaded_bytes = base64.b64decode(face_data.split(',')[1])
    with open('temp.jpg', 'wb') as f:
        f.write(uploaded_bytes)

    test_image = face_recognition.load_image_file('temp.jpg')
    test_encodings = face_recognition.face_encodings(test_image)
    os.remove('temp.jpg')

    if not test_encodings:
        return jsonify({'message': 'No face found in uploaded image'}), 400

    result = face_recognition.compare_faces([known_encodings[0]], test_encodings[0])
    if result[0]:
        return jsonify({'message': 'Face match'}), 200
    else:
        return jsonify({'message': 'Face does not match'}), 401

# ========== START SERVER ==========

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

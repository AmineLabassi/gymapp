import sqlite3
import os
import base64
import face_recognition
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import joblib
import pandas as pd
import re
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

def init_gym_db():
    conn = sqlite3.connect('gym.db')
    cursor = conn.cursor()

    # Create goals table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
        )
    ''')

    # Create days table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS days (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            goal_id INTEGER,
            name TEXT,
            FOREIGN KEY(goal_id) REFERENCES goals(id)
        )
    ''')

    # Create exercises table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day_id INTEGER,
            name TEXT,
            reps TEXT,
            video_url TEXT,
            FOREIGN KEY(day_id) REFERENCES days(id)
        )
    ''')

    conn.commit()
    conn.close()


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

# ==== Chargement des modèles et encodeurs ====
model_bf = joblib.load('models/breakfast_model.pkl')
model_ln = joblib.load('models/lunch_model.pkl')
model_dn = joblib.load('models/dinner_model.pkl')

enc_bf = joblib.load('models/breakfast_encoder.pkl')
enc_ln = joblib.load('models/lunch_encoder.pkl')
enc_dn = joblib.load('models/dinner_encoder.pkl')

import re

@app.route('/diet', methods=['POST'])
def generate_diet():
    data = request.get_json()
    username = data.get('username')
    calories = data.get('calories_to_maintain_weight')

    if not username or not calories:
        return jsonify({'error': 'Username and calories are required'}), 400

    # Get user data
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute('SELECT age, weight, height, gender FROM users WHERE username = ?', (username,))
    result = cursor.fetchone()
    conn.close()

    if not result:
        return jsonify({'error': 'User not found'}), 404

    age, weight, height, gender = result

    df = pd.DataFrame([{
        "age": age,
        "weight(kg)": weight,
        "height(m)": height,
        "gender": gender,
        "calories_to_maintain_weight": calories
    }])
    df["gender"] = df["gender"].map({
        "male": "M", "female": "F",
        "Male": "M", "Female": "F",
        "M": "M", "F": "F"
    }).fillna("M")

    # Default balanced meals
    default_bf = "60g of oats + 150g of banana + 150ml of milk"
    default_ln = "200g of rice + 130g of chicken + 300g of vegetables"
    default_dn = "180g of pasta + 130g of tuna + 300g of vegetables"

    try:
        # Predict meals
        pred_bf = model_bf.predict(df)[0]
        pred_ln = model_ln.predict(df)[0]
        pred_dn = model_dn.predict(df)[0]

        # Ensure valid labels
        breakfast = pred_bf if pred_bf in enc_bf.classes_ else default_bf
        lunch = pred_ln if pred_ln in enc_ln.classes_ else default_ln
        dinner = pred_dn if pred_dn in enc_dn.classes_ else default_dn

        # Use estimation to validate prediction quality
        def estimate_calories(meal_text):
            food_calories = {
                "oats": 389,
                "banana": 89,
                "milk": 42,
                "rice": 130,
                "chicken": 165,
                "vegetables": 35,
                "tuna": 132,
                "pasta": 131,
                "whole wheat bread": 250,
                "egg": 155,
                "plain yogurt": 59,
                "vegetable soup": 40
            }
            import re
            total = 0
            for food, kcal_per_100 in food_calories.items():
                match = re.search(rf"(\d+)\s*(g|ml)?\s*(of|de)?\s*{food}", meal_text, re.IGNORECASE)
                if match:
                    qty = int(match.group(1))
                    total += (qty / 100) * kcal_per_100
            return total

        # Total calorie estimation
        total_cal = (
            estimate_calories(breakfast) +
            estimate_calories(lunch) +
            estimate_calories(dinner)
        )

        # If too far from target, fallback to balanced default meals
        if abs(total_cal - calories) > 250:  # tolerance range
            breakfast = default_bf
            lunch = default_ln
            dinner = default_dn

        return jsonify({
            "breakfast": breakfast,
            "lunch": lunch,
            "dinner": dinner,
            "calories": round(calories)
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500



gainMuscleProgram = [
    {'day': 'Monday - Push', 'exercises': [
        {'name': 'Barbell Bench Press', 'reps': '4x10', 'videoUrl': 'https://www.youtube.com/watch?v=gRVjAtPip0Y'},
        {'name': 'Overhead Press', 'reps': '4x10', 'videoUrl': 'https://www.youtube.com/watch?v=qEwKCR5JCog'},
        {'name': 'Dumbbell Chest Fly', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=eozdVDA78K0'},
        {'name': 'Triceps Extension', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=nRiJVZDpdL0'}
    ]},
    {'day': 'Tuesday - Pull', 'exercises': [
        {'name': 'Seated Row', 'reps': '4x10', 'videoUrl': 'https://www.youtube.com/watch?v=GZbfZ033f74'},
        {'name': 'Assisted Pull-ups', 'reps': '3x8', 'videoUrl': 'https://www.youtube.com/watch?v=0ZkivYwS5zM'},
        {'name': 'Bicep Curls', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo'}
    ]},
    {'day': 'Wednesday - Legs', 'exercises': [
        {'name': 'Barbell Squats', 'reps': '4x12', 'videoUrl': 'https://www.youtube.com/watch?v=Dy28eq2PjcM'},
        {'name': 'Walking Lunges', 'reps': '3x10', 'videoUrl': 'https://www.youtube.com/watch?v=wrwwXE_x-pQ'},
        {'name': 'Romanian Deadlift', 'reps': '3x10', 'videoUrl': 'https://www.youtube.com/watch?v=2SHsk9AzdjA'},
        {'name': 'Calf Raises', 'reps': '3x20', 'videoUrl': 'https://www.youtube.com/watch?v=-M4-G8p8fmc'}
    ]},
    {'day': 'Thursday', 'exercises': []},
    {'day': 'Friday - Push', 'exercises': [
        {'name': 'Incline Dumbbell Press', 'reps': '4x10', 'videoUrl': 'https://www.youtube.com/watch?v=8iPEnn-ltC8'},
        {'name': 'Dips', 'reps': '3x8', 'videoUrl': 'https://www.youtube.com/watch?v=2z8JmcrW-As'},
        {'name': 'Lateral Raises', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=kDqklk1ZESo'}
    ]},
    {'day': 'Saturday - Pull', 'exercises': [
        {'name': 'Barbell Row', 'reps': '4x10', 'videoUrl': 'https://www.youtube.com/watch?v=vT2GjY_Umpw'},
        {'name': 'Face Pulls', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=rep-qVOkqgk'},
        {'name': 'Hammer Curls', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=zC3nLlEvin4'}
    ]},
    {'day': 'Sunday - Legs/Optional', 'exercises': [
        {'name': 'Leg Press', 'reps': '4x10', 'videoUrl': 'https://www.youtube.com/watch?v=IZxyjW7MPJQ'},
        {'name': 'Leg Curl Machine', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=1Tq3QdYUuHs'}
    ]}
]

loseWeightProgram = [
    {'day': 'Monday - Push', 'exercises': [
        {'name': 'Push-ups', 'reps': '4x20', 'videoUrl': 'https://www.youtube.com/watch?v=IODxDxX7oi4'},
        {'name': 'Bench Dips', 'reps': '3x15', 'videoUrl': 'https://www.youtube.com/watch?v=0326dy_-CzM'},
        {'name': 'Dumbbell Shoulder Press', 'reps': '3x15', 'videoUrl': 'https://www.youtube.com/watch?v=B-aVuyhvLHU'}
    ]},
    {'day': 'Tuesday - Pull', 'exercises': [
        {'name': 'Cable Row', 'reps': '3x15', 'videoUrl': 'https://www.youtube.com/watch?v=HJSVR_67OlM'},
        {'name': 'Bicep Curls', 'reps': '3x20', 'videoUrl': 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo'},
        {'name': 'Plank', 'reps': '3x1 min', 'videoUrl': 'https://www.youtube.com/watch?v=pSHjTRCQxIw'}
    ]},
    {'day': 'Wednesday - Legs', 'exercises': [
        {'name': 'Bodyweight Squats', 'reps': '4x20', 'videoUrl': 'https://www.youtube.com/watch?v=aclHkVaku9U'},
        {'name': 'Walking Lunges', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=wrwwXE_x-pQ'},
        {'name': 'Jump Squats', 'reps': '3x15', 'videoUrl': 'https://www.youtube.com/watch?v=U4s4mEQ5VqU'}
    ]},
    {'day': 'Thursday', 'exercises': []},
    {'day': 'Friday - Push', 'exercises': [
        {'name': 'Incline Push-ups', 'reps': '4x20', 'videoUrl': 'https://www.youtube.com/watch?v=EDG7Yg6tzKY'},
        {'name': 'Lateral Raises', 'reps': '3x15', 'videoUrl': 'https://www.youtube.com/watch?v=kDqklk1ZESo'},
        {'name': 'Triceps Dips', 'reps': '3x12', 'videoUrl': 'https://www.youtube.com/watch?v=0326dy_-CzM'}
    ]},
    {'day': 'Saturday - Pull', 'exercises': [
        {'name': 'Lat Pulldown', 'reps': '3x15', 'videoUrl': 'https://www.youtube.com/watch?v=CAwf7n6Luuc'},
        {'name': 'Resistance Band Row', 'reps': '3x20', 'videoUrl': 'https://www.youtube.com/watch?v=sP_4vybjVJs'},
        {'name': 'Side Plank', 'reps': '3x45 sec', 'videoUrl': 'https://www.youtube.com/watch?v=K2VljzCC16g'}
    ]},
    {'day': 'Sunday - Cardio + Stretch', 'exercises': [
        {'name': 'Light cardio (walk/cycle)', 'reps': '30-40 min', 'videoUrl': 'https://www.youtube.com/watch?v=ml6cT4AZdqI'},
        {'name': 'Full-body Stretching', 'reps': '15 min', 'videoUrl': 'https://www.youtube.com/watch?v=qULTwquOuT4'}
    ]}
]
def insert_program_to_db(goal_name, program_data):

    conn = sqlite3.connect('gym.db')
    cursor = conn.cursor()

    cursor.execute('INSERT OR IGNORE INTO goals (name) VALUES (?)', (goal_name,))
    goal_id = cursor.execute('SELECT id FROM goals WHERE name = ?', (goal_name,)).fetchone()[0]

    for day in program_data:
        cursor.execute('INSERT INTO days (goal_id, name) VALUES (?, ?)', (goal_id, day['day']))
        day_id = cursor.lastrowid

        for ex in day['exercises']:
            cursor.execute('INSERT INTO exercises (day_id, name, reps, video_url) VALUES (?, ?, ?, ?)',
                           (day_id, ex['name'], ex['reps'], ex['videoUrl']))
    
    conn.commit()
    conn.close()

@app.route('/gym', methods=['GET'])
def get_all_programs():
    conn = sqlite3.connect('gym.db')
    cursor = conn.cursor()

    # Enable dictionary cursor
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Fetch all goals
    cursor.execute("SELECT id, name FROM goals")
    goals = cursor.fetchall()

    all_programs = []

    for goal in goals:
        goal_id = goal['id']
        goal_name = goal['name']

        # Fetch days for this goal
        cursor.execute("""
            SELECT id, name FROM days
            WHERE goal_id = ?
            ORDER BY id ASC
        """, (goal_id,))
        days = cursor.fetchall()

        program = []
        for day in days:
            day_id = day['id']
            day_name = day['name']

            # Fetch exercises for this day
            cursor.execute("""
                SELECT name, reps, video_url FROM exercises
                WHERE day_id = ?
            """, (day_id,))
            exercises_raw = cursor.fetchall()

            exercises = [
                {
                    "name": ex['name'],
                    "reps": ex['reps'],
                    "videoUrl": ex['video_url']
                }
                for ex in exercises_raw
            ]

            program.append({
                "day": day_name,
                "exercises": exercises
            })

        all_programs.append({
            "goal": goal_name,
            "program": program
        })

    conn.close()
    return jsonify(all_programs)



# ========== START SERVER ==========

if __name__ == '__main__':
    init_gym_db()

    insert_program_to_db("gain muscle", gainMuscleProgram)
    insert_program_to_db("lose weight", loseWeightProgram)
    app.run(host='0.0.0.0', port=5000, debug=True)

import sqlite3
import os
from dotenv import load_dotenv

load_dotenv()

DB_PATH = os.getenv("DATABASE_PATH")

def initialize_database():
    """Initialize the SQLite database and create necessary tables."""
    # Check if the file_log.db exists
    if not os.path.exists(DB_PATH):
        print(f"⚠️ Database not found. Creating {DB_PATH}...")
        # Create the file if it doesn't exist
        open(DB_PATH, 'w').close()

    # Check if the file is empty
    if os.path.getsize(DB_PATH) == 0:
        print(f"⚠️ Database file is empty. Initializing database at {DB_PATH}...")

    # Connect to the SQLite database (it will create the file if it doesn't exist)
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create a table for file logging if it doesn't already exist
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS file_log (
                    file_name TEXT PRIMARY KEY,
                    last_modified TIMESTAMP,
                    last_processed TIMESTAMP
    )
    """)

    # Commit the changes and close the connection
    conn.commit()
    conn.close()
    print(f"✅ Database initialized at {DB_PATH}")

if __name__ == "__main__":
    initialize_database()
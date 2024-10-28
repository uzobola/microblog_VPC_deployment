#!/usr/bin/env python
# Shebang line to make the file executable on Unix-like systems

import unittest
from app import create_app
from app import db
from app.models import User, Post
from config import Config

# Test configuration class that inherits from main Config
class TestConfig(Config):
    TESTING = True                                  # Enables testing mode
    SQLALCHEMY_DATABASE_URI = 'sqlite://'           # Use in-memory SQLite database
    ELASTICSEARCH_URL = None                        # Disable Elasticsearch for testing

# Main test class inheriting from unittest.TestCase
class TestApp(unittest.TestCase):
    def setUp(self):
        # This runs before each test
        self.app = create_app(TestConfig)           # Create app with test config
        self.client = self.app.test_client()        # Create test client
        self.app_context = self.app.app_context()   # Get application context
        self.app_context.push()                     # Push context to stack
        db.create_all()                             # Create all database tables

    def tearDown(self):
        # This runs after each test
        db.session.remove()                         # Remove database session
        db.drop_all()                               # Drop all tables
        self.app_context.pop()                      # Remove context from stack

    def test_login_page(self):
        # Test case for login page
        response = self.client.get('auth/login')    # Send GET request to login page
        self.assertEqual(response.status_code, 200)  # Check if response is OK (200)
        self.assertIn(b'Sign In', response.data)    # Check if 'Sign In' is in response

# Run tests if file is executed directly
if __name__ == '__main__':
    unittest.main(verbosity=2)                      # Run tests with detailed output

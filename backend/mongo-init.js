// MongoDB Initialization Script

// Get reference to the database
db = db.getSiblingDB('taskdo');

// Create application user
db.createUser({
  user: 'taskdo_user',
  pwd: 'password',  // In production, use the value from environment variable
  roles: [
    { role: 'readWrite', db: 'taskdo' }
  ]
});

// Create collections with validation
db.createCollection('users');
db.createCollection('projects');
db.createCollection('tasks');
db.createCollection('tags');
db.createCollection('pomodoro_sessions');

// Create indexes for better performance

// Users collection
db.users.createIndex({ email: 1 }, { unique: true });

// Projects collection
db.projects.createIndex({ user_id: 1 });
db.projects.createIndex({ is_archived: 1 });

// Tasks collection
db.tasks.createIndex({ user_id: 1 });
db.tasks.createIndex({ project_id: 1 });
db.tasks.createIndex({ status: 1 });
db.tasks.createIndex({ due_date: 1 });
db.tasks.createIndex({ is_archived: 1 });
db.tasks.createIndex({ is_deleted: 1 });
db.tasks.createIndex({ tags: 1 });

// Tags collection
db.tags.createIndex({ user_id: 1 });
db.tags.createIndex({ name: 1, user_id: 1 }, { unique: true });

// Pomodoro sessions collection
db.pomodoro_sessions.createIndex({ user_id: 1 });
db.pomodoro_sessions.createIndex({ task_id: 1 });
db.pomodoro_sessions.createIndex({ start_time: 1 });

// Print initialization complete message
print('MongoDB initialization completed.');

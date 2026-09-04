# Task Management & To-Do API

A RESTful task management API built with Django REST Framework, supporting JWT authentication and full CRUD operations for tasks, with users able to access and modify only their own data.

## Features

- User registration and JWT-based login (access + refresh tokens)
- Full CRUD for tasks (create, read, update, delete)
- Custom permissions — users can only access/modify their own tasks
- Filtering tasks by status, priority, and due date
- Fully documented and tested via Postman collection

## Tech Stack

- Python, Django, Django REST Framework
- SQLite
- JWT Authentication (djangorestframework-simplejwt)
- django-filter
- Postman (API testing & documentation)

## Setup

\`\`\`bash
git clone https://github.com/yourusername/taskmanager-api.git
cd taskmanager-api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
\`\`\`

## API Endpoints

| Method | Endpoint              | Description                  | Auth Required |
|--------|------------------------|-------------------------------|----------------|
| POST   | /api/register/          | Register a new user           | No             |
| POST   | /api/token/              | Login (returns JWT tokens)    | No             |
| POST   | /api/token/refresh/      | Refresh access token          | No             |
| GET    | /api/tasks/              | List authenticated user's tasks | Yes          |
| POST   | /api/tasks/              | Create a task                 | Yes            |
| GET    | /api/tasks/{id}/         | Retrieve a task                | Yes            |
| PATCH  | /api/tasks/{id}/         | Update a task                  | Yes            |
| DELETE | /api/tasks/{id}/         | Delete a task                  | Yes            |

Tasks can be filtered via query params: \`?status=pending\`, \`?priority=high\`, \`?due_date=2026-09-10\`

## Postman Collection

Import \`taskmanager-api.postman_collection.json\` into Postman to test all endpoints. Set the \`base_url\` environment variable to \`http://127.0.0.1:8000\`.

## Design Notes

- Task ownership is enforced server-side — the \`owner\` field is read-only in the serializer and set automatically from the authenticated user, preventing users from assigning tasks to others.
- \`get_queryset()\` is overridden per-user so tasks belonging to other users are not just forbidden but invisible (404, not 403), reducing information leakage.


## Challenges Solved

- **Preventing ownership spoofing**: Initially, task ownership could be set by whatever the client sent in the request body. Fixed by making the `owner` field read-only in the serializer and assigning it server-side in `perform_create()` from the authenticated request user — ensuring a user can never create or reassign a task to someone else.

- **Information leakage on unauthorized access**: Rather than only relying on a permission check (which returns 403 and confirms an object exists), overrode `get_queryset()` to scope every query to `request.user` first. This means requesting another user's task by ID returns 404, not 403 — the object is invisible rather than merely forbidden, which is a stronger privacy guarantee.

- **Password security in registration**: The default DRF `ModelSerializer.create()` would have stored passwords in plain text. Solved by overriding `create()` to use Django's `User.objects.create_user()`, which hashes passwords automatically, and marking the `password` field `write_only` so it's never exposed in API responses.

- **JWT token lifecycle**: Handled short-lived access tokens (60 min) paired with longer-lived refresh tokens (1 day), and implemented the `/api/token/refresh/` flow so clients can maintain a session without re-authenticating with credentials each time.
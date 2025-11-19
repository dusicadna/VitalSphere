# VitalSphere

VitalSphere is a comprehensive wellness platform that provides a complete ecosystem for managing wellness services, products, appointments, and e-commerce functionality. The platform consists of a .NET backend API, Flutter desktop and mobile applications, and integrates with RabbitMQ for asynchronous messaging and email notifications.

```
VitalSphere/
├── VitalSphere.WebAPI/          # REST API
├── VitalSphere.Services/        # Business logic & data access
├── VitalSphere.Model/            # Models, DTOs, requests/responses
├── VitalSphere.Subscriber/       # RabbitMQ subscriber service
├── UI/
│   ├── vital_sphere_desktop/    # Flutter desktop app
│   └── vital_sphere_mobile/     # Flutter mobile app
├── docker-compose.yml            # Docker Compose configuration
├── Dockerfile                    # API container image
└── Dockerfile.notifications      # Subscriber service container image
```

**Configure environment variables**
   You can adjust `.env` file in the `VitalSphere` directory with the following variables:
   ```env
   SQL__PASSWORD=YourSQLPassword
   SQL__USER=sa
   SQL__DATABASE=VitalSphereDb
   SQL__PID=Developer
   RABBITMQ__HOST=rabbitmq
   RABBITMQ__USERNAME=guest
   RABBITMQ__PASSWORD=guest
   ```
   and `.env` in `VitalSphere.UI.vital_sphere_mobile` for:
   ```env
   STRIPE_PUBLISHABLE_KEY=...
   STRIPE_SECRET_KEY=...

## 🔐 Test Accounts

### Desktop Application (Admin)
- **Username**: `admin`
- **Password**: `test`

### Mobile Application (User)
- **Username**: `user`
- **Password**: `test`
- **Email**: `vitalsphere.receiver@gmail.com`
- **Email Password**: `VitalSphere2001`

## 📧 RabbitMQ & Email Notifications

The platform uses RabbitMQ for asynchronous appointment notifications:

1. When a user schedules an appointment through the mobile app, the API publishes a message to RabbitMQ
2. The `VitalSphere.Subscriber` service consumes the message
3. An email confirmation is sent to the user's registered email address

### Testing Email Notifications

1. Log in to the mobile app with the test user account (`user` / `test`)
2. Schedule a wellness service appointment
3. Check the email inbox for `vitalsphere.receiver@gmail.com` (password: `VitalSphere2001`)
4. You should receive an appointment confirmation email


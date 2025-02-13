# Authentication service
## Send http from another pod
curl -X POST https://cscloud8-134.lnu.se/api/auth/signin-google -H "Content-Type:application/json" -d '{"tokenId":"google-auth-token"}'

## Endpoint Details

### **URL**
`POST /api/auth/signin-google`

### **Request Format**

#### **Headers**
No specific headers required beyond standard API headers.

#### **Body**
The body should be sent as JSON and contain the following:

| Field       | Type   | Description                          |
|-------------|--------|--------------------------------------|
| `tokenId`   | string | Google ID Token provided by the client. |

**Example Request Body:**
```json
{
  "tokenId": "eyJhbGciOiJSUzI1NiIsImtpZ..."
}
```

## Response Format
On successful authentication, the server returns an HTTP 200 status code along with the generated JWT.

### Response Example:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
}
```

## JWT Token Structure
The `AuthController` in the provided code generates a JWT token when a user signs in using Google. Below are the details about what is included in the token:

### Claims in the Token

1. **Subject (`sub`)**  
   - Represents the encrypted email of the authenticated user.

2. **JWT ID (`jti`)**  
   - A unique identifier for the JWT.

3. **Name (`name`)**  
   - The name of the authenticated user.

4. **Email (`email`)**  
   - The email address of the authenticated user.

5. **Picture (`picture`)**  
   - URL of the authenticated user's profile picture.

## Example: 
{
  "sub": "vS0GCAKFzottIl5yHSsr1dx1u8JCWYrJ8AdT3yAdvNo=",
  "jti": "374c8445-21e5-4d4a-b000-4be4222354d3",
  "name": "Vanja Maric",
  "email": "vm222hx@student.lnu.se",
  "picture": "https://lh3.googleusercontent.com/a/ACg8ocKHzClLLe7ZOg6KC_7H-JgA7WlPNl8uLdw1dGOjLwQ__iO3=s96-c",
  "exp": 1735545211
}

## Token Configuration
- **Signing Key**:  
  A symmetric security key derived from the environment variable `JWT_SECRET`.

- **Signing Algorithm**:  
  HMAC-SHA256 (`SecurityAlgorithms.HmacSha256`).

- **Expiration**:  
  The token expires 55 minutes after it is issued (`DateTime.UtcNow.AddMinutes(55)`).

## Token Response

The generated token is returned as part of the API response in the following format:
```json
{
  "token": "jwt_generated_token"
}
```

## Run locally
- minikube start
- minikube addons enable ingress
- minikube tunnel
- kubectl create secret docker-registry regcred   --docker-server=gitlab.lnu.se:5050   --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
- skaffold dev
- kubectl port-forward pod/auth-7b7749d957-86wtj  8080:8080
- Send POST request at: http://localhost:8080/auth/Auth/signin-google 
----------------------------------------------------------------------------
## Enter db: 
- psql -h localhost -U postgres -d postgres
- SELECT * FROM pg_stat_activity;
- DELETE FROM "Users" WHERE "Email" = 'vm222hx@student.lnu.se';
- SELECT * FROM "Users" WHERE "Email" = 'vm222hx@student.lnu.se';

## Create debbug pod 
- kubectl run debug-pod --rm -it --image=alpine -- sh
- apk add --no-cache curl


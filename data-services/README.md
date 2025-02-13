# DATA SERVICES

## ## Endpoints

### 1. `POST /Data/startScraping`
Initiates the scraping process for the user.

#### Request
- **Method**: `POST`
- **Headers**:
  - `Authorization`: `Bearer <JWT_TOKEN>` 
- **Body**:
  - City (string, required): The city where the user is located.
  - CollegeName (string, optional): The name of the college associate with the user.

#### Response
- **200 OK**: The scraping process was successfully initiated.
- **400 Bad Request**: If the required fields in the body are missing (e.g., City).
- **401 Unauthorized**: If the email claim is not found in the token.

#### Example Request:
```bash
curl -X POST https://cscloud8-111.lnu.se/api/Data/startScraping -H "Authorization: Bearer <Jwt token>" -H "Content-Type: application/json" \
-d '{
  "City": "Gothenburg",
  "CollegeName": "Chalmers University of Technology"
}'
``` 

### 2. `GET /Data/getScrapedData`
Returns the scraped data for the authenticated user.

#### Request
- **Method**: `GET`
- **Authorization**: Required.
- **Headers**:
  - `Authorization`: `Bearer <JWT_TOKEN>`

#### Response
- **200 OK**: A list of scraped data.
Body example:
``` bash
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "nameOccurrences": 5,
    "emailOccurrences": 2,
    "linkedInTitle": "Software Engineer",
    "linkedInSnippet": "Experienced in C#, Java, and Python",
    "linkedInDescription": "Detailed profile about software engineering projects.",
    "dateScraped": "2025-01-01T12:00:00Z"
  }
]
```
- **401 Unauthorized**: If the user is not authenticated or the email claim is missing.

### Info:
If the data date is  "dateScraped": "0001-01-01T00:00:00" - The data has never been scraped 

## Data service
Rabbitmq works fine in development and creates "startScrapingDataQueue" queue. Í can not connect to rmq in k8s

RABBITMQ_HOST=rabbitmq.default.svc.cluster.local # In development use localhost, in prod replace.default with namspace name
RABBITMQ_PORT= 5672

#### Run locally
- minikube start
- minikube addons enable ingress
- minikube tunnel
- kubectl create secret docker-registry regcred   --docker-server=gitlab.lnu.se:5050   --docker-username=<your-username> --docker-password=<your-token> --docker-email=<your-email>
- skaffold dev
- kubectl port-forward pod/data-7b7749d957-86wtj  8080:8080    #change pod name to one data pod name
- Send Post request at: http://localhost:8080/Data/startScraping 

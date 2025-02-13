# Link to start URL of the application
https://cscloud8-111.lnu.se/
# Deployment pipeline anatomy
![pipeline_visualization](uploads/eed3c4fde4656ab625f5e089a6dfbab7/pipeline_visualization.png)


# Continuous Delivery principles adopted

## Branching strategy and merging
For all the repositories, we will be working inside the "development" branch while locally hosting the cluster with Skaffold. Developers will make changes in the development branch, and when those changes are ready, a merge request will be created to merge into the "main" branch. Once the changes are merged into main, the application will be automatically deployed to the staging environment. The staging environment mirrors the production environment to ensure consistency between the two. This process allows us to test changes in an environment that behaves similarly to production. If everything looks good and all tests pass, we will manually promote the changes to the production environment by triggering a manual deployment process.
The staging environment is hosted at https://cscloud8-111.lnu.se/staging/ and the production environment is hosted at https://cscloud8-111.lnu.se/.


## Repository 
The repository is a multi repo and consist of 4 repositories:
- Frontend: the React application;
- Authentication: the O-Auth Google login feature;
- Data Services: consists of 2 microservices - the data scraper and data service (that the frontend calls);
- Infrastructure: the terraform scripts required to build the infrastructure for all the services;


## Team practices 

### Meetings
Fridays: Stand-up where we present what we have done, plan on doing and any issues we may have encountered. Here we also discuss the results from user testing (if any). On Slack as needed and considering our planning. 

### Tools
- Figma: design
- Trello: planning
- Slack, Discord: communication
- Gitlab: version management, pipelines
- VSCode: source code

# Design
## Persona

![DALL_E_2024-12-03_10.02.49_-_En_ung_kvinna_i_20-årsåldern_med_axellångt_blont_hår_och_blå_ögon__sittande_vid_ett_skrivbord_med_en_laptop_framför_sig._Hon_bär_en_avslappnad_hoodie__1](uploads/b03e11d62cbf343ab435d3d7b0fb7898/DALL_E_2024-12-03_10.02.49_-_En_ung_kvinna_i_20-årsåldern_med_axellångt_blont_hår_och_blå_ögon__sittande_vid_ett_skrivbord_med_en_laptop_framför_sig._Hon_bär_en_avslappnad_hoodie__1.png)

Emma is a 23-year-old student from Stockholm who is passionate about digital privacy and technology. She enjoys drinking coffee and often spends time at cafés where she can read or work on her projects. She doesn't have many close friends but deeply values the relationships she has. When she's not studying or reading about cybersecurity, Emma likes to be creative by trying out new recipes in the kitchen or working on small projects at home. She has a relaxed style and prefers to keep things simple, both in her digital life and her everyday routine. Emma is looking for practical ways to protect her personal information and feel secure online.

**Motivations:**
- Protect her personal privacy and digital presence.
- Prevent her information from being exploited in data breaches or fraud.
- Feel safer online.

**Frustrations:**
- Lack of time to manually keep track of her online data.
- Worry that sensitive information could end up in the wrong hands without her knowledge.
- Difficulty managing multiple accounts and passwords.

**Goals:**
- Gain a clear overview of her digital presence and risks.
- Be able to respond to potential threats or leaks.

## User Interface Design
### Landing page
![UI_-_landing_page](uploads/d7f5ad7d97c3a698bec3cf70588297a7/UI_-_landing_page.png)

### Login popup
![Log_in_popup](uploads/6401c236d5e0fa22d53ff4928c2847e6/Log_in_popup.png)

### Account overview and scaping service
![Account_overview](uploads/75d537281d7e7e4edac978eae12e114f/Account_overview.png)

### User data
![My_data](uploads/5c32f1227cf4733637a564de6a76a32f/My_data.png)

## Architectural overview of the system

### User stories 

- As Emma I  want to be able to log in into the App with my Google account
- As Emma I want to see my profile
- As Emma I want to be able see my data if it is available
- As Emma I want to be able to scrape public data associated with my Name and email
- As Emma I want to be able to log out from the App

![user_story](uploads/8c76d0835b25fc20911aa0a3ab12a48e/user_story.png)


### Diagram
![Architectural_representation__2_](uploads/e7d1ad83ac3352611f429974e2699992/Architectural_representation__2_.png)

## Microservices

- Frontend: Handles user interactions.
- Auth Service: Manages authentication via OAuth2.
- Data Service: Processes and manages data.
- Data Scraper: Responsible for gathering external data.
- Supporting Components: Message Broker: Facilitates asynchronous communication.

## Communication protocols and patterns (e.g., HTTP, queues)

### Synchronous Messaging Pattern (Request-Response)
Direct HTTP-based communication:
Frontend → Data Service
Frontend → Auth Service
Auth Service → External API

### Asynchronous Messaging Pattern (Request-Reply)
Asynchronous communication with message queues:
Data Service → Data Scraper

## Data persistency

### Stack
- React: used for frontend.
- Express: used for scraper service.
- .NET: used for data service/OAuth service.
- Postgres: Centralized database for storing application data.
- Redis: Used for caching, optional.

### Principle
Replication of database where we share Database with CQRS: Keep one database for all but add read replicas to boost read performance if needed.

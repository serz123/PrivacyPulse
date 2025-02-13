# Stage 1: Build

FROM gitlab.lnu.se:5050/2dv013/student/team-2024-03-pikachu/frontend/node:20.8.0-bullseye-slim AS builder

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install all dependencies including dev dependencies
RUN npm ci

# Copy application code
COPY . .

# Build the application passing the environment variable
RUN npm run build 

# Stage 2: Production
FROM gitlab.lnu.se:5050/2dv013/student/team-2024-03-pikachu/frontend/node:20.8.0-bullseye-slim

WORKDIR /app

# Copy built assets from builder
COPY --from=builder /app/dist ./dist

# Install production dependencies only
COPY package*.json ./
RUN npm ci --omit=dev

# Install serve globally
RUN npm install -g serve

# Expose port 3000
EXPOSE 3000

# Serve the app
CMD ["serve", "-s", "dist", "-l", "3000"]

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using System.Text;
using Microsoft.EntityFrameworkCore;
using DotNetEnv;
using data_service.src.helpers;
using data_service.src.data;
using data_service.src.services;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Configure logging with Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .CreateLogger();

SimpleLogger.Log("Starting Service");

Env.Load();
var jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET");
Log.Information("JWT Secret: {jwtSecret}", jwtSecret);


// RabbitMQ connection setup
var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost"; // In prod use this before localhost Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? 
var rabbitMqPort = Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672";  // Default RabbitMQ AMQP port

// Initialize RabbitMQService
var rabbitMqService = new RabbitMQService(rabbitMqHost);

// Try to connect to RabbitMQ and declare the queue, with proper logging
try
{
    rabbitMqService.Connect();  // Establish connection and declare queue
    SimpleLogger.Log("Successfully connected to RabbitMQ and declared queue.");
}
catch (Exception ex)
{
    Log.Fatal(ex, "Error connecting to RabbitMQ.");
    SimpleLogger.Log($"Failed to connect to RabbitMQ: {ex.Message}");
    throw;  // Ensure the app doesn't run if RabbitMQ connection fails
}


// Access the user secrets
var postgresUser = Environment.GetEnvironmentVariable("POSTGRES_USER");
var postgresPassword = Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
var postgresDatabase = Environment.GetEnvironmentVariable("POSTGRES_DATABASE");
var postgresPort = Environment.GetEnvironmentVariable("POSTGRES_PORT");
var postgresReplicationHost = Environment.GetEnvironmentVariable("POSTGRES_REPLICATION_HOST");
var postgresHost = Environment.GetEnvironmentVariable("POSTGRES_HOST");
var postgresSlavePort = Environment.GetEnvironmentVariable("POSTGRES_REPLICATION_PORT");

var connectionStringMaster = $"Host={postgresHost};Port={postgresPort};Username={postgresUser};Password={postgresPassword};Database={postgresDatabase}"; // TODO: Localhost for local och just postgresPort in both
var connectionStringSlave = $"Host={postgresReplicationHost};Port={postgresSlavePort};Username={postgresUser};Password={postgresPassword};Database={postgresDatabase}";

// Configure CORS
builder.Services.AddCors(opts =>
{
    opts.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure JWT Authentication with Serilog logging
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(cfg =>
{
    cfg.RequireHttpsMetadata = false;
    cfg.SaveToken = true;
    cfg.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
        ValidateIssuer = false,
        ValidateAudience = false
    };

    // Add event handlers for Serilog logging
    cfg.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            Log.Information("JWT Token received.");
            Log.Information("Authorization Header: {AuthorizationHeader}", context.Request.Headers["Authorization"]);
            return Task.CompletedTask;
        },
        OnTokenValidated = context =>
        {
            Log.Information("Token successfully validated.");
            var claimsPrincipal = context.Principal;
            var claims = claimsPrincipal.Claims.Select(c => $"{c.Type}: {c.Value}");
            Log.Information("Token Claims: {Claims}", string.Join(", ", claims));
            return Task.CompletedTask;
        },
        OnAuthenticationFailed = context =>
        {
            Log.Error("Authentication failed. Exception: {ExceptionMessage}", context.Exception.Message);
            return Task.CompletedTask;
        },
        OnChallenge = context =>
        {
            Log.Warning("Authentication challenge triggered.");
            return Task.CompletedTask;
        }
    };
});


// Register DBContext
builder.Services.AddDbContext<MasterDbContext>(options =>
    options.UseNpgsql(connectionStringMaster));

builder.Services.AddDbContext<SlaveDbContext>(options =>
    options.UseNpgsql(connectionStringSlave));

// Register services
builder.Services.AddControllers();
builder.Services.AddScoped<RabbitMQService>(serviceProvider =>
{
    return rabbitMqService;
});

builder.Services.AddScoped<IDataService, DataService>();

// Configure Swagger for Development
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Please enter your JWT token",
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        BearerFormat = "JWT",
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new List<string>()
        }
    });
});

}

var app = builder.Build();

// Check DB connection and log it
try
{
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<MasterDbContext>();
        await dbContext.Database.EnsureCreatedAsync();  // Ensures the database is created
        Log.Information("Database connected successfully.");
    }
}
catch (Exception ex)
{
    Log.Fatal(ex, "Database connection failed.");
    throw;  // Throw exception to prevent the app from running if DB connection fails
}


// Middleware
app.UseRouting();
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapControllers();

// Start RabbitMQ message consumer
var dataService = app.Services.GetService<IDataService>();
Task.Run(() => dataService.StartConsumingMessages());

app.Run();

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using System.Text;
using Authentication.src.services;
using Authentication.src.helpers;
using Authentication.src.data;
using Microsoft.EntityFrameworkCore;
using DotNetEnv;

var builder = WebApplication.CreateBuilder(args);

// Configure logging with Serilog
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .CreateLogger();

SimpleLogger.Log("Starting Service");

Env.Load();
var jwtSecret =  Environment.GetEnvironmentVariable("JWT_SECRET");

// Access the user secrets
var postgresUser =  Environment.GetEnvironmentVariable("POSTGRES_USER");
var postgresPassword =  Environment.GetEnvironmentVariable("POSTGRES_PASSWORD");
var postgresDatabase =  Environment.GetEnvironmentVariable("POSTGRES_DATABASE");
var postgresPort =  Environment.GetEnvironmentVariable("POSTGRES_PORT");
var postgresReplicationHost =  Environment.GetEnvironmentVariable("POSTGRES_REPLICATION_HOST");
var postgresHost =  Environment.GetEnvironmentVariable("POSTGRES_HOST");
var postgresSlavePort =  Environment.GetEnvironmentVariable("POSTGRES_REPLICATION_PORT");

var connectionStringMaster = $"Host={postgresHost};Port={postgresPort};Username={postgresUser};Password={postgresPassword};Database={postgresDatabase}";
var connectionStringSlave = $"Host={postgresReplicationHost};Port={postgresSlavePort};Username={postgresUser};Password={postgresPassword};Database={postgresDatabase}";
Console.WriteLine(connectionStringMaster);
Console.WriteLine(connectionStringSlave);

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

// Configure JWT Authentication
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
});

// Register DBContext
builder.Services.AddDbContext<MasterDbContext>(options =>
    options.UseNpgsql(connectionStringMaster));

builder.Services.AddDbContext<SlaveDbContext>(options =>
    options.UseNpgsql(connectionStringSlave));

// Register services
builder.Services.AddControllers();
builder.Services.AddScoped<IAuthService, AuthService>();

// Configure Swagger for Development
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();
}

var app = builder.Build();
app.Use(async (context, next) =>
{
    Log.Information("Incoming Request: {Method} {Path}", context.Request.Method, context.Request.Path);
    await next();
});

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

app.Run();

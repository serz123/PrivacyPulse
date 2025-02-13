using System;
using System.Threading.Tasks;
using Authentication.src.data;
using Authentication.src.services;
using Google.Apis.Auth;
using Microsoft.EntityFrameworkCore;
using Xunit;

public class AuthServiceTests
{
    private readonly MasterDbContext _masterDbContext;
    private readonly SlaveDbContext _slaveDbContext;
    private readonly AuthService _authService;

    public AuthServiceTests()
    {
        var masterOptions = new DbContextOptionsBuilder<MasterDbContext>()
            .UseInMemoryDatabase("MasterTestDb")
            .Options;

        var slaveOptions = new DbContextOptionsBuilder<SlaveDbContext>()
            .UseInMemoryDatabase("SlaveTestDb")
            .Options;

        _masterDbContext = new MasterDbContext(masterOptions);
        _slaveDbContext = new SlaveDbContext(slaveOptions);
        _authService = new AuthService(_masterDbContext, _slaveDbContext);
    }

    [Fact]
    public async Task Authenticate_ExistingUser_ReturnsUserDTO()
    {
        // Arrange
        var existingUser = new User
        {
            Id = Guid.NewGuid(),
            Name = "Test User",
            Email = "testuser@example.com",
            Picture = "https://example.com/picture.jpg",
            OauthSubject = "existing-oauth-subject",
            OauthIssuer = "accounts.google.com"
        };

        _slaveDbContext.Users.Add(existingUser);
        _slaveDbContext.SaveChanges();

        var payload = new GoogleJsonWebSignature.Payload
        {
            Email = "testuser@example.com",
            Name = "Test User",
            Picture = "https://example.com/picture.jpg",
            Subject = "existing-oauth-subject",
            Issuer = "accounts.google.com"
        };

        // Act
        var result = await _authService.Authenticate(payload);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(existingUser.Email, result.Email);
        Assert.Equal(existingUser.Name, result.Name);
        Assert.Equal(existingUser.Picture, result.Picture);
    }

    [Fact]
    public async Task Authenticate_NewUser_AddsUserAndReturnsUserDTO()
    {
        // Arrange
        var newUserPayload = new GoogleJsonWebSignature.Payload
        {
            Email = "newuser@example.com",
            Name = "New User",
            Picture = "https://example.com/newpicture.jpg",
            Subject = "new-oauth-subject",
            Issuer = "accounts.google.com"
        };

        // Act
        var result = await _authService.Authenticate(newUserPayload);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(newUserPayload.Email, result.Email);
        Assert.Equal(newUserPayload.Name, result.Name);
        Assert.Equal(newUserPayload.Picture, result.Picture);

        var newUser = _masterDbContext.Users.FirstOrDefault(u => u.Email == newUserPayload.Email);
        Assert.NotNull(newUser);
        Assert.Equal(newUserPayload.Subject, newUser.OauthSubject);
        Assert.Equal(newUserPayload.Issuer, newUser.OauthIssuer);
    }

    [Fact]
    public async Task Authenticate_NullPayload_ThrowsArgumentNullException()
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentNullException>(() => _authService.Authenticate(null));
    }
}


using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Xunit;
using data_service.src.controllers;
using data_service.src.services;
using data_service.src.models;
using data_service.src.data;

public class DataControllerTests
{
    [Fact]
    public async Task StartScraping_ValidInput_ReturnsOk()
    {
        // Arrange
        var mockDataService = new Mock<IDataService>();
        var controller = new DataController(mockDataService.Object);

        var claims = new[]
        {
            new Claim(ClaimTypes.Email, "test@example.com"),
            new Claim("name", "Test User")
        };
        controller.ControllerContext.HttpContext = new DefaultHttpContext
        {
            User = new ClaimsPrincipal(new ClaimsIdentity(claims))
        };

        var userInput = new UserInput
        {
            City = "New York",
            CollegeName = "Test College"
        };

        // Act
        var result = await controller.StartScraping(userInput);

        // Assert
        Assert.IsType<OkResult>(result);
        mockDataService.Verify(s => s.PushMessageToQueueAsync("test@example.com", "Test User", "New York", "Test College"), Times.Once);
    }

    [Fact]
    public async Task StartScraping_InvalidInput_ReturnsBadRequest()
    {
        // Arrange
        var mockDataService = new Mock<IDataService>();
        var controller = new DataController(mockDataService.Object);

        var claims = new[]
        {
            new Claim(ClaimTypes.Email, "test@example.com"),
            new Claim("name", "Test User")
        };
        controller.ControllerContext.HttpContext = new DefaultHttpContext
        {
            User = new ClaimsPrincipal(new ClaimsIdentity(claims))
        };

        var userInput = new UserInput
        {
            City = "" // Invalid city
        };

        // Act
        var result = await controller.StartScraping(userInput);

        // Assert
        Assert.IsType<BadRequestObjectResult>(result);
    }

   [Fact]
public async Task GetScrapedData_ValidEmail_ReturnsScrapedData()
{
    // Arrange
    var mockDataService = new Mock<IDataService>();

    // Create test data
    var testData = new ScrapedData
    {
        Id = Guid.NewGuid(),
        Email = "test@example.com",
        NameOccurrences = 10,
        EmailOccurrences = 5,
        LinkedInLink = "https://linkedin.com/in/test-profile",
        LinkedInTitle = "Software Engineer",
        LinkedInSnippet = "Experienced in software engineering.",
        LinkedInDescription = "A skilled software engineer.",
        DateScraped = DateTime.UtcNow,
        User = null
    };

    // Mock GetScrapedData to return the test data
    mockDataService
        .Setup(s => s.GetScrapedData("test@example.com"))
        .ReturnsAsync(testData); // Correctly match the method's return type

    var controller = new DataController(mockDataService.Object);

    // Set up claims
    var claims = new[]
    {
        new Claim(ClaimTypes.Email, "test@example.com")
    };

    controller.ControllerContext.HttpContext = new DefaultHttpContext
    {
        User = new ClaimsPrincipal(new ClaimsIdentity(claims))
    };

    // Act
    var result = await controller.GetScrapedData() as OkObjectResult;

    // Assert
    Assert.NotNull(result);
    Assert.Equal(testData, result.Value); // Ensure the returned data matches the test data
    mockDataService.Verify(s => s.GetScrapedData("test@example.com"), Times.Once); // Verify the method was called once
}

    [Fact]
    public async Task GetScrapedData_NoEmailClaim_ReturnsUnauthorized()
    {
        // Arrange
        var mockDataService = new Mock<IDataService>();
        var controller = new DataController(mockDataService.Object);

        controller.ControllerContext.HttpContext = new DefaultHttpContext
        {
            User = new ClaimsPrincipal(new ClaimsIdentity())
        };

        // Act
        var result = await controller.GetScrapedData();

        // Assert
        Assert.IsType<UnauthorizedObjectResult>(result);
    }
}

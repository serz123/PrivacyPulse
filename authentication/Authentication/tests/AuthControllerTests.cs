using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Authentication.src.controllers;
using Authentication.src.data;
using Authentication.src.models;
using Authentication.src.services;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Moq;
using Xunit;

public class AuthControllerTests
{
    
    [Fact]
    public async Task Signin_InvalidToken_ReturnsBadRequest()
    {
        // Arrange
        var authServiceMock = new Mock<IAuthService>();

        authServiceMock.Setup(s => s.Authenticate(It.IsAny<Google.Apis.Auth.GoogleJsonWebSignature.Payload>()))
                       .ThrowsAsync(new Exception("JWT must consist of Header, Payload, and Signature"));

        var controller = new AuthController(authServiceMock.Object);

        var userView = new UserView { TokenId = "invalidToken" };

        // Act
        var result = await controller.Signin(userView) as BadRequestObjectResult;

        // Assert
        Assert.NotNull(result);
        Assert.Equal(400, result.StatusCode);

        var error = result.Value?.GetType().GetProperty("error")?.GetValue(result.Value, null)?.ToString();
        Assert.NotNull(error);
        Assert.Contains("JWT must consist of", error);
    }
}

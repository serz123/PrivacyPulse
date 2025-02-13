using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Authentication.src.data;
using Authentication.src.helpers;
using Authentication.src.models;
using Authentication.src.services;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Serilog;

namespace Authentication.src.controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("signin-google")]
        public async Task<IActionResult> Signin([FromBody] UserView userView)
        {
            try
            {
                string _jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET");
                string _jwtEmailEncryption = Environment.GetEnvironmentVariable("JWT_EMAIL_ENCRYPTION");
                
                var payload = await GoogleJsonWebSignature.ValidateAsync(userView.TokenId,
                    new GoogleJsonWebSignature.ValidationSettings());

                var userDto = await _authService.Authenticate(payload);

                // Ensure Security.Encrypt method exists or provide implementation
                var claims = new[]
                {
                    new Claim(JwtRegisteredClaimNames.Sub, Encrypt(_jwtEmailEncryption, userDto.Email)),
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                    new Claim("name", userDto.Name),
                    new Claim("email", userDto.Email),
                    new Claim("picture", userDto.Picture)
                };

                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSecret));
                var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

                var token = new JwtSecurityToken(
                    claims: claims,
                    expires: DateTime.UtcNow.AddMinutes(55),
                    signingCredentials: creds);

                return Ok(new
                {
                    token = new JwtSecurityTokenHandler().WriteToken(token)
                });
            }
            catch (Exception ex)
            {
                // Ensure SimpleLogger.Log is defined and working
                SimpleLogger.Log(ex);
                return BadRequest(new { error = ex.Message });
            }
        }

        // Implement or ensure the existence of this Encrypt method
        private string Encrypt(string encryptionKey, string value)
        {
            // Example encryption logic
            var key = Encoding.UTF8.GetBytes(encryptionKey);
            using var hmac = new System.Security.Cryptography.HMACSHA256(key);
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(value));
            return Convert.ToBase64String(hash);
        }
    }
}

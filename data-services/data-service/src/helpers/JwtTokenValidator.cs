using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Microsoft.AspNetCore.Mvc;
using data_service.src.helpers;
using System.Text;
using Serilog;

namespace backend_test.Helpers
{
    public class JwtTokenValidator : ISecurityTokenValidator
    {
        private readonly JwtSecurityTokenHandler _tokenHandler;

        public JwtTokenValidator()
        {
            _tokenHandler = new JwtSecurityTokenHandler();
        }

        public bool CanValidateToken => true;

        public int MaximumTokenSizeInBytes { get; set; } = TokenValidationParameters.DefaultMaximumTokenSizeInBytes;

        public bool CanReadToken(string securityToken)
        {
            return _tokenHandler.CanReadToken(securityToken);
        }

        public ClaimsPrincipal ValidateToken(string securityToken, TokenValidationParameters validationParameters, out SecurityToken validatedToken)
        {
            string jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret));
            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = false,
                ValidateAudience = false,
                ValidateLifetime = true,
                IssuerSigningKey = key
            };

            try
            {
                Log.Information("Validating token...");
                var principal = _tokenHandler.ValidateToken(securityToken, tokenValidationParameters, out validatedToken);
                Log.Information("Token validated successfully. Claims: {claims}", string.Join(", ", principal.Claims.Select(c => $"{c.Type}: {c.Value}")));
                return principal;
            }
            catch (Exception ex)
            {
                Log.Error("Token validation failed: {error}", ex.Message);
                throw;
            }

        }
    }
}

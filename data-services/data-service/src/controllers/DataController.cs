using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using data_service.src.services;
using Microsoft.AspNetCore.Authorization;
using data_service.src.data;
using System.ComponentModel.DataAnnotations;
using Serilog;
using data_service.src.models;

namespace data_service.src.controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DataController : ControllerBase
    {
        private readonly IDataService _dataService;

        public DataController(IDataService dataService)
        {
            _dataService = dataService;
        }

        [Authorize]
        [HttpPost("startScraping")]
        public async Task<IActionResult> StartScraping([FromBody] UserInput userInput)
        {
            // Log the Authorization header
            var token = Request.Headers["Authorization"].ToString();
            Log.Information($"Received Token: {token}");


            // Get the email claim from the authenticated user
            var email = User.FindFirst(ClaimTypes.Email)?.Value;
            var name = User.FindFirst("name")?.Value;
            var city = userInput.City;
            var collegeName = "";

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized("Email claim not found.");
            }
            if (string.IsNullOrEmpty(city))
            {
                return BadRequest("City not found.");
            }
            if (string.IsNullOrEmpty(name))
            {
                return Unauthorized("Name claim not found.");
            }

            if (userInput.CollegeName != null)
            {
                collegeName = userInput.CollegeName;
            }
            await _dataService.PushMessageToQueueAsync(email, name, city, collegeName);
            return Ok();
        }

        [Authorize]
        [HttpGet("getScrapedData")]
        public async Task<IActionResult> GetScrapedData()
        {
            // Get the email claim from the authenticated user
            var email = User.FindFirst(ClaimTypes.Email)?.Value;

            if (string.IsNullOrEmpty(email))
            {
                return Unauthorized("Email claim not found.");
            }
            ScrapedData data = await _dataService.GetScrapedData(email);
            return Ok(data);
        }
    }
}

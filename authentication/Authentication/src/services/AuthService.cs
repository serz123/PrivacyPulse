using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Authentication.src.data;
using Authentication.src.helpers;
using Google.Apis.Auth;

namespace Authentication.src.services
{
    public class AuthService : IAuthService
    {
        private readonly MasterDbContext _masterContext;
        private readonly SlaveDbContext _slaveContext;

        public AuthService(MasterDbContext masterContext, SlaveDbContext slaveContext)
        {
            _masterContext = masterContext;
            _slaveContext = slaveContext;
        }

        public async Task<UserDTO> Authenticate(GoogleJsonWebSignature.Payload payload)
        {
            if (payload == null)
                throw new ArgumentNullException(nameof(payload), "Payload cannot be null");

            var user = await Task.FromResult(FindUserOrAdd(payload));
            return user.ToDto();
        }

        private User FindUserOrAdd(GoogleJsonWebSignature.Payload payload)
        {
            // Check if the user exists
            var user = _slaveContext.Users.FirstOrDefault(u => u.Email == payload.Email);

            // Add a new user if not found
            if (user == null)
            {
                user = new User
                {
                    Id = Guid.NewGuid(),
                    Name = payload.Name,
                    Email = payload.Email,
                    Picture = payload.Picture,
                    OauthSubject = payload.Subject,
                    OauthIssuer = payload.Issuer
                };
                _masterContext.Users.Add(user);
                _masterContext.SaveChanges();
            }
            return user;
        }
    }
}

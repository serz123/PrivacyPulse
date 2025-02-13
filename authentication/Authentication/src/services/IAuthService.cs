using Authentication.src.data;

namespace Authentication.src.services
{
    public interface IAuthService
    {
        Task<UserDTO> Authenticate(Google.Apis.Auth.GoogleJsonWebSignature.Payload payload);
    }
}


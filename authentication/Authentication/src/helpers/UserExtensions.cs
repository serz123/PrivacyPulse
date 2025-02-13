using Authentication.src.data;

namespace Authentication.src.helpers
{
    public static class UserExtensions
    {
        public static UserDTO ToDto(this User user)
        {
            return new UserDTO
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email,
                Picture = user.Picture
            };
        }
    }
}

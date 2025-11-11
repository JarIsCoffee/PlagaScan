using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PlagaBackend.Models;

namespace PlagaBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;

        public AuthController(AuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] UsuarioRegisterModel model)
        {
            var usuario = new Usuario
            {
                Nombre = model.Nombre,
                Apellido = model.Apellido,
                Email = model.Email,
                FotoPerfil = model.FotoPerfil
            };

            var result = await _authService.Register(usuario, model.Password);

            if (!result)
                return BadRequest("El usuario ya existe");

            return Ok("Usuario registrado exitosamente");
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] UsuarioLoginModel model)
        {
            var user = _authService.Login(model.Email, model.Password);
            if (user == null) return Unauthorized("Credenciales incorrectas");

            return Ok(new { user.IdUsuario, user.Nombre, user.Apellido, user.Email, user.FotoPerfil });
        }

        [HttpPut("updateProfile/{id}")]
        public async Task<IActionResult> UpdateProfile(int id, [FromBody] UpdateProfileModel model)
        {
            var user = await _authService.UpdateProfileFoto(id, model.Nombre, model.Apellido, model.FotoPerfil);
            if (user == null) return NotFound("Usuario no encontrado");

            return Ok(new { user.IdUsuario, user.Nombre, user.Apellido, user.Email, user.FotoPerfil });
        }
    }
}

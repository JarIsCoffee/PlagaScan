namespace PlagaBackend.Models
{
    public class UsuarioRegisterModel
    {
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }

        public string FotoPerfil { get; set; }
    }
}

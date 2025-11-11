using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using PlagaBackend.Models;

public class AuthService
{
    private readonly AppvirtualContext _context;

    public AuthService(AppvirtualContext context)
    {
        _context = context;
    }

    public async Task<bool> Register(Usuario usuario, string password)
    {
        if (_context.Usuarios.Any(u => u.Email == usuario.Email))
            return false; // Usuario ya existe

        usuario.PasswordHash = HashPassword(password);
        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();
        return true;
    }

    public Usuario Login(string email, string password)
    {
        var user = _context.Usuarios.FirstOrDefault(u => u.Email == email);
        if (user == null) return null;

        if (VerifyPassword(password, user.PasswordHash)) { 
            return user;
        }

        return null;
    }

    private string HashPassword(string password)
    {
        using var sha256 = SHA256.Create();
        var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
        return Convert.ToBase64String(hashedBytes);
    }

    private bool VerifyPassword(string password, string hash)
    {
        return HashPassword(password) == hash;
    }

    public async Task<Usuario> UpdateProfileFoto(int userId, string nombre, string apellido, string fotoPerfil)
    {
        var user = await _context.Usuarios.FindAsync(userId);
        if (user == null) return null;

        user.Nombre = nombre;
        user.Apellido = apellido;
        user.FotoPerfil = fotoPerfil;
        await _context.SaveChangesAsync();
        return user;
    }
}

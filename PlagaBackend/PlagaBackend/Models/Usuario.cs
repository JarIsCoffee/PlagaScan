using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PlagaBackend.Models;

public partial class Usuario
{
    public int IdUsuario { get; set; }

    [Required]
    public string Nombre { get; set; }

    [Required]
    public string Apellido { get; set; }

    [Required]
    [EmailAddress]
    public string Email { get; set; }

    public string FotoPerfil { get; set; }

    [Required]
    public string PasswordHash { get; set; }

    public DateTime FechaRegistro { get; set; } = DateTime.Now;
}

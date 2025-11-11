using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace PlagaBackend.Models
{
    public class CultivosModel
    {
        public int id_cultivo { get; set; }

       
        public int IdPlaga { get; set; }


        public string Nombre { get; set; } = string.Empty;

        public string Variedad { get; set; } = string.Empty;

        public string Ubicacion { get; set; } = string.Empty;

        public DateTime fecha_registro { get; set; } = DateTime.Now;

        // Relación con la plaga
        [ForeignKey("IdPlaga")]
        public virtual plagaModel Plaga { get; set; } = null!;
    }
}

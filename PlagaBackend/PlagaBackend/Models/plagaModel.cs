namespace PlagaBackend.Models
{
    public class plagaModel
    {
        public int id_plaga { get; set; }
        public string nombre_comun { get; set; } = string.Empty;
        public string nombre_cientifico { get; set; } = string.Empty;
        public string descripcion { get; set; } = string.Empty;
        public string sintomas { get; set; } = string.Empty;
    }
}

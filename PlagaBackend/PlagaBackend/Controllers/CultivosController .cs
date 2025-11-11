using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PlagaBackend.Models;

namespace PlagaBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CultivosController : ControllerBase
    {
        private readonly AppvirtualContext _context;

        public CultivosController(AppvirtualContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetCultivos()
        {
            var cultivos = await _context.Cultivos
                .Include(c => c.Plaga)
                .ToListAsync();
            return Ok(cultivos);
        }
    }
}


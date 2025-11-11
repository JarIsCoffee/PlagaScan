using System;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PlagaBackend.Models;

namespace PlagaBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlagasController : ControllerBase
    {
        private readonly AppvirtualContext _context;

        public PlagasController(AppvirtualContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetPlagas()
        {
            var plagas = await _context.Plagas.ToListAsync();
            return Ok(plagas);
        }
    }
}

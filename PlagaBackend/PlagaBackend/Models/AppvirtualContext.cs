using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Pomelo.EntityFrameworkCore.MySql.Scaffolding.Internal;

namespace PlagaBackend.Models;

public partial class AppvirtualContext : DbContext
{
    public AppvirtualContext() { }

    public AppvirtualContext(DbContextOptions<AppvirtualContext> options)
        : base(options) { }

    public virtual DbSet<Usuario> Usuarios { get; set; }
    public virtual DbSet<plagaModel> Plagas { get; set; }

    public virtual DbSet<CultivosModel> Cultivos { get; set; }

    //    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    //#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
    //        => optionsBuilder.UseMySql("server=localhost;port=3306;database=appvirtual;uid=root;password=Jairo2021*", Microsoft.EntityFrameworkCore.ServerVersion.Parse("8.0.41-mysql"));

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .UseCollation("utf8mb4_0900_ai_ci")
            .HasCharSet("utf8mb4");

        // Configuración de la tabla usuarios
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.IdUsuario).HasName("PRIMARY");

            entity.ToTable("usuarios");

            entity.HasIndex(e => e.Email, "Email").IsUnique();

            entity.Property(e => e.Apellido).HasMaxLength(100);
            entity.Property(e => e.Email).HasMaxLength(150);
            entity.Property(e => e.FechaRegistro)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");
            entity.Property(e => e.Nombre).HasMaxLength(100);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
        });

        // Configuración de la tabla plagas
        modelBuilder.Entity<plagaModel>(entity =>
        {
            entity.HasKey(e => e.id_plaga).HasName("PRIMARY");
            entity.ToTable("plagas");

            entity.Property(e => e.nombre_comun).HasMaxLength(100);
            entity.Property(e => e.nombre_cientifico).HasMaxLength(150);
            entity.Property(e => e.descripcion).HasColumnType("text");
            entity.Property(e => e.sintomas).HasColumnType("text");
        });

        // Configuración de la tabla cultivos
        modelBuilder.Entity<CultivosModel>(entity =>
        {
            entity.HasKey(e => e.id_cultivo).HasName("PRIMARY");

            entity.ToTable("cultivos");

            entity.Property(e => e.Nombre)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.Variedad)
                .HasMaxLength(100);

            entity.Property(e => e.Ubicacion)
                .HasMaxLength(255);

            entity.Property(e => e.fecha_registro)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("datetime");

            // Relación con plaga
            entity.HasOne(e => e.Plaga)
                  .WithMany()
                  .HasForeignKey(e => e.IdPlaga)
                  .OnDelete(DeleteBehavior.Cascade)
                  .HasConstraintName("FK_Cultivo_Plaga");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

# claude-config

Configuración global personal de Claude Code — comandos y skills disponibles en todos los proyectos.

[English](README.md)

## Comandos

Slash commands disponibles como `/nombre-comando` en cualquier sesión de Claude Code.

| Comando | Descripción |
|---|---|
| `/new-project` | Bootstrap completo de un proyecto: PRD → decisiones de arquitectura → specs de módulos → planes de implementación → scaffold ejecutable → CLAUDE.md. Cubre tenencia, motor de base de datos, modelo de autenticación, estilo de UI, datos semilla, fixtures de desarrollo y más. Autocontenido — no requiere referencias externas. |
| `/implement-phase` | Implementa una fase planificada: verificación de git status → carga de contexto → aclaración del spec antes de escribir código → construcción en orden de dependencias → escritura o actualización de tests → sincronización de docs → actualización del estado de la fase. |
| `/change-module` | Aplica un cambio a un módulo completado. Clasifica el cambio como fix / mejora / transversal, actualiza los docs y luego implementa directamente (fix) o crea un plan de parche y lo delega a `/implement-phase`. |
| `/add-module` | Agrega un nuevo módulo a mitad de proyecto. Verifica alineación con el PRD, reúne requerimientos en grupos estructurados, escribe el spec y el plan, actualiza `docs/index.md`. Sin implementación — ejecutar `/implement-phase` después. |

### Flujo de trabajo

```
/new-project        Bootstrap desde cero
      ↓
/implement-phase    Construir fase por fase
      ↓
/change-module      Corregir o extender trabajo completado
/add-module         Agregar un módulo no incluido en el plan original
```

## Skills

| Skill | Descripción |
|---|---|
| *(agrega los tuyos aquí)* | |

## Estructura de carpetas

```
claude-config/
├── README.md
├── README.es.md
├── install.sh              Mac / Linux
├── install.ps1             Windows
├── commands/
│   ├── new-project.md
│   ├── implement-phase.md
│   ├── change-module.md
│   └── add-module.md
└── skills/
    └── {nombre-skill}/
        ├── SKILL.md
        └── (archivos de soporte)
```

## Instalación

Clona el repositorio en cualquier carpeta de tu máquina:

```bash
# Mac / Linux
git clone git@github.com/vicmangontel/claude-config.git ~/claude-config

# Windows
git clone git@github.com/vicmangontel/claude-config.git $env:USERPROFILE\claude-config
```

Luego ejecuta el script de instalación. Copia los comandos y skills a las carpetas de instalación de Claude Code. **Nunca elimina nada** — los archivos que ya existen en tus carpetas de Claude y que no están en este repositorio se dejan completamente intactos.

### Mac / Linux

```bash
cd ~/claude-config
chmod +x install.sh
./install.sh
```

### Windows

```powershell
cd $env:USERPROFILE\claude-config
.\install.ps1
```

> No se requieren permisos de Administrador ni Modo Desarrollador — el script solo copia archivos, no crea symlinks.

## Actualización

Descarga los últimos cambios y vuelve a ejecutar el script de instalación:

```bash
# Mac / Linux
cd ~/claude-config && git pull && ./install.sh

# Windows
cd $env:USERPROFILE\claude-config; git pull; .\install.ps1
```

## Agregar un nuevo comando

1. Crear `commands/{nombre}.md`
2. `git add . && git commit -m "feat: add /{nombre} command"`
3. `git push`
4. Ejecutar el script de instalación para copiarlo a tu instalación de Claude

## Agregar un nuevo skill

1. Crear `skills/{nombre-skill}/SKILL.md` y cualquier archivo de soporte
2. `git add . && git commit -m "feat: add {nombre-skill} skill"`
3. `git push`
4. Ejecutar el script de instalación para copiarlo a tu instalación de Claude

## Cómo funciona el script de instalación

| Situación | Resultado |
|---|---|
| Archivo en el repo, no en el destino | Se copia |
| Archivo en ambos, contenido modificado | El destino se sobreescribe con la versión más reciente |
| Archivo en ambos, contenido idéntico | Se omite — no se toca |
| Archivo en el destino pero no en el repo | Se deja completamente intacto |

Se puede ejecutar en cualquier momento, tantas veces como sea necesario.

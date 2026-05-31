# claude-config

Personal Claude Code global configuration — commands and skills available across all projects.

## Commands

Slash commands available as `/command-name` in any Claude Code session.

| Command | Description |
|---|---|
| `/new-project` | Full project bootstrap: PRD → architecture decisions → module specs → implementation plans → runnable scaffold → CLAUDE.md. Covers tenancy, DB engine, auth model, UI style, seed data, dev fixtures and more. Self-contained — no external reference needed. |
| `/implement-phase` | Implement one planned phase: git status check → load context → clarify spec before writing any code → build in dependency order → write or update tests → sync docs → update phase status. |
| `/change-module` | Apply a change to a completed module. Classifies the change as fix / enhancement / cross-cutting, updates docs, then either implements directly (fix) or creates a patch plan and hands off to `/implement-phase`. |
| `/add-module` | Add a new module mid-project. Checks PRD alignment, gathers requirements in structured groups, writes the spec and plan, updates `docs/index.md`. No implementation — run `/implement-phase` after. |

### Command workflow

```
/new-project        Bootstrap everything from scratch
      ↓
/implement-phase    Build phase by phase
      ↓
/change-module      Fix or extend completed work
/add-module         Add a module not in the original plan
```

## Skills

| Skill | Description |
|---|---|
| *(add yours here)* | |

## Folder structure

```
claude-config/
├── README.md
├── install.sh              Mac / Linux
├── install.ps1             Windows
├── commands/
│   ├── new-project.md
│   ├── implement-phase.md
│   ├── change-module.md
│   └── add-module.md
└── skills/
    └── {skill-name}/
        ├── SKILL.md
        └── (any supporting files)
```

## Setup

Clone the repo anywhere on your machine:

```bash
# Mac / Linux
git clone git@github.com/vicmangontel/claude-config.git ~/claude-config

# Windows
git clone git@github.com/vicmangontel/claude-config.git $env:USERPROFILE\claude-config
```

Then run the install script. It copies commands and skills into your Claude Code
installation folders. **It never deletes anything** — files already in your Claude
folders that are not in this repo are left completely untouched.

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

> No Administrator or Developer Mode required — the script only copies files,
> it does not create symlinks.

## Updating

Pull the latest and re-run the install script:

```bash
# Mac / Linux
cd ~/claude-config && git pull && ./install.sh

# Windows
cd $env:USERPROFILE\claude-config; git pull; .\install.ps1
```

## Adding a new command

1. Create `commands/{name}.md`
2. `git add . && git commit -m "feat: add /{name} command"`
3. `git push`
4. Run the install script to copy it into your Claude installation

## Adding a new skill

1. Create `skills/{skill-name}/SKILL.md` and any supporting files alongside it
2. `git add . && git commit -m "feat: add {skill-name} skill"`
3. `git push`
4. Run the install script to copy it into your Claude installation

## How the install script works

| Situation | Result |
|---|---|
| File in repo, not in destination | Copied in |
| File in both, content changed | Destination overwritten with latest version |
| File in both, content identical | Skipped — not touched |
| File in destination but not in repo | Left completely alone |

Safe to run at any time, as many times as needed.

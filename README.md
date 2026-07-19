# Echo Runner

Echo Runner je 2D strategická plošinovka vytvořená v Godot 4.6. Hráč má na každý průchod levelem omezený čas. Po skončení kola se jeho vstupy uloží, level se obnoví a vznikne echo, které předchozí pohyb přesně zopakuje. Hráč tak spolupracuje se svými minulými verzemi a postupně řeší hádanky s tlačítky, dveřmi, nepřáteli a cílem.

## Spuštění

1. Otevřete projekt v Godot 4.6 nebo novějším.
2. Spusťte celý projekt klávesou `F5`.

Hlavní scéna projektu je `game/game.tscn`.

## Ovládání

- pohyb doleva: `A` nebo šipka doleva
- pohyb doprava: `D` nebo šipka doprava
- skok: `W`, mezerník nebo šipka nahoru
- předčasně dokončit kolo a vytvořit echo: `E`

## Herní systém

- Každý level určuje délku kola a maximální počet ech.
- `LoopManager` zaznamenává vstup hráče po fyzikálních snímcích.
- Po skončení kola se celý level znovu vytvoří ze své `PackedScene`.
- Klávesou `E` lze kolo dokončit okamžitě; zbývající čas nahrávky se doplní nečinností, takže echo zůstane stát na místě.
- Dokončené nahrávky zůstávají mezi koly stejného levelu.
- Při přechodu do dalšího levelu se staré nahrávky smažou.
- Echo používá stejnou scénu runnera a stejné fyzikální reakce jako živý hráč.
- Echo může reagovat na nepřátele a aktivovat tlačítka, ale nemění hráčovo skóre ani HUD zdraví.

## Struktura projektu

```text
game/
├── game.tscn
└── game.gd

levels/
├── base_level.tscn
├── base_level.gd
├── level_01.tscn
├── level_02.tscn
├── level_03.tscn
├── level_04.tscn
└── level_05.tscn

actors/runner/
├── runner.tscn
├── runner.gd
└── runner_input.gd

systems/
└── loop_manager.gd

objects/
├── pressure_plate.tscn
├── echo_door.tscn
├── level_goal.tscn
├── potvora.tscn
└── mince.tscn

tilesets/
├── platform_tileset.tres
└── background_tileset.tres
```

## Struktura levelu

Každý level dědí z `levels/base_level.tscn` a zachovává společné schéma:

```text
Level
├── BackgroundColor
├── TileMapBackground
├── TileMapWorld
├── DecorationsFront
├── RunnerSpawn
├── EchoSpawn
├── Actors
├── Interactables
└── Goal
```

- `TileMapWorld` obsahuje pevné prostředí a kolize.
- `TileMapBackground` a `DecorationsFront` jsou dekorativní vrstvy bez kolizí.
- `Actors` obsahuje živého runnera, echa a nepřátele.
- `Interactables` obsahuje tlačítka, dveře a další logické objekty.
- `RunnerSpawn` a `EchoSpawn` určují počáteční pozice.

Rozmístění dlaždic je uložené samostatně v každém levelu. Definice dlaždic a jejich kolize jsou sdílené prostřednictvím souborů v adresáři `tilesets/`.

## Kampaň

- Level 1: první echo a jedno tlačítko.
- Level 2: delší cesta a spolupráce s jedním echem.
- Level 3: dvě tlačítka a dvě echa.
- Level 4: echo v kombinaci s nepřítelem.
- Level 5: tři tlačítka, tři echa a finální hádanka.

## Použité zdroje

Grafické zdroje SpriteLib jsou uložené v `spritelib_gpl/`; původní licenční informace jsou v `spritelib_gpl/license.txt`. Další zdroje projektu budou popsány v kořenovém souboru `resources.md`.
